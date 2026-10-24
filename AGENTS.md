# AGENTS.md

## Project

Laravel + MySQL web application

## Required read order (start every task with these)

1. `docs/ai-context/project-summary.md`
2. `docs/ai-context/glossary.md`
3. `docs/ai-context/module-map.md`
4. `docs/ai-context/common-commands.md`
5. Relevant file(s) below depending on the task

## Task-based reading

| Task | Read |
|---|---|
| Creating / updating requirements.md or use-cases.md | `docs/original-docs/` (source materials) + `docs/product/requirements.md`; before asking for approval, run `bash .claude/hooks/spec-lint.sh` (`--requirements` before Gate 1) |
| Requirements / UC reference | `docs/product/requirements.md` + `docs/product/use-cases.md` |
| Code implementation | `docs/product/use-cases.md` + `docs/architecture/data-model.md` + `docs/product/mockups/` |
| UI implementation / mock-based dev | `docs/product/ui-guidelines.md` + `docs/product/mockups/` |
| Frontend changes | `.claude/rules/15-frontend.md` (rules for whichever stack was selected via `meta/adr/ADR-0005-frontend-stack.md`) |
| Changing what the AI may do without asking | `docs/development/ai-authority.md` |
| Auth changes | `docs/architecture/authz-authn.md` |
| DB changes | `docs/architecture/data-model.md` + `docs/adr/` |
| Test changes | `docs/development/testing-strategy.md` + `docs/product/use-cases.md` + `docs/architecture/data-model.md` |
| Architecture changes | `docs/adr/` (all relevant ADRs) |
| Security changes | `docs/security/secrets-handling.md` |
| Change request | `docs/rcid/traceability-matrix.md` |

## Quality gates

| Gate | Condition | Unlocks |
|---|---|---|
| Gate 0 | `docs/ai-context/` filled in AND a frontend stack selection ADR exists (see `meta/adr/ADR-0005-frontend-stack.md`) | AI assistance starts |
| Gate 1 | `docs/product/requirements.md` approved | use-cases.md drafting + mock generation |
| Gate 2 ★ | `docs/product/use-cases.md` final approval | **Code generation** + data-model drafting |
| Gate 3 | `docs/architecture/data-model.md` approved | DB implementation + migrations |
| Gate 4 | Failing test case(s) reviewed and approved by a human (per-feature, repeats every cycle — unlike Gate 0-3 which pass once) | Implementation (Green phase) |

> **Existing-codebase adoption**: adding this harness to a project with existing code
> satisfies Gates 0-3 via one consolidated review instead of four separate approvals — see
> `SETUP.md`'s Existing-Codebase Path and `meta/adr/ADR-0011-existing-codebase-adoption.md`.

**Do not generate code before Gate 2 is passed.**
**Do not write implementation code before Gate 4 is passed**: write a failing test first, stop, and wait for human approval before implementing. See `.claude/rules/30-testing.md`.

## Rules

- Do **not** read the entire docs tree unless explicitly needed
- Read only files relevant to the current task
- Do not generate code until `docs/product/use-cases.md` is approved (Gate 2)
- Mock creation (`/generate-mock`) is allowed after Gate 1 — do not wait for Gate 3
- Before any architecture change, check `docs/adr/`
- Frontend stack must be selected per the criteria in `meta/adr/ADR-0005-frontend-stack.md` and recorded as a project ADR (in `docs/adr/`) — this is part of Gate 0, not optional
- Do not change env / secret handling casually
- Do not introduce schema-breaking migration without a migration plan
- Do not bypass authorization layer (Policy / Gate)
- Do not edit unrelated files
- `docs/original-docs/` is read-only — never edit, delete, or create files in it, except its own `README.md`
- Test case names must be derived from use-cases.md UC titles
- Follow Red → Gate 4 approval → Green → Refactor for new features, not just bug fixes (`.claude/rules/30-testing.md`; steps in "TDD cycle" below)
- Do not ask before local work inside an agreed task (reading, builds, tests, checks against mocks, the task's doc updates) — run it and report; ask before user-facing behavior changes, shared environments, and commits / merges / pushes (`.claude/rules/00-global.md`, "Work That Needs No Approval")

## TDD cycle

Codex has no `/tdd` command. When asked to run a TDD cycle for a use case, read
`.claude/commands/tdd.md` and `.claude/rules/30-testing.md` and follow its Steps 0-8, with these
differences — Codex runs without the sub-agents and the `agent-guard.sh` hook that Claude Code has:

- **One session plays each role in turn.** Step 1 follows `.claude/agents/test-writer.md`;
  Step 3 follows `.claude/agents/tdd-implementer.md`. Stop at Gate 4 (Step 2) and wait for the
  person's approval, then — after Step 2's working-tree check against the Step 0 baseline — run
  `bash .claude/hooks/tdd-snapshot.sh record` and show its line.
- **Nothing blocks your writes.** From Gate 4 approval to the Step 8 report, do not write to
  `tests/`, `docs/product/`, `logs/audit.jsonl` or `.git/claude-tdd/`, and run no git command
  that changes the index, working tree, history or config. If a test or the spec looks wrong,
  stop and report `SPEC_CONFLICT` as `tdd-implementer.md` describes. The Step 4 and Step 7
  checks are the only machine stops here, so never skip them.
- **Attempt limit**: no counter runs. Stop after 3 Green attempts, or when the same failure
  appears twice, and report; this replaces Step 3's run and call limits.
- **Step 4 output**: `verify` prints a `WARNING: agent-guard.sh counted no …` line and finds no
  blocked attempts, because the hook does not run under Codex. Show them as printed and add
  "agent-guard.sh does not run under Codex".
- **Cycle review**: there is no `cycle-reviewer`; do not review your own change in its place.
  Say "Cycle review unavailable — please run `/review` before merging" and continue. Codex's
  built-in `/review` is not the project review (`docs/development/review-guidelines.md`).
- **Commands and skills** named in the steps (`/commit`, `prepare-merge`, `/generate-e2e-test`):
  read their files under `.claude/` and follow their steps, as `tdd.md` says. Where it suggests
  the `run` skill, suggest starting the app and trying the change instead.
- The Test-Run Budget, Step 7 (`verify-green`) and the Step 8 completion report apply as written.

## Output expectations

For every non-trivial change:
- Summarize changed files
- Mention risks
- Propose tests (reference the UC that the test covers)
- Reference related ADR / UC IDs when available

## Prohibited actions

- Code generation before Gate 2 approval
- Implementation before Gate 4 (test case) approval
- Committing secrets or credentials
- Bypassing Gate / Policy for authorization
- Schema-breaking migrations without migration plan
- Force-pushing, or committing / pushing / merging without explicit instruction — the core Git rules and the active profile are in `.claude/rules/70-git.md`, the full rules in `docs/development/git-workflow.md`; read both before branching, committing, pushing, or merging
- Editing, deleting, or creating files under `docs/original-docs/` (except its own `README.md`)
