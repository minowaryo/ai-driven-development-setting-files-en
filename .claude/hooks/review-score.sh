#!/usr/bin/env bash
# review-score.sh — Step 0 of /review.
# Scores everything changed since the current branch diverged from `main` — commits on
# the branch plus staged, unstaged, and untracked work in the working tree — so /review
# can pick "normal" vs "enhanced" depth without manual judgment.
# No state file, no AI calls: pure local git commands.
#
# Environment:
#   REVIEW_SCORE_BASE_BRANCH  base branch (default: main; falls back to origin/<base>)
#   REVIEW_SCORE_THRESHOLD    score at or above which the enhanced level is recommended (default: 30)
set -euo pipefail

BASE_BRANCH="${REVIEW_SCORE_BASE_BRANCH:-main}"
THRESHOLD="${REVIEW_SCORE_THRESHOLD:-30}"

FILE_WEIGHT=1
LINE_WEIGHT=0.05
SENSITIVE_WEIGHT=15

# Adjust to the project's own sensitive areas (migrations, authz, payments, do-not-touch, etc.)
SENSITIVE_PATTERNS=(
  'database/migrations/'
  'app/Policies/'
  'app/Http/Middleware/'
  'config/auth\.php'
  'app/Http/Controllers/Auth/'
  'docs/ai-context/do-not-touch\.md'
)

skip() {
  echo "[review-score] $1; skipping score calculation."
  echo "RECOMMENDATION=normal"
  exit 0
}

TOPLEVEL=$(git rev-parse --show-toplevel 2>/dev/null) || skip "not a git repository"
# Paths below are repo-relative; running from a subdirectory would otherwise miss them.
cd "$TOPLEVEL"

# CI and fresh clones often have only the remote-tracking branch.
if ! git rev-parse --verify --quiet "$BASE_BRANCH" >/dev/null; then
  if git rev-parse --verify --quiet "origin/$BASE_BRANCH" >/dev/null; then
    BASE_BRANCH="origin/$BASE_BRANCH"
  else
    skip "base branch '$BASE_BRANCH' not found"
  fi
fi

# Unrelated histories and some shallow clones have no merge base.
MERGE_BASE=$(git merge-base "$BASE_BRANCH" HEAD 2>/dev/null || true)
[ -n "$MERGE_BASE" ] || skip "no merge base with '$BASE_BRANCH'"

# Diff the merge base against the working tree (not HEAD): /tdd leaves its changes
# uncommitted, so a commits-only range would score the usual flow as zero.
TRACKED_FILES=$(git -c core.quotePath=false diff --name-only "$MERGE_BASE")
UNTRACKED_FILES=$(git -c core.quotePath=false ls-files --others --exclude-standard)
CHANGED_FILES=$(printf '%s\n%s\n' "$TRACKED_FILES" "$UNTRACKED_FILES" | sed '/^$/d')
FILE_COUNT=$(printf '%s' "$CHANGED_FILES" | awk 'END {print NR}')

read -r ADDED DELETED <<<"$(git diff --numstat "$MERGE_BASE" | awk '{a+=$1; d+=$2} END {print a+0, d+0}')"
# Untracked files count as fully added.
if [ -n "$UNTRACKED_FILES" ]; then
  UNTRACKED_LINES=$(git ls-files --others --exclude-standard -z | xargs -0 cat -- 2>/dev/null | wc -l | tr -d ' ')
  ADDED=$((ADDED + UNTRACKED_LINES))
fi
LINE_COUNT=$((ADDED + DELETED))

SENSITIVE_MATCHES=()
if [ -n "$CHANGED_FILES" ]; then
  while IFS= read -r file; do
    for pattern in "${SENSITIVE_PATTERNS[@]}"; do
      if echo "$file" | grep -qE "$pattern"; then
        SENSITIVE_MATCHES+=("$file")
        break
      fi
    done
  done <<<"$CHANGED_FILES"
fi
SENSITIVE_COUNT=${#SENSITIVE_MATCHES[@]}

SCORE=$(awk -v f="$FILE_COUNT" -v l="$LINE_COUNT" -v s="$SENSITIVE_COUNT" \
  -v fw="$FILE_WEIGHT" -v lw="$LINE_WEIGHT" -v sw="$SENSITIVE_WEIGHT" \
  'BEGIN { printf "%.0f", f*fw + l*lw + s*sw }')

echo "[review-score] base: $BASE_BRANCH (merge-base: ${MERGE_BASE:0:7})"
echo "  Files changed   : $FILE_COUNT"
echo "  Lines changed   : $LINE_COUNT (+$ADDED / -$DELETED)"
if [ "$SENSITIVE_COUNT" -gt 0 ]; then
  echo "  Sensitive paths matched:"
  for f in "${SENSITIVE_MATCHES[@]}"; do
    echo "    - $f"
  done
else
  echo "  Sensitive paths matched: none"
fi
echo "  Score           : $SCORE (threshold: $THRESHOLD)"
echo

if [ "$SCORE" -ge "$THRESHOLD" ]; then
  echo "  >> Large/risky change detected. Run the enhanced review level (broader coverage + adversarial re-check)."
  echo "RECOMMENDATION=enhanced"
else
  echo "  >> Normal review level is sufficient."
  echo "RECOMMENDATION=normal"
fi
