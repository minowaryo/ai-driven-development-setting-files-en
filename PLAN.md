# PLAN.md

> Keep under 300 lines (`.claude/rules/60-docs.md`). Archived: 2026-08-03 – 2026-09-14 → `meta/history/plan-archive.md` (2026-09-30).

## Per-session load reduction: move read-on-demand content out of auto-loaded files (2026-09-30)

### Decision

- Same core/detail pattern as the Git split, applied only where the content is needed at one
  moment: `.claude/rules/31-e2e-testing.md` → `docs/development/e2e-testing.md` (read by
  `/generate-e2e-test`); `50-review.md` body → `docs/development/review-guidelines.md` (read by
  `/review`; a 3-line core stays); `60-docs.md` PLAN archive procedure →
  `docs/development/plan-archiving.md` (limit and destination stay), ADR template → points to
  `.claude/commands/adr.md` (its single source); "When Git Gets Stuck" →
  `docs/development/git-troubleshooting.md` (out of the read-first `common-commands.md`).
- Every move is verbatim (diff-checked); only titles and self-references were adjusted.
- Result: auto-loaded rules ~13,260 → ~10,630 tokens; with the read-first ai-context files
  ~16,370 → ~13,530. A fresh `claude -p` session located every moved item correctly.
- Not done (deferred): `paths:` scoping for `10-laravel` / `15-frontend` / `20-mysql` —
  decide after personal trial.

### Files touched

`CLAUDE.md`, `README.md`, `.claude/rules/30-testing.md`, `.claude/rules/50-review.md`,
`.claude/rules/60-docs.md`, `.claude/commands/review.md`, `.claude/commands/generate-e2e-test.md`,
`docs/ai-context/common-commands.md`, `docs/development/{e2e-testing,review-guidelines,git-troubleshooting,plan-archiving}.md`
(new or moved), `docs/development/git-workflow.md`, `docs/development/review-checklist.md`,
`docs/development/testing-strategy.md`, `PLAN.md`, `meta/history/plan-archive.md` (2026-08-27 and 2026-09-14 entries archived).

### Status

Implemented on `feat/token-reduction` (EN); not committed. Next: port to JP and company after
their Git-workflow ports land.

## Git workflow: `lite` profile (default) alongside `standard`, one-line switch (2026-09-30)

### Decision

- A profile switch — `Profile: lite` (default) or `standard` in `.claude/rules/70-git.md` —
  switched by editing that one line (the user asks in plain words; AI edits and commits it,
  never switches on its own). Only the rows in the §0 table of `docs/development/git-workflow.md` differ; everything else,
  including every safety rule, is shared.
- `lite`: AI names and creates the branch without waiting; one commit per `/tdd` cycle;
  `/review` is asked about only when a sensitive path is touched (size is information);
  commit → merge → push may run on one approval of a plan that shows commits, files,
  score, tier, and tests — any failure stops the rest.
- `standard`: the 2026-09-29 rule set, unchanged.
- Selection: `standard` for production systems with real data or 2+ parallel developers;
  otherwise `lite`.
- `docs/ai-context/common-commands.md` gains "When Git Gets Stuck" (situation → what to ask
  the AI), for developers with little Git experience.
- Load cost: the full rules moved to `docs/development/git-workflow.md` (read before Git
  operations); `.claude/rules/70-git.md` is now an 18-line always-loaded core (profile line +
  safety rules that hold even if the full file is not read). Auto-loaded context: ~14,100
  tokens on `main` → ~13,300. Pointers repointed; no other auto-loaded file grew by more than
  ~150 characters (no new CLAUDE.md "Read when relevant" row — the core already says when).
- Recorded as update notes on `meta/adr/ADR-0015-git-workflow.md`.
- Scope: EN template only. JP port and the generalized docs (`~/Downloads/git-workflow-rules*.md`)
  follow after personal trial use.

### Files touched

`.claude/rules/70-git.md`, `.claude/commands/tdd.md`, `.claude/commands/commit.md`,
`.claude/skills/prepare-merge/SKILL.md`, `docs/ai-context/common-commands.md`,
`meta/adr/ADR-0015-git-workflow.md`, `docs/development/git-workflow.md` (new), `CLAUDE.md`,
`AGENTS.md`, `APPLY_TEMPLATE.md`, `README.md`, `.gitignore`, `.claude/hooks/review-score.sh`
(comments), `.claude/rules/30-testing.md`, `.claude/rules/50-review.md`, `.claude/rules/60-docs.md`,
`docs/development/ai-workflow.md`, `docs/development/coding-standards.md`, `PLAN.md`,
`meta/history/plan-archive.md` (new — first
archive of this template's own PLAN.md, 2 oldest entries moved verbatim).

### Status

Implemented on `feat/git-lite-profile`; not committed. Next: personal trial, then JP port
and generalized docs.

## Git workflow rules: branches, commit unit, authority, --no-ff merge record, merge-check tiers (2026-09-29)

### Decision

- Full design spec: the author's local planning notes (`~/.claude/plans/`, not in this repo);
  the durable record is `meta/adr/ADR-0015-git-workflow.md`.
- Primary host is GitLab (GitHub must still work). MR/PR process, CI, and branch
  protection are deferred; branches + commits + `--no-ff` merge commits alone must
  produce the record.
- GitHub-Flow-style short-lived branches (`<type>/<issue-no>-<slug>`); direct commits to
  `main` only for docs/typo-only changes.
- Commit unit: one-sentence test, green at every commit, behavior / refactor / formatting
  kept apart; `/tdd` Red+Green = one commit, Refactor = separate commit, migration = own commit.
- Authority: AI commits only via `/commit` (split proposal → one human approval); push
  only on explicit instruction (`ask`); force-push denied; merge prepared by the new
  `prepare-merge` skill and executed only on explicit instruction.
- Merge commit = lightweight MR substitute: git default subject + short "why" body +
  `Merge-Check:` / `Review:` / `Tests:` trailers.
- Pre-merge check reuses `review-score.sh`: `light` (< 10, tests only) / `recommended`
  (10-29, `/review` suggested) / `required` (≥ 30 or any sensitive path, `/review`
  mandatory). Thresholds calibrated on 4 local Laravel repos' history plus Google
  "Small CLs" / SmartBear guidance; Trial status.
- Worktrees only for parallel sessions; no per-task sub-agent review loop; project rules
  override Superpowers Git skills.
- `.claude/rules/70-git.md` is the single source of truth for Git rules; every other
  file keeps at most a one-line pointer.
- After EN is complete, port to the JP sibling repo (`ai-driven-development-setting-files`).

### Files touched

Implementation plan: the author's local planning notes (not in this repo); branch
`feat/git-workflow-rules`.

Phase A (docs): `.claude/rules/70-git.md` (new), `meta/adr/ADR-0015-git-workflow.md` (new),
`meta/adr/README.md`, `meta/adr/ADR-0009-review-escalation-mechanism.md`, `CLAUDE.md`,
`AGENTS.md`, `.claude/rules/00-global.md`, `.claude/rules/30-testing.md`,
`.claude/rules/50-review.md`, `.claude/rules/60-docs.md`,
`docs/development/coding-standards.md`, `docs/development/review-checklist.md`,
`docs/development/ai-workflow.md`, `docs/security/secrets-handling.md`,
`docs/product/org-permission-philosophy.md`, `docs/product/user-guide.md`,
`docs/ai-context/common-commands.md`, `README.md`.

Phase B: `.claude/hooks/review-score.sh`, `meta/tests/review-score.test.sh` (new —
template-internal, `APPLY_TEMPLATE.md` class X), `.claude/commands/commit.md` (new),
`.claude/skills/prepare-merge/SKILL.md` (new), `.claude/commands/tdd.md`,
`.claude/settings.json` (new), `.gitignore`, `APPLY_TEMPLATE.md`.

### Status

Completed in EN and JP: committed on `feat/git-workflow-rules`, `/review` (enhanced) passed
with its findings fixed, then merged into `main` with `--no-ff` via `prepare-merge`.
Verified: `bash meta/tests/review-score.test.sh` → 27/27; force push denied / normal push
not denied in a live session; a fresh `claude -p` session loads `70-git.md` and
`prepare-merge`. ADR-0015 is anonymized (no internal project names). The template's own
PLAN.md archive lives in `meta/history/` (class X). Target projects start with a blank
`PLAN.md` on both paths: `APPLY_TEMPLATE.md` class D, and `SETUP.md` "Before Step 1" for
projects copied from the template (which also removes `meta/tests/`, `meta/history/`,
`APPLY_TEMPLATE.md`). Follow-up: revisit the Trial thresholds after real use (ADR-0015).

## Third-party skill/plugin adoption: 4 in-house skills (Trial) + a deferral record (2026-09-28)

### Decision

- A user-provided comparison of the "Superpowers" Claude Code plugin (`obra/superpowers`)
  against this harness prompted a broader evaluation of third-party Claude Code tooling.
  Two research passes verified the actual claims (repo survey of this template's own
  `.claude/`, plus web verification of Superpowers, Laravel Boost, cc-sdd,
  `mattpocock/skills`, and hookify) before any adoption decision was made.
- **Adopted, in-house, all in one pass, marked Trial** (`meta/adr/ADR-0013-third-party-skill-adoption-trial.md`):
  new skills `.claude/skills/systematic-debugging/SKILL.md` (reproduce-and-localize
  discipline for unclear bugs) and `.claude/skills/verification-before-completion/SKILL.md`
  (no "done" claim without an actual run this turn), a new "Test Quality Heuristics"
  subsection in `.claude/rules/30-testing.md` (don't mock the behavior under test, don't
  derive expected values from the implementation, sanity-check a test actually fails when
  the code is broken), and a new skill `.claude/skills/grill-me/SKILL.md` (one-question-at-
  a-time requirements interview, adapted and credited from `mattpocock/skills`). None are
  installed plugins — Superpowers' own SessionStart force-injection (~1,300 tokens wrapped
  in `<EXTREMELY_IMPORTANT>` tags — GitHub issues #1480/#1456/#2377) and non-enforced TDD
  (issues #384/#2372) were verified real risks, so the underlying ideas were rewritten
  in-house instead. The user explicitly chose to roll out all four together rather than
  stage them one at a time, judging three of the four low-risk (they only tighten the AI's
  own internal discipline); `grill-me` is flagged in ADR-0013's rollout-tracking table as
  the one item that changes the human-interaction pattern and is worth watching for
  friction. ADR-0013 introduces **Trial** as a new ADR Status value (alongside
  Proposed/Accepted/Deprecated/Superseded), reflected in the templates in
  `.claude/commands/adr.md` and `.claude/rules/60-docs.md`.
- **Considered and deferred, record-only, no functional changes**
  (`meta/adr/ADR-0014-third-party-integrations-deferred.md`): Laravel Boost (`laravel/boost`)
  — deferred, not rejected, because `php artisan boost:install` overwrites `CLAUDE.md`/
  `AGENTS.md`; if ever adopted, register only its MCP server manually
  (`claude mcp add -s local -t stdio laravel-boost php artisan boost:mcp`), never run the
  full installer against this template. cc-sdd (`gotalab/cc-sdd`) — rejected as redundant
  with this harness's own Gate 0-3 pipeline. hookify (official Anthropic plugin) — deferred/
  watch, since `ADR-0010`'s script-invoked-hook choice was deliberate and a real-hook trial
  deserves its own separately-scoped evaluation. Superpowers itself (the wholesale plugin)
  — rejected, citing the same two verified GitHub-issue risks above.

### Files touched

`meta/adr/ADR-0013-third-party-skill-adoption-trial.md` (new),
`meta/adr/ADR-0014-third-party-integrations-deferred.md` (new),
`.claude/skills/systematic-debugging/SKILL.md` (new),
`.claude/skills/verification-before-completion/SKILL.md` (new),
`.claude/skills/grill-me/SKILL.md` (new), `.claude/rules/30-testing.md`,
`.claude/rules/00-global.md`, `CLAUDE.md`, `docs/ai-context/common-commands.md`,
`README.md`, `meta/adr/README.md`, `.claude/commands/adr.md`, `.claude/rules/60-docs.md`.

### Status

Implemented. Not committed — awaiting explicit instruction. Follow-up: revisit
ADR-0013's rollout-tracking table once the batch has been used for a while — promote
to Accepted, or roll back individually (watch `grill-me` first for human-side friction).

## Skills vs. commands criterion, /regenerate-traceability, standalone /adr export (2026-09-26)

### Decision

- Recorded the criterion for where a new AI entry point belongs, in
  `meta/adr/ADR-0012-skills-vs-commands.md`: **forgetting to run it is the failure mode →
  `.claude/skills/`** (carries a `description`, so AI may invoke it unprompted);
  **running it at the wrong moment is the failure mode → `.claude/commands/`** (no
  `description`, so invocation stays a deliberate human act). The six existing entry points
  all fall on the command side and were deliberately left where they are — migrating them
  would churn cross-references in `SETUP.md`, `README.md`, `.claude/rules/`, and
  `common-commands.md` for no functional gain, and a `description` on `/review` or `/tdd`
  would quietly undo `ADR-0009`'s Option A and Gate 4's approval pause respectively.
- First application of the criterion: `/regenerate-traceability` ships as a skill
  (`.claude/skills/regenerate-traceability/SKILL.md`), making the previously prose-only
  Maintenance procedure in `docs/rcid/traceability-matrix.md` executable. A traceability
  matrix fails by going quietly stale, never by being rebuilt at an awkward moment.
  Its load-bearing constraint: it rewrites **only** the `Matrix` table, never the
  hand-maintained `Change Tracking` table, which is an audit record that cannot be
  re-derived from code. Its reported output leads with Status regressions
  (`Complete` → `Not Found`), since those signal a renamed/deleted file or a match that
  silently stopped working.
- `/adr` was extracted as a standalone, shareable skill to `dist/skills/adr/SKILL.md` with
  the harness-specific reference (`meta/adr/ADR-0007`) stripped and an ADR-directory
  fallback added. `.claude/commands/adr.md` stays as-is and remains the source of truth —
  `dist/` is `.gitignore`d build output, regenerated when someone asks for the file, never
  edited in place. A tracked second copy would drift invisibly, since nothing fails when
  the two disagree.
- PLAN.md archiving was evaluated as a skill candidate in the same pass and **not adopted**
  — line-count checking plus a verbatim move is faster done by hand than maintaining a
  trigger for it.

### Files touched

`meta/adr/ADR-0012-skills-vs-commands.md` (new),
`.claude/skills/regenerate-traceability/SKILL.md` (new), `dist/skills/adr/SKILL.md` (new,
untracked), `.gitignore`, `README.md`, `meta/adr/README.md`,
`docs/ai-context/common-commands.md`, `docs/rcid/traceability-matrix.md`,
`.claude/rules/00-global.md`, `.claude/rules/60-docs.md`.

### Status

Implemented. Not committed — awaiting explicit instruction.

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
