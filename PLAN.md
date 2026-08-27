# PLAN.md

## Split one-time Gate 0 setup steps out of CLAUDE.md into SETUP.md (2026-08-27)

### Decision

- `CLAUDE.md`'s "Required Steps Before Starting the Project (Gate 0)" section (Steps 1-4: frontend stack selection, ai-context fill-in, requirements docs, architecture design, TDD pipeline diagram) was moved verbatim into a new top-level `SETUP.md`, read once at project kickoff. `CLAUDE.md` now only keeps a short pointer to it plus the steady-state per-session rules (Read first / Read when relevant / Global rules / Detailed rules), which are read every session.
- Rationale: ~50 of `CLAUDE.md`'s ~140 lines were one-time kickoff instructions that every session's context was paying for regardless of relevance. Splitting them out reduces per-session context load without losing any content.
- Cross-references to `CLAUDE.md`'s Step 1-4 procedure were repointed to `SETUP.md` in `.claude/rules/00-global.md`, `.claude/rules/60-docs.md`, `meta/adr/ADR-0005-frontend-stack.md`, and `README.md`. `AGENTS.md` was left unchanged — it never duplicated the Step 1-4 procedure, only the Gate summary table, which still applies.
- Old `PLAN.md` entries below that reference "`CLAUDE.md` Step 1a/3" etc. describe the file layout as of when they were written and were left as-is (historical record, not rewritten).

### Files touched

`SETUP.md` (new), `CLAUDE.md`, `.claude/rules/00-global.md`, `.claude/rules/60-docs.md`, `meta/adr/ADR-0005-frontend-stack.md`, `README.md`.

### Status

Completed. No open follow-ups.

## Separate template/harness ADRs from project ADRs (2026-08-17)

### Decision

- `docs/adr/` is reserved exclusively for the ADRs of the project built from this template. It now starts empty; the first project ADR should be `ADR-0001`.
- The 9 ADRs that document this template/harness's own design (ADR-0001 through ADR-0009) were moved to `meta/adr/`, a new top-level directory outside `docs/`. This keeps them out of any future "reset project docs" sweep of `docs/`, and out of the project's own ADR numbering sequence.
- Added a new `ADR-0009-review-escalation-mechanism.md`, documenting the `review-score` mechanism (see below), along with the other harness features ported over in this same pass: the `docs/credentials/` handling policy (`.gitignore` + `.claude/rules/40-security.md`), the optional/non-blocking UAT step (`.claude/rules/00-global.md` + `docs/product/uat-scenarios.md` / `uat-results/`), the CRUD-coverage rule for new data models (`.claude/rules/30-testing.md` / `50-review.md` / `.claude/commands/review.md`), a dedicated `.claude/rules/31-e2e-testing.md` split out of `30-testing.md`, and the "API Conventions" / "Error Handling Policy" sections in `docs/development/coding-standards.md`.
- All cross-references to these 9 files (in `CLAUDE.md`, `AGENTS.md`, `.claude/rules/`, `docs/ai-context/`, `docs/architecture/`, `docs/development/`) were repointed to `meta/adr/`. References to `docs/adr/` that describe creating a *new* project ADR (e.g. `/adr` command, `CLAUDE.md` Step 1a/3, Gate rules) were left unchanged.
- Added `docs/adr/README.md` and `meta/adr/README.md` explaining the split so it isn't rediscovered by accident later.
- Added a `/review` Step 0 that runs `.claude/hooks/review-score.sh` (a local, AI-free script scoring the diff since `git merge-base main HEAD`) to auto-select the normal vs. enhanced review level.

### Files touched

`meta/adr/ADR-0001` through `ADR-0009` (moved from `docs/adr/`), `docs/adr/README.md` (new), `meta/adr/README.md` (new), `.claude/hooks/review-score.sh` (new), `.gitignore` (new), `docs/credentials/README.md` (new), `docs/product/org-permission-philosophy.md` (new), `docs/product/uat-scenarios.md` (new), `docs/product/uat-results/README.md` (new), `docs/product/user-guide.md` (new), `docs/ai-context/known-pitfalls.md` (new), `.claude/rules/31-e2e-testing.md` (new, split from `30-testing.md`), `README.md`, `CLAUDE.md`, `AGENTS.md`, `.claude/rules/00-global.md`, `.claude/rules/15-frontend.md`, `.claude/rules/30-testing.md`, `.claude/rules/40-security.md`, `.claude/rules/50-review.md`, `.claude/rules/60-docs.md`, `.claude/commands/review.md`, `.claude/commands/generate-e2e-test.md`, `.claude/commands/tdd.md`, `.claude/agents/tdd-implementer.md`, `docs/ai-context/common-commands.md`, `docs/ai-context/module-map.md`, `docs/development/ai-workflow.md`, `docs/development/coding-standards.md`, `docs/development/testing-strategy.md`, `docs/architecture/authz-authn.md`.

### Status

Completed. No open follow-ups.

## Frontend stack selection process built into Gate 0 (2026-08-03)

### Decision

- `docs/adr/ADR-0005-frontend-stack.md` was changed from a fixed decision (Vue 3 + Inertia.js + Pinia for all projects) to a per-project selection framework within the PHP/Laravel ecosystem (Blade / Livewire / Vue+Inertia+Pinia / React+Inertia / SPA+API), with Vue+Inertia+Pinia kept as the default recommendation.
- The selection process is now an explicit part of Gate 0 (`CLAUDE.md` Step 1a/1b/1c): select stack → record a project ADR via `/adr` → rewrite `.claude/rules/15-frontend.md` for the chosen stack → reflect the result in `docs/ai-context/`.
- `.claude/rules/15-vue.md` was renamed to `.claude/rules/15-frontend.md` so the rule file path stays stable regardless of which stack is selected — projects choosing a non-default stack rewrite this file's contents instead of creating a new file and updating every cross-reference.
- Backend (Laravel + MySQL, ADR-0001/0002) and auth strategy (Sanctum + Policy/Gate, ADR-0003) remain fixed template decisions — out of scope for this flexibility.

### Files touched

`docs/adr/ADR-0005-frontend-stack.md`, `docs/adr/ADR-0006-e2e-testing-playwright.md`, `CLAUDE.md`, `AGENTS.md`, `README.md`, `.claude/rules/00-global.md`, `.claude/rules/15-frontend.md` (renamed from `15-vue.md`), `.claude/rules/30-testing.md`, `.claude/rules/50-review.md`, `.claude/rules/60-docs.md`, `.claude/agents/tdd-implementer.md`, `docs/ai-context/module-map.md`.

### Status

Completed. No open follow-ups.
