#!/usr/bin/env bash
# Tests for .claude/hooks/review-score.sh (MERGE_CHECK tiers + exclusions).
# Template-internal: APPLY_TEMPLATE.md class X — never copied into target projects.
# Builds throwaway git repos under mktemp; touches nothing in this repository.
# Usage: bash meta/tests/review-score.test.sh [path/to/review-score.sh]
set -u

SCRIPT="${1:-$(cd "$(dirname "$0")/../.." && pwd)/.claude/hooks/review-score.sh}"
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

lines() { # lines N FILE
  mkdir -p "$(dirname "$2")"
  yes x | head -n "$1" >"$2"
}

commit_all() { git -C "$1" add -A && git -C "$1" commit -qm change; }

run() { # run DIR [ENV...] -> sets OUT, ERR
  local d=$1; shift
  OUT=$(cd "$d" && env "$@" bash "$SCRIPT" 2>"$d/.stderr")
  ERR=$(cat "$d/.stderr")
}

check() { # check NAME CONDITION-DESCRIPTION
  if eval "$2"; then
    PASS=$((PASS + 1)); echo "PASS: $1"
  else
    FAIL=$((FAIL + 1)); echo "FAIL: $1 -- expected: $2"; echo "$OUT" | sed 's/^/    | /'
    [ -n "$ERR" ] && echo "$ERR" | sed 's/^/    ! /'
  fi
}

has() { printf '%s\n' "$OUT" | grep -qx "$1"; }
last_is_rec() { printf '%s\n' "$OUT" | tail -n 1 | grep -qE '^RECOMMENDATION=(normal|enhanced)$'; }

# 1: light
d=$(new_repo); lines 20 "$d/a.php"; commit_all "$d"; run "$d"
check "1 light" 'has MERGE_CHECK=light && has RECOMMENDATION=normal'
check "8.1 last line" last_is_rec

# 2: recommended (5 files x 40 lines = score 15)
d=$(new_repo); for i in 1 2 3 4 5; do lines 40 "$d/f$i.php"; done; commit_all "$d"; run "$d"
check "2 recommended" 'has MERGE_CHECK=recommended'
check "8.2 last line" last_is_rec
# 7: LIGHT override on the same repo
run "$d" REVIEW_SCORE_LIGHT_THRESHOLD=100
check "7 light override" 'has MERGE_CHECK=light'

# 3: required by score (20 files x 30 lines = score 50)
d=$(new_repo); for i in $(seq 1 20); do lines 30 "$d/g$i.php"; done; commit_all "$d"; run "$d"
check "3 required by score" 'has MERGE_CHECK=required && has RECOMMENDATION=enhanced'
check "8.3 last line" last_is_rec

# 4: required by sensitive path
d=$(new_repo); lines 10 "$d/database/migrations/x.php"; commit_all "$d"; run "$d"
check "4 required by sensitive" 'has MERGE_CHECK=required && has RECOMMENDATION=normal'
check "8.4 last line" last_is_rec

# 5: lock file excluded
d=$(new_repo); lines 5000 "$d/composer.lock"; lines 10 "$d/a.php"; commit_all "$d"; run "$d"
check "5 lock excluded" 'has MERGE_CHECK=light'

# 6: untracked binaries not counted, no stderr
d=$(new_repo); lines 10 "$d/a.php"; commit_all "$d"
mkdir -p "$d/storage/fonts" "$d/public/img"
head -c 200000 /dev/urandom >"$d/storage/fonts/f.ttf"
head -c 200000 /dev/urandom >"$d/public/img/logo.png"
run "$d"
check "6 untracked binaries" 'has MERGE_CHECK=light'
check "6 no stderr" '[ -z "$ERR" ]'
check "8.6 last line" last_is_rec

# 9: outside a git repo
d=$(mktemp -d -p "$ROOT"); run "$d"
check "9 skip path tier (fail safe)" 'has MERGE_CHECK=required'
check "9 skip path last line" '[ "$(printf "%s\n" "$OUT" | tail -n 1)" = "RECOMMENDATION=normal" ]'

# 10: untracked nested repo / directory must not crash the script
d=$(new_repo); lines 10 "$d/a.php"; commit_all "$d"
git -C "$d" init -q "$d/sub"; echo y >"$d/sub/y.txt"
run "$d"
check "10 nested repo: light" 'has MERGE_CHECK=light'
check "10 nested repo: last line" last_is_rec

# 11: untracked text file of blank lines is text, not binary (300 lines -> score 16)
d=$(new_repo); yes '' | head -n 300 >"$d/blank.txt"; run "$d"
check "11 blank-line text counted" 'has MERGE_CHECK=recommended'

# 12: untracked filename with a space is counted (300 lines -> score 16)
d=$(new_repo); lines 300 "$d/my file.php"; run "$d"
check "12 filename with space counted" 'has MERGE_CHECK=recommended'

# 13: resources/views/vendor is hand-edited Laravel code, not excluded (400 lines -> score 21)
d=$(new_repo); lines 400 "$d/resources/views/vendor/mail/x.blade.php"; commit_all "$d"; run "$d"
check "13 views/vendor counted" 'has MERGE_CHECK=recommended'

# 14: root vendor/ is still excluded
d=$(new_repo); lines 5000 "$d/vendor/pkg/x.php"; lines 10 "$d/a.php"; commit_all "$d"; run "$d"
check "14 root vendor excluded" 'has MERGE_CHECK=light'

# 15: committed binary is left out of the counts
d=$(new_repo); mkdir -p "$d/public/img"; head -c 200000 /dev/urandom >"$d/public/img/logo.png"
lines 10 "$d/a.php"; commit_all "$d"; run "$d"
check "15 committed binary excluded" 'has MERGE_CHECK=light'

# 16/17: threshold boundaries (empty tracked files: score = file count)
d=$(new_repo); for i in $(seq 1 10); do : >"$d/e$i.php"; done; commit_all "$d"; run "$d"
check "16 score 10 is recommended" 'has MERGE_CHECK=recommended && has RECOMMENDATION=normal'
d=$(new_repo); for i in $(seq 1 30); do : >"$d/e$i.php"; done; commit_all "$d"; run "$d"
check "17 score 30 is required+enhanced" 'has MERGE_CHECK=required && has RECOMMENDATION=enhanced'

# 18: missing base branch fails safe
d=$(new_repo); lines 10 "$d/a.php"; commit_all "$d"; run "$d" REVIEW_SCORE_BASE_BRANCH=develop
check "18 missing base: required" 'has MERGE_CHECK=required'
check "18 missing base: last line normal" '[ "$(printf "%s\n" "$OUT" | tail -n 1)" = "RECOMMENDATION=normal" ]'

# 19: sensitive path in an untracked file forces required
d=$(new_repo); lines 1 "$d/app/Policies/OrderPolicy.php"; run "$d"
check "19 untracked sensitive: required" 'has MERGE_CHECK=required'

echo "== $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
