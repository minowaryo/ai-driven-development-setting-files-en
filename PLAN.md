# PLAN.md

## Existing-codebase adoption path for Gate 0-3 (2026-09-15)

### Decision

- This harness's Gate 0-4 pipeline assumed a greenfield project (a human writes
  `requirements.md` from a blank page before any code exists). Added a generic
  "Existing-Codebase Path" for adopting the harness onto a project that already has
  running code: `SETUP.md` gets a new Step 0 branch (new project → unchanged Step 1-4;
  existing code → Step 1B-3B, then rejoin at Step 4), recorded in
  `meta/adr/ADR-0011-existing-codebase-adoption.md`. Single repo, single file, branching
  inside Gate 0 — the same pattern `ADR-0005` already uses for frontend-stack selection —
  not a fork, since Gate 1-4 and `.claude/rules/10-60` are identical either way.
- Step 1B generalizes `ADR-0005`'s "detect, don't assume" treatment from frontend-only to
  the whole stack (backend framework, DB engine, auth mechanism against
  `ADR-0001`/`ADR-0002`/`ADR-0003`); a fundamental mismatch (non-PHP/Laravel backend) stops
  and flags rather than forcing an ill-fitting adoption.
- Two separate output lists, not one: a blocking **"Needs confirmation"** list (only things
  affecting whether the drafted `ai-context/`/`use-cases.md`/`data-model.md` themselves are
  trustworthy — resolving it *is* the single consolidated Gate 0-3 sign-off, replacing four
  separate approvals) and a non-blocking **"Backlog"** list (`domain-boundary-check.sh
  --audit-all` findings — existing code debt, never a blocker, per `ADR-0010`'s own
  "backlog, not blocker" framing). An earlier draft folded Backlog findings into the gating
  list and wired in the built-in `security-review` skill; both were corrected after review
  — the former contradicted `ADR-0010`, and the latter is diff-scoped so it would review the
  onboarding's own docs-only diff rather than the inherited application code.
- New `/onboard-existing-codebase` command automates Step 1B-3B end to end. It is
  positioned as an extended, template-aware version of Claude Code's built-in `/init` (not
  a competitor) — running generic `/init` on this template is discouraged since it would
  overwrite the templated `CLAUDE.md`.
- The branch-detection trip-wire lives in `docs/ai-context/project-summary.md`'s
  placeholder content, not `.claude/rules/00-global.md` — only the former is guaranteed to
  be read on literally the first message of any session (`00-global.md` is only consulted
  when relevant), so only the former can catch an arbitrary first prompt like "add a login
  feature" with no prior knowledge of `SETUP.md`.
- `docs/development/ai-workflow.md`'s Role Breakdown now shows greenfield and
  existing-codebase splits side by side (same shape, different authoring-vs-verifying
  role), with `meta/adr/ADR-0004` getting a short pointer amendment in its existing
  2026-07-15-style format. `docs/original-docs/README.md` gets a clarifying bullet so its
  existing "primary source" guidance (greenfield-only) doesn't read as contradicting the
  new "code is truth" principle for existing-codebase adoption — both are grounded in the
  pre-existing `.claude/rules/00-global.md` "User-Facing Behavior Changes Always Require
  Approval" rule, which already governed spec-vs-code mismatches before this change.
- Deliberately not a rulebook: no attempt to enumerate every kind of code-vs-docs ambiguity
  in advance. The one firm guardrail, stated explicitly in `SETUP.md`, the new command, and
  the ADR: when in doubt, put it on the Needs-confirmation list and ask — never resolve an
  ambiguity by guessing and drafting/implementing on that guess.

### Files touched

`meta/adr/ADR-0011-existing-codebase-adoption.md` (new), `SETUP.md`,
`.claude/commands/onboard-existing-codebase.md` (new), `docs/development/ai-workflow.md`,
`meta/adr/ADR-0004-ai-development-policy.md`, `docs/ai-context/project-summary.md`,
`.claude/rules/00-global.md`, `AGENTS.md`, `README.md`, `docs/original-docs/README.md`,
`.claude/rules/60-docs.md`, `meta/adr/README.md`.

### Status

Completed. Documentation-only change (no application code, no build/test step). No open
follow-ups; the command's actual drafting behavior will get its first real workout the
first time a project uses it against genuine existing code.

## Domain Boundary stated as a contract, plus a deterministic Controller check (2026-09-14)

### Decision

- `.claude/rules/10-laravel.md` now states the **Domain Boundary** (Service/Action layer + Policy layer) as explicit MAY / MUST NOT lists instead of the abstract label "Fat Controller is prohibited". A Controller may only validate via FormRequest, call `authorize()`, call exactly one Service/Action, and format the response; it must not call `DB::`, call Eloquent write methods, check roles inline, or make a decision spanning more than one entity.
- Added `.claude/hooks/domain-boundary-check.sh` — deterministic git + awk, no AI calls — run from `/review` Step 0 next to `review-score.sh`. Reports `db-access` / `eloquent-write` / `role-check` findings plus a per-method branch-density heuristic; `--audit-all` scans the whole tree, `--stats` yields trendable counts, exit 1 on findings so CI can gate.
- Why this, and not the originally proposed DSL: measurement on the real `ihs-tech-uplift` project — which **already uses this harness** — found 103 findings across 21 Controllers, including `DB::transaction()` in a Controller and hand-written `isAdmin()`/`abort(403)` authorization despite 12 Policy classes existing. Prose rules demonstrably did not hold the boundary, but a full DSL + compiler is disproportionate for a docs-and-rules template. Recorded in `meta/adr/ADR-0010-domain-boundary-contract.md`.
- The invariant declaration loop (declare in `data-model.md` → Red-phase coverage → Gate 4) was **deferred, not rejected**, with its reasoning and revisit criteria recorded in ADR-0010 — its cost recurs per change while its benefit arrives months later, and a Feature Test forces a behavior to exist without forcing which layer it lives in.
- `.gitattributes` now pins `*.sh` to LF, protecting both hook scripts from CRLF checkouts on Windows.
- Performance was a design constraint, not an afterthought: an early draft filtered the file list with one `grep` process per file and took 15.8s for 300 Controllers on Windows/Git Bash. Filtering in a single pass brought that to 1.1s (0.59s on the 21-Controller real project, 0.26s for a typical diff-scoped run).

### Files touched

`meta/adr/ADR-0010-domain-boundary-contract.md` (new), `.claude/hooks/domain-boundary-check.sh` (new), `.claude/rules/10-laravel.md`, `.claude/rules/50-review.md`, `.claude/commands/review.md`, `.claude/agents/tdd-implementer.md`, `docs/ai-context/glossary.md`, `meta/adr/README.md`, `.gitattributes`.

### Status

Completed. Gate tables in `.claude/rules/00-global.md`, `SETUP.md`, and `AGENTS.md` were deliberately left untouched (no Gate condition changed). No open follow-ups; revisit the deferred invariant loop per the criteria in ADR-0010.

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
