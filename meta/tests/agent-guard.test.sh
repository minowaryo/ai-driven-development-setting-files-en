#!/usr/bin/env bash
# Tests for .claude/hooks/agent-guard.sh (ADR-0016 Stage 1, item 3: tdd-implementer cannot
# move the goal). Feeds PreToolUse payloads on stdin and checks the exit code and the
# denial log. Template-internal: APPLY_TEMPLATE.md class X — never copied into target projects.
# Builds throwaway fixture directories under mktemp; touches nothing in this repository.
# Usage: bash meta/tests/agent-guard.test.sh [path/to/agent-guard.sh]
set -u

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPT="${1:-$REPO/.claude/hooks/agent-guard.sh}"
ROOT=$(mktemp -d)
trap 'rm -rf "$ROOT"' EXIT
PASS=0
FAIL=0

# A project directory as the hook sees it (cwd in the payload). Windows form, JSON-escaped.
PROJ="$ROOT/proj"
mkdir -p "$PROJ"
WIN_CWD='C:\\work\\app'

# payload AGENT TOOL INPUT_JSON [CWD]: AGENT "" = main session (no agent fields)
payload() {
  local agent=$1 tool=$2 input=$3 cwd=${4:-$WIN_CWD} fields=''
  [ -n "$agent" ] && fields="\"agent_id\":\"a123\",\"agent_type\":\"$agent\","
  printf '{"session_id":"s-1","transcript_path":"C:\\\\t.jsonl","cwd":"%s",%s"hook_event_name":"PreToolUse","tool_name":"%s","tool_input":%s}' \
    "$cwd" "$fields" "$tool" "$input"
}

# expect NAME WANT_EXIT PAYLOAD
expect() {
  local name=$1 want=$2 got
  (cd "$PROJ" && printf '%s' "$3" | bash "$SCRIPT" >/dev/null 2>"$ROOT/err")
  got=$?
  if [ "$got" = "$want" ]; then PASS=$((PASS + 1))
  else FAIL=$((FAIL + 1)); echo "FAIL: $name — exit $got, want $want ($(head -c 200 "$ROOT/err"))"; fi
}

W() { printf '{"file_path":"%s","content":"x"}' "$1"; }
B() { printf '{"command":"%s","description":"d"}' "$1"; }
IMPL=tdd-implementer

# --- locked paths, file tools ---
expect "Write tests/ (Windows absolute)"        2 "$(payload $IMPL Write "$(W 'C:\\work\\app\\tests\\Feature\\FooTest.php')")"
expect "Edit tests/ (relative)"                 2 "$(payload $IMPL Edit "$(W 'tests/Unit/BarTest.php')")"
expect "Write docs/product/use-cases.md"        2 "$(payload $IMPL Write "$(W 'C:\\work\\app\\docs\\product\\use-cases.md')")"
expect "Write /c/ form"                         2 "$(payload $IMPL Write "$(W '/c/work/app/tests/x.php')")"
expect "Write c:/ form, other case"             2 "$(payload $IMPL Write "$(W 'c:/Work/App/Tests/X.php')")"
expect "Write via .. into tests/"               2 "$(payload $IMPL Write "$(W 'app/../tests/x.php')")"
expect "MultiEdit tests/"                       2 "$(payload $IMPL MultiEdit "$(W 'tests/x.php')")"
expect "NotebookEdit tests/"                    2 "$(payload $IMPL NotebookEdit '{"notebook_path":"tests/n.ipynb"}')"

# --- allowed for the implementer ---
expect "Write app/"                             0 "$(payload $IMPL Write "$(W 'C:\\work\\app\\app\\Services\\Order.php')")"
expect "Write a dir merely named *tests*"       0 "$(payload $IMPL Write "$(W 'app/Support/contests/x.php')")"
expect "Write docs/development/"                0 "$(payload $IMPL Write "$(W 'docs/development/notes.md')")"
expect "Bash run the tests"                     0 "$(payload $IMPL Bash "$(B 'php artisan test tests/Feature/FooTest.php 2>&1')")"
expect "Bash pest with redirect to /dev/null"   0 "$(payload $IMPL Bash "$(B 'vendor/bin/pest tests/Unit > /dev/null')")"
expect "Bash read a test"                       0 "$(payload $IMPL Bash "$(B 'cat tests/Feature/FooTest.php')")"
expect "Bash git status / diff / log"           0 "$(payload $IMPL Bash "$(B 'git status && git diff && git log -3')")"
expect "Read tests/ (not a write tool)"         0 "$(payload $IMPL Read '{"file_path":"tests/x.php"}')"

# --- Bash writes into locked paths ---
expect "Bash redirect into tests/"              2 "$(payload $IMPL Bash "$(B 'echo x > tests/a.txt')")"
expect "Bash append into docs/product/"         2 "$(payload $IMPL Bash "$(B 'echo x >> docs/product/use-cases.md')")"
expect "Bash sed -i on a test"                  2 "$(payload $IMPL Bash "$(B 'sed -i s/5/1/ tests/Feature/FooTest.php')")"
expect "Bash cp over a test"                    2 "$(payload $IMPL Bash "$(B 'cp /tmp/x.php tests/Feature/FooTest.php')")"
expect "Bash rm a test"                         2 "$(payload $IMPL Bash "$(B 'rm tests/Feature/FooTest.php')")"
expect "Bash php -r file_put_contents"          2 "$(payload $IMPL Bash "$(B "php -r 'file_put_contents(\\\"tests/x.php\\\", 1);'")")"
expect "Bash tee into tests/"                   2 "$(payload $IMPL Bash "$(B 'echo x | tee tests/a.txt')")"

# --- git commands that change the index, the tree or the config ---
expect "git add -A"                             2 "$(payload $IMPL Bash "$(B 'git add -A')")"
expect "git -C dir add"                         2 "$(payload $IMPL Bash "$(B 'git -C . add app/')")"
expect "git commit"                             2 "$(payload $IMPL Bash "$(B 'git commit -m wip')")"
expect "git stash"                              2 "$(payload $IMPL Bash "$(B 'git stash')")"
expect "git checkout -- tests"                  2 "$(payload $IMPL Bash "$(B 'git checkout -- tests')")"
expect "git restore"                            2 "$(payload $IMPL Bash "$(B 'git restore app/x.php')")"
expect "git reset"                              2 "$(payload $IMPL Bash "$(B 'git reset --hard')")"
expect "git config filter"                      2 "$(payload $IMPL Bash "$(B 'git config filter.x.clean cat')")"
expect "git -c ... add"                         2 "$(payload $IMPL Bash "$(B 'git -c core.x=1 add .')")"
expect "chained: test && git add"               2 "$(payload $IMPL Bash "$(B 'php artisan test && git add .')")"

# --- not the implementer: nothing is blocked ---
expect "main session Write tests/"              0 "$(payload '' Write "$(W 'tests/x.php')")"
expect "main session git add"                   0 "$(payload '' Bash "$(B 'git add -A')")"
expect "test-writer Write tests/"               0 "$(payload test-writer Write "$(W 'tests/Feature/NewTest.php')")"
expect "other agent edits docs/product/"        0 "$(payload general-purpose Write "$(W 'docs/product/user-guide.md')")"

# --- the agent name inside written content must not trigger a block ---
expect "main session writes text naming the implementer" 0 \
  "$(payload '' Write '{"file_path":"tests/x.txt","content":"\"agent_type\":\"tdd-implementer\""}')"

# --- fail closed: unparsable payload that mentions the implementer ---
expect "garbled payload naming the implementer" 2 '{"agent_type":"tdd-implementer" garbled'
expect "empty input"                            0 ''

# --- denial log ---
rm -rf "$PROJ/logs"
(cd "$PROJ" && payload $IMPL Write "$(W 'tests/x.php')" | bash "$SCRIPT" >/dev/null 2>&1)
if [ -f "$PROJ/logs/audit.jsonl" ] \
   && [[ $(<"$PROJ/logs/audit.jsonl") == *'"event":"agent_guard_denial"'*'"session_id":"s-1"'*'"agent_type":"tdd-implementer"'* ]] \
   && [[ $(<"$PROJ/logs/audit.jsonl") != *'"content"'* ]]; then
  PASS=$((PASS + 1))
else
  FAIL=$((FAIL + 1)); echo "FAIL: denial log line missing or malformed: $(cat "$PROJ/logs/audit.jsonl" 2>/dev/null)"
fi
(cd "$PROJ" && payload '' Write "$(W 'tests/x.php')" | bash "$SCRIPT" >/dev/null 2>&1)
lines=$(wc -l < "$PROJ/logs/audit.jsonl")
if [ "$lines" -eq 1 ]; then PASS=$((PASS + 1)); else FAIL=$((FAIL + 1)); echo "FAIL: allowed call wrote a log line ($lines lines)"; fi

# --- deny message is factual and names the legitimate way out ---
msg=$( (cd "$PROJ" && payload $IMPL Write "$(W 'tests/x.php')" | bash "$SCRIPT" 2>&1 >/dev/null) )
if [[ $msg == *"Gate 4"* && $msg == *SPEC_CONFLICT* ]]; then PASS=$((PASS + 1))
else FAIL=$((FAIL + 1)); echo "FAIL: deny message lacks Gate 4 / SPEC_CONFLICT pointer: $msg"; fi

echo "agent-guard tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
