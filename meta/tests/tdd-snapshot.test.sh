#!/usr/bin/env bash
# Tests for .claude/hooks/tdd-snapshot.sh (ADR-0016 Stage 1, item 5: the approved snapshot).
# Template-internal: APPLY_TEMPLATE.md class X — never copied into target projects.
# Builds throwaway git repositories under mktemp; touches nothing in this repository.
# Usage: bash meta/tests/tdd-snapshot.test.sh [path/to/tdd-snapshot.sh]
set -u

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPT="${1:-$REPO/.claude/hooks/tdd-snapshot.sh}"
ROOT=$(mktemp -d)
trap 'rm -rf "$ROOT"' EXIT
PASS=0
FAIL=0

fresh() { # a new project with one test and one use case
  P="$ROOT/p$RANDOM$RANDOM"
  mkdir -p "$P/tests/Feature" "$P/docs/product" "$P/app"
  git -C "$P" init -q
  git -C "$P" config core.autocrlf false
  printf 'assertSame(100, $q);\n' > "$P/tests/Feature/OrderTest.php"
  printf 'Quantity is an integer from 1 to 100.\n' > "$P/docs/product/use-cases.md"
}
run() { (cd "$P" && bash "$SCRIPT" "$@" >"$ROOT/out" 2>&1); echo $?; }
expect() { # expect NAME WANT GOT [OUTPUT_SUBSTRING]
  if [ "$3" = "$2" ] && { [ -z "${4:-}" ] || grep -qF -- "$4" "$ROOT/out"; }; then PASS=$((PASS + 1))
  else FAIL=$((FAIL + 1)); echo "FAIL: $1 — exit $3, want $2$( [ -n "${4:-}" ] && echo ", output to contain '$4'"): $(head -c 300 "$ROOT/out")"; fi
}

fresh
expect "verify without a snapshot"            3 "$(run verify)" "record"
expect "record"                               0 "$(run record)" "2 files"
expect "verify, nothing changed"              0 "$(run verify)" "unchanged"

printf 'assertNotNull($q);\n' > "$P/tests/Feature/OrderTest.php"
expect "a test was weakened"                  2 "$(run verify)" "assertNotNull"

fresh; run record >/dev/null
printf 'Quantity is an integer from 1 to 99.\n' > "$P/docs/product/use-cases.md"
expect "the spec was edited"                  2 "$(run verify)" "1 to 99"

fresh; run record >/dev/null
printf 'x\n' > "$P/tests/Feature/NewTest.php"
expect "a test file was added"                2 "$(run verify)" "NewTest.php"

fresh; run record >/dev/null
rm "$P/tests/Feature/OrderTest.php"
expect "a test file was deleted"              2 "$(run verify)" "OrderTest.php"

fresh; run record >/dev/null
printf 'echo 1;\n' > "$P/app/Order.php"
expect "only app/ changed"                    0 "$(run verify)" "unchanged"

# A clean filter makes git see the tampered file as the approved one; a plain copy does not.
fresh; run record >/dev/null
printf 'assertTrue(true);\n' > "$P/tests/Feature/OrderTest.php"
git -C "$P" config filter.fake.clean "sed 's/assertTrue(true)/assertSame(100, \$q)/'"
printf 'tests/** filter=fake\n' > "$P/.gitattributes"
git -C "$P" add -A >/dev/null 2>&1
expect "tamper hidden by a clean filter + git add" 2 "$(run verify)" "assertTrue"

# A new approval replaces the snapshot.
fresh; run record >/dev/null
printf 'assertSame(99, $q);\n' > "$P/tests/Feature/OrderTest.php"
run record >/dev/null
expect "re-record after a new approval"       0 "$(run verify)" "unchanged"

# The snapshot lives inside .git/, never in the working tree.
fresh; run record >/dev/null
snapdir="$P/$(git -C "$P" rev-parse --git-path claude-tdd)/approved"
if [ -f "$snapdir/tests/Feature/OrderTest.php" ] \
   && [ -z "$(git -C "$P" status --porcelain --ignored | grep -v -e '^?? app/' -e '^?? docs/' -e '^?? tests/')" ]; then PASS=$((PASS + 1))
else FAIL=$((FAIL + 1)); echo "FAIL: record left files in the working tree: $(git -C "$P" status --porcelain --ignored)"; fi

# Projects without docs/product/ still work.
fresh; rm -rf "$P/docs"
expect "record without docs/product/"         0 "$(run record)"
expect "verify without docs/product/"         0 "$(run verify)" "unchanged"

# Blocked attempts come from the log, not from the implementer's report (2026-10-07).
unset CLAUDE_PROJECT_DIR
DENIAL='{"ts":"t","event":"agent_guard_denial","session_id":"s","agent_type":"tdd-implementer","tool":"Edit","rule":"locked_path","target":"tests/Feature/OrderTest.php"}'
fresh; mkdir -p "$P/logs"; printf '%s\n' "${DENIAL/OrderTest/OldTest}" > "$P/logs/audit.jsonl"
run record >/dev/null
expect "denials before approval are not reported" 0 "$(run verify)" "No blocked attempts"
printf '%s\n{"ts":"t","event":"other"}\n' "$DENIAL" >> "$P/logs/audit.jsonl"
expect "a denial since approval is printed verbatim" 0 "$(run verify)" '"target":"tests/Feature/OrderTest.php"'
expect "and counted (other events are not)"   0 "$(run verify)" "blocked 1 time(s)"
if ! grep -qF OldTest "$ROOT/out"; then PASS=$((PASS + 1)); else FAIL=$((FAIL + 1)); echo "FAIL: a pre-approval denial was reported"; fi
: > "$P/logs/audit.jsonl"
expect "a log that shrank is a change"        2 "$(run verify)" "shorter than at Gate 4 approval"

fresh; run record >/dev/null
mkdir -p "$P/logs"; printf '%s\n' "$DENIAL" > "$P/logs/audit.jsonl"
expect "log created after approval"           0 "$(run verify)" "blocked 1 time(s)"

fresh; run record >/dev/null
expect "no log at all"                        0 "$(run verify)" "No blocked attempts"
rm "$P/$(git -C "$P" rev-parse --git-path claude-tdd)/approved/.log-offset"
expect "snapshot from before this check"      0 "$(run verify)" "skipped"

expect "usage error"                          3 "$(run bogus)" "usage"

echo "tdd-snapshot tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
