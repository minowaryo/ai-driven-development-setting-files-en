#!/usr/bin/env bash
# Tests for .claude/hooks/domain-boundary-check.sh (findings, priority signal, heuristic).
# Template-internal: APPLY_TEMPLATE.md class X — never copied into target projects.
# Builds throwaway git repos under mktemp; touches nothing in this repository.
# Usage: bash meta/tests/domain-boundary-check.test.sh [path/to/domain-boundary-check.sh]
set -u

SCRIPT="${1:-$(cd "$(dirname "$0")/../.." && pwd)/.claude/hooks/domain-boundary-check.sh}"
ROOT=$(mktemp -d)
trap 'rm -rf "$ROOT"' EXIT
PASS=0
FAIL=0

new_repo() {
  local d
  d=$(mktemp -d -p "$ROOT")
  git -C "$d" init -q -b main
  git -C "$d" config user.email t@example.com
  git -C "$d" config user.name t
  git -C "$d" config core.autocrlf false
  echo base >"$d/README.md"
  git -C "$d" add . && git -C "$d" commit -qm base
  git -C "$d" checkout -qb feat/x
  echo "$d"
}

# ctrl DIR NAME [PARAMS] < body — wraps the body in one method so its first line is L6.
ctrl() {
  local f="$1/app/Http/Controllers/$2.php"
  mkdir -p "$(dirname "$f")"
  {
    printf '<?php\nclass %s extends Controller\n{\n    public function store(%s)\n    {\n' "$2" "${3:-Request \$request}"
    cat
    printf '    }\n}\n'
  } >"$f"
}

# raw DIR PATH < content — writes a file verbatim (for layouts ctrl cannot express).
raw() { mkdir -p "$(dirname "$1/$2")"; cat >"$1/$2"; }

run() { # run DIR [ARGS...] -> sets OUT, ERR, RC
  local d=$1; shift
  OUT=$(cd "$d" && bash "$SCRIPT" "$@" 2>"$d/.stderr")
  RC=$?
  ERR=$(cat "$d/.stderr")
}

check() { # check NAME CONDITION
  if eval "$2"; then
    PASS=$((PASS + 1)); echo "PASS: $1"
  else
    FAIL=$((FAIL + 1)); echo "FAIL: $1 -- expected: $2"; echo "$OUT" | sed 's/^/    | /'
    [ -n "$ERR" ] && echo "$ERR" | sed 's/^/    ! /'
  fi
}

has()      { printf '%s\n' "$OUT" | grep -qx "$1"; }
contains() { printf '%s\n' "$OUT" | grep -qF -- "$1"; }
finding()  { printf '%s\n' "$OUT" | grep -qE "^ +L$1 +$2 "; }            # finding LINE CATEGORY
findings() { printf '%s\n' "$OUT" | grep -cE '^ +L[0-9]+ +[a-z-]+ '; }  # number of listed findings
summary()  { contains ">> $1 violation(s), $2 heuristic warning(s), $3 priority file(s)."; }

# ---------------------------------------------------------------------------
# Regression: detections that already work must keep working
# ---------------------------------------------------------------------------

# R1: a Controller that follows the contract is clean
d=$(new_repo); ctrl "$d" CleanController 'StoreOrderRequest $request' <<'EOF'
        $this->authorize('create', Order::class);
        $order = $this->placeOrder->execute($request->validated());
        return redirect()->route('orders.show', $order);
EOF
run "$d"
check "R1 clean: no violations" 'has VIOLATIONS=0 && contains "No Domain Boundary violations"'
check "R1 clean: exit 0" '[ "$RC" -eq 0 ]'

# R2: DB:: in a Controller
d=$(new_repo); ctrl "$d" DbController <<'EOF'
        DB::transaction(fn () => $this->orders->run());
EOF
run "$d"
check "R2 DB:: is db-access" 'finding 6 db-access'
check "R2 findings exit 1" '[ "$RC" -eq 1 ]'

# R3: static Eloquent create
d=$(new_repo); ctrl "$d" CreateController <<'EOF'
        $user = User::create($request->validated());
EOF
run "$d"
check "R3 Model::create is eloquent-write" 'finding 6 eloquent-write'

# R4: instance Eloquent update
d=$(new_repo); ctrl "$d" UpdateController <<'EOF'
        $order->update(['status' => 'paid']);
EOF
run "$d"
check "R4 \$order->update is eloquent-write" 'finding 6 eloquent-write'

# R5: inline role comparison
d=$(new_repo); ctrl "$d" RoleController <<'EOF'
        if ($request->user()->role === 'admin') { abort(403); }
EOF
run "$d"
check "R5 ->role === is role-check" 'finding 6 role-check'

# R6: role predicate method
d=$(new_repo); ctrl "$d" IsAdminController <<'EOF'
        if (auth()->user()->isAdmin()) { abort(403); }
EOF
run "$d"
check "R6 isAdmin() is role-check" 'finding 6 role-check'

# R7: priority signal — writes guarded only by a hand-written role check
d=$(new_repo); ctrl "$d" PriorityController <<'EOF'
        if ($request->user()->isAdmin()) {
            $order->delete();
        }
EOF
run "$d"
check "R7 priority file listed" 'contains "READ THESE FIRST" && contains "app/Http/Controllers/PriorityController.php" && summary 2 0 1'

# R8: sanctioned shapes — own collaborators and non-DB facades
d=$(new_repo); ctrl "$d" SanctionedController <<'EOF'
        $this->service->create($request->validated());
        Storage::delete($request->input('path'));
        Cache::forget('orders');
EOF
run "$d"
check "R8 \$this-> and facades not flagged" 'has VIOLATIONS=0'

# R9: branch density; a closure does not reset the per-method count
d=$(new_repo); ctrl "$d" DenseController <<'EOF'
        if ($a) { abort(400); }
        if ($b) { abort(400); }
        $f = function () { return 1; };
        if ($c) { abort(400); }
        if ($d) { abort(400); }
        if ($e) { abort(400); }
        if ($g) { abort(400); }
EOF
run "$d"
check "R9 dense method warned" 'summary 0 1 0 && contains "branches=6"'

# R10: files outside the Controller paths are not scanned
d=$(new_repo); raw "$d" app/Services/OrderService.php <<'EOF'
<?php
class OrderService
{
    public function cancel(Order $order) { $order->update(['status' => 'cancelled']); }
}
EOF
run "$d"
check "R10 non-Controller not scanned" 'contains "Controllers scanned: 0" && has VIOLATIONS=0'

# R11: comments are not code
d=$(new_repo); ctrl "$d" CommentController <<'EOF'
        // $order->delete();
        /* DB::table('orders')->delete(); */
        # $order->update([]);
EOF
run "$d"
check "R11 comments ignored" 'has VIOLATIONS=0'

# R12: outside a git repository the check skips gracefully
d=$(mktemp -d -p "$ROOT"); run "$d"
check "R12 non-git skips with exit 0" 'contains "not a git repository" && [ "$RC" -eq 0 ]'

# R13: an untyped variable stays flagged (its type is unknown, so it may be a Model)
d=$(new_repo); ctrl "$d" UntypedController <<'EOF'
        $cart->update($request->validated());
EOF
run "$d"
check "R13 untyped \$cart->update still flagged" 'finding 6 eloquent-write'

# ---------------------------------------------------------------------------
# Misses that must now be caught
# ---------------------------------------------------------------------------

# N1: static query chain ending in a write
d=$(new_repo); ctrl "$d" StaticChainController <<'EOF'
        Order::where('id', $id)->update(['status' => 'cancelled']);
EOF
run "$d"
check "N1 Model::where()->update() flagged" 'finding 6 eloquent-write'

# N2: static finder chain ending in a write
d=$(new_repo); ctrl "$d" FinderController <<'EOF'
        Order::findOrFail($id)->delete();
EOF
run "$d"
check "N2 Model::findOrFail()->delete() flagged" 'finding 6 eloquent-write'

# N3: chain split over lines; later line numbers stay correct
d=$(new_repo); ctrl "$d" MultiLineController <<'EOF'
        $order
            ->update(['x' => 1]);
        $other->delete();
EOF
run "$d"
check "N3 multi-line chain reported at its first line" 'finding 6 eloquent-write'
check "N3 next statement keeps its own line number" 'finding 8 eloquent-write && [ "$(findings)" -eq 2 ]'

# N4: static chain split over lines
d=$(new_repo); ctrl "$d" MultiLineStaticController <<'EOF'
        Order::query()
            ->whereKey($id)
            ->delete();
EOF
run "$d"
check "N4 multi-line static chain flagged" 'finding 6 eloquent-write'

# N5: nested parentheses inside the chain's arguments
d=$(new_repo); ctrl "$d" NestedController <<'EOF'
        Order::findOrFail($request->input('id'))->delete();
EOF
run "$d"
check "N5 nested-argument chain flagged" 'finding 6 eloquent-write'

# N6: reversed role comparison
d=$(new_repo); ctrl "$d" ReversedRoleController <<'EOF'
        if ('admin' === $request->user()->role) { abort(403); }
EOF
run "$d"
check "N6 'admin' === ->role is role-check" 'finding 6 role-check'

# N7: enum-backed role
d=$(new_repo); ctrl "$d" EnumRoleController <<'EOF'
        if ($request->user()->role->value === 'admin') { abort(403); }
EOF
run "$d"
check "N7 ->role->value === is role-check" 'finding 6 role-check'

# N8: in_array over a chained role
d=$(new_repo); ctrl "$d" InArrayRoleController <<'EOF'
        if (in_array($request->user()->role, ['admin', 'owner'])) { abort(403); }
EOF
run "$d"
check "N8 in_array(chain->role) is role-check" 'finding 6 role-check'

# N9: nullsafe write
d=$(new_repo); ctrl "$d" NullsafeController <<'EOF'
        $order?->delete();
EOF
run "$d"
check "N9 \$order?->delete() flagged" 'finding 6 eloquent-write'

# ---------------------------------------------------------------------------
# False positives that must now be quiet
# ---------------------------------------------------------------------------

# F1: method-injected Service is a sanctioned collaborator
d=$(new_repo); ctrl "$d" InjectedServiceController 'StoreOrderRequest $request, CreateOrderService $service' <<'EOF'
        $order = $service->create($request->validated());
        return response()->json($order);
EOF
run "$d"
check "F1 injected *Service not flagged" 'has VIOLATIONS=0'

# F2: multi-line signature with an injected Action next to a route-bound Model
d=$(new_repo); raw "$d" app/Http/Controllers/InjectedActionController.php <<'EOF'
<?php
class InjectedActionController extends Controller
{
    public function update(
        UpdateOrderRequest $request,
        Order $order,
        UpdateOrderAction $action,
    ) {
        $action->update($order, $request->validated());
        $order->update(['seen' => true]);
    }

    public function destroy(Order $order)
    {
        $action->delete($order);
    }
}
EOF
run "$d"
check "F2 injected *Action not flagged" '! finding 9 eloquent-write'
check "F2 Model-typed param still flagged" 'finding 10 eloquent-write'
check "F2 injection does not leak into the next method" 'finding 15 eloquent-write && [ "$(findings)" -eq 2 ]'

# F3: ->cannot() is a Policy call, so the file is not a priority file
d=$(new_repo); ctrl "$d" CannotController <<'EOF'
        if ($request->user()->cannot('update', $order)) { abort(403); }
        if ($request->user()->isAdmin()) { $order->load('items'); }
        $order->update($request->validated());
EOF
run "$d"
check "F3 ->cannot() counts as authorization" 'summary 2 0 0'

# F4: ->can() is a Policy call, so the file is not a priority file
d=$(new_repo); ctrl "$d" CanController <<'EOF'
        abort_unless($request->user()->can('update', $order), 403);
        if ($request->user()->hasRole('editor')) { $order->load('items'); }
        $order->update($request->validated());
EOF
run "$d"
check "F4 ->can() counts as authorization" 'summary 2 0 0'

echo "== $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
