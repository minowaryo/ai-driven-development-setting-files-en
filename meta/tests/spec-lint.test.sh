#!/usr/bin/env bash
# Tests for .claude/hooks/spec-lint.sh (structural checks on the spec documents).
# Template-internal: APPLY_TEMPLATE.md class X — never copied into target projects.
# Builds throwaway fixture directories under mktemp; touches nothing in this repository.
# Usage: bash meta/tests/spec-lint.test.sh [path/to/spec-lint.sh]
set -u

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPT="${1:-$REPO/.claude/hooks/spec-lint.sh}"
ROOT=$(mktemp -d)
trap 'rm -rf "$ROOT"' EXIT
PASS=0
FAIL=0

REQ_OK='# requirements.md

## 4. Feature List

| Feature ID | Feature Name | Summary | Actor | Priority |
|---|---|---|---|---|
| F-001 | Order list | Staff browse orders | Staff | High |
| F-002 | Order export | Staff export orders as CSV | Staff | Medium |

## Quality Gate

Once this document is approved, proceed to use cases.'

uc() { # uc ID TITLE FEATURE -> a complete use case
  cat <<EOF
### $1: $2

**Actor**: Staff
**Preconditions**: Logged in
**Related requirement**: $3

#### Basic Flow
1. Staff opens the page
2. System shows the result

#### Inputs
| Field | Type | Required | Validation |
|---|---|---|---|
| status | string | Optional | one of open, closed |

#### Error Cases
| Case | HTTP Status | Message |
|---|---|---|
| Not logged in | 401 | Please log in |

#### Permissions
- Staff: Allowed
- Guest: Not allowed (401)

---

EOF
}

UC_HEAD='# use-cases.md

## Review Criteria

- [ ] Is the Actor clearly defined?

## Use Case Template

'

UC_TAIL='## Approval Record

| Date | Reviewer | Result | Comment |
|---|---|---|---|
| YYYY-MM-DD | [Name] | Approved / Rejected | [Comment] |'

new_dir() { # new_dir -> fixture with a clean spec set
  local d
  d=$(mktemp -d -p "$ROOT")
  mkdir -p "$d/docs/product/mockups"
  printf '%s\n' "$REQ_OK" >"$d/docs/product/requirements.md"
  { printf '%s' "$UC_HEAD"; uc UC-001 "Browse orders" F-001; uc UC-002 "Export orders" F-002; printf '%s\n' "$UC_TAIL"; } \
    >"$d/docs/product/use-cases.md"
  cat >"$d/docs/product/mockups/README.md" <<'EOF'
# Mockups

## Screen List

| File Name | UC | Screen Name | Created | Business Review | Feedback Incorporated |
|---|---|---|---|---|---|
| `screen-UC001-order-list.html` | UC-001 | Order list | 2026-10-01 | Done | Yes |
EOF
  echo '<html></html>' >"$d/docs/product/mockups/screen-UC001-order-list.html"
  echo "$d"
}

uc_file() { echo "$1/docs/product/use-cases.md"; }

run() { # run DIR [ARGS...] -> sets OUT, ERR, CODE
  local d=$1; shift
  OUT=$(cd "$d" && bash "$SCRIPT" "$@" 2>"$d/.stderr")
  CODE=$?
  ERR=$(cat "$d/.stderr")
}

check() { # check NAME CONDITION
  if eval "$2"; then
    PASS=$((PASS + 1)); echo "PASS: $1"
  else
    FAIL=$((FAIL + 1)); echo "FAIL: $1 -- expected: $2 (exit $CODE)"; echo "$OUT" | sed 's/^/    | /'
    [ -n "$ERR" ] && echo "$ERR" | sed 's/^/    ! /'
  fi
}

has() { printf '%s\n' "$OUT" | grep -qE "$1"; }
summary() { printf '%s\n' "$OUT" | tail -n 1 | grep -qx "SPEC_LINT findings=$1 warnings=$2"; }

# 1: clean set
d=$(new_dir); run "$d"
check "1 clean exit 0" '[ "$CODE" -eq 0 ]'
check "1 clean summary" 'summary 0 0'

# 2: duplicate UC id
d=$(new_dir); uc UC-001 "Again" F-001 >>"$(uc_file "$d")"; run "$d"
check "2 duplicate UC" '[ "$CODE" -eq 1 ] && has "^id .*UC-001.*duplicate"'

# 3: malformed UC heading
d=$(new_dir); printf '### UC6 Broken heading\n\n' >>"$(uc_file "$d")"; run "$d"
check "3 malformed heading" 'has "^id .*malformed"'

# 4: missing section
d=$(new_dir); f=$(uc_file "$d"); awk '!/^#### Error Cases/' "$f" >"$f.tmp" && mv "$f.tmp" "$f"; run "$d"
check "4 missing Error Cases" 'has "^section .*Error Cases.*missing"'

# 5: empty section (heading only)
d=$(new_dir); f=$(uc_file "$d")
awk '/^#### Permissions/{print; skip=1; next} skip&&/^(---|###|##)/{skip=0} !skip' "$f" >"$f.tmp" && mv "$f.tmp" "$f"; run "$d"
check "5 empty Permissions" 'has "^section .*Permissions.*empty"'

# 6: missing Actor
d=$(new_dir); f=$(uc_file "$d"); awk '!/^\*\*Actor\*\*/' "$f" >"$f.tmp" && mv "$f.tmp" "$f"; run "$d"
check "6 missing Actor" 'has "^section .*Actor.*missing"'

# 7: unknown requirement
d=$(new_dir); uc UC-003 "Ghost" F-009 >>"$(uc_file "$d")"; run "$d"
check "7 unknown F-ID" 'has "^link .*UC-003.*F-009"'

# 8: unused requirement
d=$(new_dir); f=$(uc_file "$d"); sed -i 's/^\*\*Related requirement\*\*: F-002/**Related requirement**: F-001/' "$f"; run "$d"
check "8 unused F-ID" 'has "^link .*F-002.*not referenced"'

# 9: placeholders — flagged in body, not in links / checkboxes / code / Approval Record
d=$(new_dir); f=$(uc_file "$d")
{ printf '%s' "$UC_HEAD"; uc UC-001 "[Use Case Name]" F-001; uc UC-002 "Export orders" F-002
  printf 'See [ADR-0001](../adr/ADR-0001.md) and `[not-a-placeholder]`.\n\n```\n[inside fence]\n```\n\n'
  printf '%s\n' "$UC_TAIL"; } >"$f"; run "$d"
check "9 placeholder flagged" 'has "^placeholder .*\\[Use Case Name\\]"'
check "9 link not flagged" '! has "ADR-0001"'
check "9 inline code not flagged" '! has "not-a-placeholder"'
check "9 fence not flagged" '! has "inside fence"'
check "9 approval record not flagged" '! has "\\[Name\\]|YYYY-MM-DD"'
check "9 checkbox not flagged" '! has "\\[ \\]"'
check "9 one placeholder only" 'summary 1 0'

# 9b: [inferred] markers (Existing-Codebase Path) are reported as unresolved, not as template text
d=$(new_dir); f=$(uc_file "$d"); sed -i 's/^\*\*Actor\*\*: Staff/**Actor**: Staff **[inferred]**/' "$f"; run "$d"
check "9b inferred reported" 'has "^placeholder .*unresolved \\[inferred\\]"'
check "9b not called template text" '! has "template placeholder left: \\[inferred\\]"'

# 10: TBD / TODO
d=$(new_dir); printf 'Retention period: TBD\n' >>"$d/docs/product/requirements.md"; run "$d"
check "10 TBD" 'has "^placeholder .*requirements.md.*TBD"'

# 11: wording — warn only, word boundaries, JA terms
d=$(new_dir); f=$(uc_file "$d")
sed -i 's/^2\. System shows the result/2. System shows the result appropriately, etc./' "$f"
sed -i 's/^## Approval Record/- 一覧は適切に表示する\n- The simplest inappropriate path\n\n&/' "$f"; run "$d"
check "11 exit stays 0" '[ "$CODE" -eq 0 ]'
check "11 appropriately" 'has "^wording .*appropriately"'
check "11 etc." 'has "^wording .*etc\\."'
check "11 JA term" 'has "^wording .*適切に"'
check "11 no partial words" '! has "simple\"|appropriate\""'
check "11 counts" 'summary 0 5'

# 12: requirements is a pointer (Existing-Codebase Path) — link checks skipped
d=$(new_dir); printf '# requirements.md\n\nSee use-cases.md for current behavior.\n' >"$d/docs/product/requirements.md"; run "$d"
check "12 pointer: no link findings" '! has "^link " && [ "$CODE" -eq 0 ]'
check "12 pointer: note" 'has "requirement links not checked"'

# 13: --requirements mode ignores use cases
d=$(new_dir); printf '### UC6 Broken\n' >>"$(uc_file "$d")"
printf '| F-001 | Duplicate | x | Staff | Low |\n' >>"$d/docs/product/requirements.md"; run "$d" --requirements
check "13 duplicate F-ID" 'has "^id .*F-001.*duplicate"'
check "13 use cases ignored" '! has "UC6"'

# 14: mockups
d=$(new_dir); m="$d/docs/product/mockups"
echo x >"$m/screen-UC009-ghost.html"
echo x >"$m/screen-UC002-export.png"
echo x >"$m/Order List.html"
printf '| `screen-UC002-missing.html` | UC-002 | Missing | 2026-10-01 | | |\n' >>"$m/README.md"; run "$d"
check "14 unknown UC" 'has "^mockup .*screen-UC009-ghost.html.*UC-009"'
check "14 not listed" 'has "^mockup .*screen-UC009-ghost.html.*not in the Screen List"'
check "14 listed but missing" 'has "^mockup .*screen-UC002-missing.html.*does not exist"'
check "14 png without md" 'has "^mockup .*screen-UC002-export.png.*companion"'
check "14 bad name" 'has "^mockup .*Order List.html.*naming"'
check "14 placeholder row ignored" '! has "add entries"'

# 15: CRLF line endings behave like LF
d=$(new_dir); for f in "$d"/docs/product/*.md "$d"/docs/product/mockups/README.md; do sed -i 's/$/\r/' "$f"; done; run "$d"
check "15 CRLF clean" '[ "$CODE" -eq 0 ] && summary 0 0'

# 16: the template's own (unfilled) spec documents
d=$(mktemp -d -p "$ROOT"); mkdir -p "$d/docs"; cp -r "$REPO/docs/product" "$d/docs/"; run "$d"
check "16 template flagged, no crash" '[ "$CODE" -eq 1 ] && has "^placeholder .*use-cases.md" && [ -z "$ERR" ]'

# 17: usage errors
d=$(new_dir); run "$d" --bogus
check "17 unknown option exit 2" '[ "$CODE" -eq 2 ]'

# 18: no use-cases.md yet
d=$(new_dir); rm "$(uc_file "$d")"; run "$d"
check "18 missing use-cases note" '[ "$CODE" -eq 0 ] && has "use-cases.md not found"'

# 19: run from a subdirectory of a git repository
d=$(new_dir); git -C "$d" init -q; mkdir -p "$d/app/sub"; OUT=$(cd "$d/app/sub" && bash "$SCRIPT"); CODE=$?
check "19 subdirectory uses repo root" '[ "$CODE" -eq 0 ] && summary 0 0'

# 20: Japanese templates (the JP sibling repository ships this same script)
ja_dir() { # ja_dir -> fixture written with the JP template's headings and labels
  local d
  d=$(mktemp -d -p "$ROOT")
  mkdir -p "$d/docs/product/mockups"
  cat >"$d/docs/product/requirements.md" <<'EOF'
# requirements.md — 要件定義

## 4. 機能一覧

| 機能ID | 機能名 | 概要 | Actor | 優先度 |
|---|---|---|---|---|
| F-001 | 受注一覧 | 担当者が受注を一覧する | 担当者 | 高 |
EOF
  cat >"$d/docs/product/use-cases.md" <<'EOF'
# use-cases.md — ユースケース定義

## レビュー基準

- [ ] Actor が明確か

## ユースケーステンプレート

### UC-001: 受注を一覧する

**Actor**: 担当者
**関連要件**：F-001

#### 基本フロー
1. 担当者が一覧画面を開く
2. システムが受注を表示する

#### エラーケース
| ケース | HTTPステータス | メッセージ |
|---|---|---|
| 未ログイン | 401 | ログインしてください |

#### 権限
- 担当者: 実行可

---

## 承認記録

| 日付 | レビュアー | 結果 | コメント |
|---|---|---|---|
| YYYY-MM-DD | [名前] | 承認/差し戻し | [コメント] |
EOF
  cat >"$d/docs/product/mockups/README.md" <<'EOF'
# Mockups

## 画面一覧

| ファイル名 | 対応UC | 画面名 | 作成日 | ビジネスレビュー | フィードバック反映 |
|---|---|---|---|---|---|
| *(追加してください)* | | | | | |
| `screen-UC001-order-list.html` | UC-001 | 受注一覧 | 2026-10-05 | 済 | 済 |
EOF
  echo '<html></html>' >"$d/docs/product/mockups/screen-UC001-order-list.html"
  echo "$d"
}
d=$(ja_dir); run "$d"
check "20 JA clean" '[ "$CODE" -eq 0 ] && summary 0 0'
d=$(ja_dir); f=$(uc_file "$d"); awk '!/^#### エラーケース/' "$f" >"$f.tmp" && mv "$f.tmp" "$f"; run "$d"
check "20 JA missing section" 'has "^section .*エラーケース.*missing"'
d=$(ja_dir); f=$(uc_file "$d"); sed -i 's/^\*\*関連要件\*\*：F-001/**関連要件**：F-009/' "$f"; run "$d"
check "20 JA full-width colon label" 'has "^link .*UC-001.*F-009"'

echo "----"
echo "passed: $PASS  failed: $FAIL"
[ "$FAIL" -eq 0 ]
