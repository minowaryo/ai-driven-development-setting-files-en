# traceability-matrix.md — Harness Scripts

> Template-internal (`APPLY_TEMPLATE.md` class X; removed in `SETUP.md`). Traces every script
> in `.claude/hooks/` to where it runs, what it costs, why it exists, and how it is tested.
> The project's own requirement ↔ use case ↔ code ↔ test matrix is
> `docs/rcid/traceability-matrix.md` (rebuilt by `/regenerate-traceability`, which never
> touches this file).
> Update the rows in the same commit that adds or changes a script.

## Scripts

| Script | Role | Runs from | How often | Cost per run | Decision | Test |
|---|---|---|---|---|---|---|
| `agent-guard.sh` | Stops `tdd-implementer` from writing `tests/` / `docs/product/`, the cycle's record (`logs/`, the approved snapshot) and from git commands that change the index | PreToolUse hook in `.claude/settings.json` (Write, Edit, MultiEdit, NotebookEdit, Bash, PowerShell) | Every matching tool call, in every session | ~70 ms (≈40 ms of it is bash startup); prints nothing when it allows. The 2026-10-07 evidence lock measured no slower than before (same-machine A/B) | ADR-0016 Stage 1 item 3 (+ 2026-10-07 amendment) | `meta/tests/agent-guard.test.sh` |
| `tdd-snapshot.sh` | Copies `tests/` + `docs/product/` at Gate 4 approval; diffs them after Green; prints the implementer's blocked attempts since approval from `logs/audit.jsonl` | `/tdd` Step 2 (`record`), Step 4 (`verify`) | Twice per `/tdd` cycle | `record` 0.6–0.9 s, `verify` 0.4–0.5 s (100–500 test files); the denial report adds ≈0.2 s to `verify` (2,000-line log, 2026-10-07) | ADR-0016 Stage 1 item 5 (+ 2026-10-07 amendment) | `meta/tests/tdd-snapshot.test.sh` |
| `review-score.sh` | Scores the branch diff: review level + pre-merge tier | `/review` Step 0; `prepare-merge` step 2 | Each `/review` and each merge | ~1.1 s | ADR-0009; ADR-0015 | `meta/tests/review-score.test.sh` |
| `domain-boundary-check.sh` | Flags Controllers that cross the Domain Boundary | `/review` Step 0; `prepare-merge` step 2; `/onboard-existing-codebase` (`--audit-all`) | Each `/review`, each merge, once at onboarding | ~0.4 s per branch; ~2.9 s per 54,000 lines with `--audit-all` | ADR-0010 (+ 2026-10-03 notes); ADR-0015 note | `meta/tests/domain-boundary-check.test.sh` |
| `spec-lint.sh` | Structure check of requirements / use cases / mockups (EN and JP templates) | The AI, before Gate 1 / Gate 2 / the Gate 0-3 sign-off (`CLAUDE.md`, `AGENTS.md`, `SETUP.md` Steps 2 / 2B, `/onboard-existing-codebase`) | A few times per project | ~1 s | ADR-0018 | `meta/tests/spec-lint.test.sh` |

Costs: Windows Git Bash, measured 2026-10-05. None of these scripts calls an AI model, so
none costs tokens except the lines it prints.

## Sync

Byte-identical (ignoring line endings) across the sibling repositories, checked 2026-10-05.
JP = `ai-driven-development-setting-files`, Company = `ai-driven-development-setting-files-en-company`.

| Script | Added (EN) | Last change (EN) | JP | Company |
|---|---|---|---|---|
| `agent-guard.sh` | `6c9921b` | `c3db263` | Not ported (ADR-0016 Stage 4) | Behind EN (evidence lock not ported) |
| `tdd-snapshot.sh` | `6c9921b` | `c3db263` | Not ported (ADR-0016 Stage 4) | Behind EN (denial report not ported) |
| `review-score.sh` | `550a640` | `3b0216a` | Identical | Identical |
| `domain-boundary-check.sh` | `37457db` | `a5c2029` | Identical | Identical |
| `spec-lint.sh` | `434adb7` | `eceb033` | Identical | Identical |
