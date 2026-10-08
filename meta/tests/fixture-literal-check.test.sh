#!/usr/bin/env bash
# Tests for .claude/hooks/fixture-literal-check.sh (ADR-0017 outcome, prerequisite 1).
# Template-internal: APPLY_TEMPLATE.md class X — never copied into target projects.
# Builds throwaway git repositories under mktemp; touches nothing in this repository.
# Usage: bash meta/tests/fixture-literal-check.test.sh [path/to/fixture-literal-check.sh]
set -u

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPT="${1:-$REPO/.claude/hooks/fixture-literal-check.sh}"
SNAPSHOT="$REPO/.claude/hooks/tdd-snapshot.sh"
ROOT=$(mktemp -d)
trap 'rm -rf "$ROOT"' EXIT
PASS=0
FAIL=0

# A project committed at "cycle start": one existing service (status vocabulary 'placed'), one
# approved test that feeds the value 'SKU-A' and expects the message 'Weekly report', a spec.
fresh() {
  P="$ROOT/p$RANDOM$RANDOM"
  mkdir -p "$P/tests/Feature" "$P/docs/product" "$P/app/Services"
  git -C "$P" init -q
  git -C "$P" config core.autocrlf false
  git -C "$P" config user.email t@example.invalid; git -C "$P" config user.name t
  cat > "$P/tests/Feature/StockTest.php" <<'EOF'
<?php
test('decrements stock', function () {
    $p = Product::factory()->create(['sku' => 'SKU-A', 'stock' => 5]);
    $this->post('/orders', ['sku' => 'SKU-A', 'status' => 'placed', 'note' => 'Weekly report']);
    expect($p->fresh()->stock)->toBe(4);
});
EOF
  printf 'An order has the status placed. Quantity is 1 to 100.\n' > "$P/docs/product/use-cases.md"
  cat > "$P/app/Services/OrderService.php" <<'EOF'
<?php
class OrderService { public function isPlaced($o) { return $o->status === 'placed'; } }
EOF
  git -C "$P" add -A; git -C "$P" commit -q -m start
  (cd "$P" && bash "$SNAPSHOT" record >/dev/null 2>&1)
}
run() { (cd "$P" && bash "$SCRIPT" "$@" >"$ROOT/out" 2>&1); echo $?; }
expect() { # expect NAME WANT GOT [OUTPUT_SUBSTRING]
  if [ "$3" = "$2" ] && { [ -z "${4:-}" ] || grep -qF -- "$4" "$ROOT/out"; }; then PASS=$((PASS + 1))
  else FAIL=$((FAIL + 1)); echo "FAIL: $1 — exit $3, want $2$( [ -n "${4:-}" ] && echo ", output to contain '$4'"): $(head -c 300 "$ROOT/out")"; fi
}
add_app() { printf '%s\n' "$2" >> "$P/app/Services/$1.php"; }   # tracked file: append a line
new_app() { printf '<?php\n%s\n' "$2" > "$P/app/Services/$1.php"; }  # untracked new file

# --- nothing to report ---
fresh
expect "no change since the cycle start"                0 "$(run)"
new_app Honest "class Honest { function ok(\$q) { return \$q >= 1; } }"
expect "an honest new file"                             0 "$(run)"

# --- the special case itself ---
fresh; new_app Cheat "class Cheat { function f(\$p) { if (\$p->sku === 'SKU-A') { return 1; } } }"
expect "untracked file: === against the test's sku"     2 "$(run)" "FIXTURE_LITERAL app/Services/Cheat.php:2 'SKU-A' also appears in tests/Feature/StockTest.php"
fresh; add_app OrderService "function g(\$p) { return \$p->sku == 'SKU-A'; }"
expect "tracked file: == against the test's sku"        2 "$(run)" "OrderService.php:3"
fresh; new_app Cheat "class Cheat { function f(\$p) { return \$p->sku !== \"SKU-A\"; } }"
expect "double-quoted literal, !=="                     2 "$(run)" "'SKU-A'"
fresh; new_app Cheat "class Cheat { function f(\$p) { return in_array(\$p->sku, ['SKU-A', 'SKU-Z']); } }"
expect "in_array with the test's value"                 2 "$(run)" "'SKU-A'"
fresh; new_app Cheat "class Cheat { function f(\$p) { return match(\$p->sku) { 'SKU-A' => 4, default => 0 }; } }"
expect "match arm keyed by the test's value"            2 "$(run)" "'SKU-A'"
fresh; new_app Cheat "class Cheat { function f(\$p) { switch (\$p->sku) { case 'SKU-A': return 1; } } }"
expect "case keyed by the test's value"                 2 "$(run)" "'SKU-A'"
fresh; new_app Cheat "class Cheat { function f(\$q) { return Product::where('sku', 'SKU-A')->first(); } }"
expect "->where against the test's value"               2 "$(run)" "'SKU-A'"
fresh; new_app Cheat "class Cheat { function f(\$n) { return \$n === 'Weekly report'; } }"
expect "a multi-word literal"                           2 "$(run)" "'Weekly report'"

# --- legitimate code must not be flagged ---
fresh; new_app Ok "class Ok { function f(\$o) { return \$o->status === 'placed'; } }"
expect "a word of the spec (and already in the code)"   0 "$(run)"
fresh; add_app OrderService "function h(\$o) { return \$o->status !== 'placed'; }"
expect "a status word that already existed"             0 "$(run)"
fresh; new_app Ok "class Ok { function f() { return ['sku' => 'SKU-A']; } }"
expect "the value only appears as data, no comparison" 0 "$(run)"
fresh; new_app Ok "class Ok { function f(\$p) { return \$p->sku === 'SKU-B'; } }"
expect "a literal that is not in the tests"             0 "$(run)"
fresh; printf 'The sku SKU-A is the standard part.\n' >> "$P/docs/product/use-cases.md"; (cd "$P" && bash "$SNAPSHOT" record >/dev/null 2>&1)
new_app Ok "class Ok { function f(\$p) { return \$p->sku === 'SKU-A'; } }"
expect "the value is named by the approved spec"        0 "$(run)"
fresh; mkdir -p "$P/tests/Unit"; printf '<?php\nif ($x === "SKU-A") {}\n' > "$P/tests/Unit/NewTest.php"
expect "added lines under tests/ are not application"   0 "$(run)"
fresh; printf '%s\n' '$p->sku === "SKU-A"' > "$P/README.md"
expect "added lines outside the application paths"      0 "$(run)"

# --- fail closed ---
fresh; rm -rf "$P/$(cd "$P" && git rev-parse --git-path claude-tdd)"
expect "no approved snapshot"                           3 "$(run)" "record"
expect "outside a git repository"                       3 "$( (cd "$ROOT" && bash "$SCRIPT" >"$ROOT/out" 2>&1; echo $?) )" "not inside a git repository"

# --- known gaps (documented in the design; this test fails when one is closed, so update it then) ---
fresh; new_app Gap "class Gap { function f(\$p) { return \$p->sku === 'SKU-' . 'A'; } }"
expect "KNOWN GAP: a literal split across a concatenation" 0 "$(run)"
fresh; mkdir -p "$P/app/Services"; printf '<?php
class Gap {
  const FIX = %s;
  function f($p) { return $p->sku === self::FIX; }
}
' "'SKU-A'" > "$P/app/Services/Gap.php"
expect "KNOWN GAP: the value hidden behind a constant"   0 "$(run)"

echo "fixture-literal-check tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
