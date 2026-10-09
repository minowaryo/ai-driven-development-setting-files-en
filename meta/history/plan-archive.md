# plan-archive.md

> Template-internal archive of this repository's own `PLAN.md` entries (newest first). Moved verbatim per `.claude/rules/60-docs.md`.
> Not copied into target projects (`APPLY_TEMPLATE.md` class X; removed in `SETUP.md`).
> Covers: 2026-08-03 – 2026-10-03 (archived 2026-09-30, 2026-10-03, 2026-10-06, 2026-10-09).

## Loop Engineering roadmap + Stage 1: the implementer cannot move the goal (2026-10-03, simplified 2026-10-05)

### Decision

- Source: `meta/design/loop_engineering_design_memo.txt` (template-internal, class X).
  Reasoning and decisions: `meta/adr/ADR-0016-loop-engineering-stage1.md` (Trial; Stage 1
  simplified and re-approved 2026-10-05).
- Goal: AI may iterate implement → verify → review while TDD discipline and human decisions
  stay intact. The shape: people fix the goal (spec + approved tests), the AI does the work,
  machines check. Five stages, each started only on measured results; Gate definitions do not
  change before Stage 3; no orchestrator or separate repo before Stage 5.
- **Stage 1 has one job: `tdd-implementer` cannot move the goal.** The lock binds only the
  implementer during Green; people, the main session and `test-writer` work as today. A
  legitimate change to tests or spec = a person decides → restart from Red → Gate 4 approval
  (which takes a fresh snapshot). No relock/abandon commands, no lock lifetime, no config file.
- Verified on Claude Code 2.1.278 (CLI): `settings.json` PreToolUse hooks receive
  `agent_type: "tdd-implementer"` (Write and Bash); frontmatter hooks do not run under
  `claude -p`; deny works; a timed-out hook fails open; `disable-model-invocation` works on
  command files; the project `/review` wins over the bundled alias (undocumented).
- Reproduced and rejected as baselines: the real index (`git add -A` after tampering, 10-03)
  and a git tree hash via a temporary index (clean-filter forgery, 10-05). Stage 1 compares
  against a plain copy taken at Gate 4 approval — verified to catch both tricks and to give a
  readable diff.
- Stage 1 adds no new dependency (Bash + POSIX tools + Git).
- Company repository: hold lifted for Stage 1 only (2026-10-05); Stage 1 ported there
  (`219dd51`, not pushed); Stages 2–5 stay on hold. JP: allowed (port in a separate session).

### Stage 1 checklist (ADR-0016 items 1–10)

- [x] 1 SPEC_CONFLICT stop-and-report in `tdd-implementer.md` (+ a sentence that factual gate feedback is part of its task)
- [x] 2 Stop conditions in `/tdd` (3 Green attempts; same failure twice → human)
- [x] 3 PreToolUse hook in `.claude/settings.json`: for `agent_type == tdd-implementer` deny Write/Edit and Bash touching `tests/` or `docs/product/`, and git `add/commit/stash/checkout/restore/reset/rm/mv/apply/update-index/config`; drop "`git add` is fine" from `tdd-implementer.md`; bash builtins only, no lingering child process
- [x] 4 Hook tests in `meta/tests/` (path forms `C:\` / `/c/` / `c:/`, case, `..`, worktree `cwd`, Bash command strings)
- [x] 5 Approved snapshot: at Gate 4 approval copy `tests/` + `docs/product/` to `$(git rev-parse --git-path claude-tdd)/approved/`; after Green `diff -r`; on any difference show the diff and stop for the person
- [x] 6 Update notes on ADR-0007 (Probity limits) and ADR-0014 (Laravel Boost MCP-only install)
- [x] 7 `disable-model-invocation: true` on all `.claude/commands/*.md`; `/tdd` step 6 and `prepare-merge` step 1 read the command file instead of starting it; `"code-review": "user-invocable-only"` in `skillOverrides`; correction note on ADR-0012
- [x] 8 `APPLY_TEMPLATE.md` class C also merges `hooks` from `.claude/settings.json`
- [x] 9 Denial log `logs/audit.jsonl` (`GLOBAL_CLAUDE.md` convention; git-ignored; `event: agent_guard_denial`, `session_id`, no file contents); one docs line distinguishing it from the app's `audit` channel
- [x] 10 Re-verify the hook facts on the Claude Code version actually in use (VS Code extension ran 2.1.283–284)

Done when: hook tests pass in Git Bash; a real `/tdd` run shows a denied implementer write in
the log and a snapshot diff after a forced tamper; docs updated (`README.md`,
`common-commands.md`, a `30-testing.md` pointer, a one-page "what is locked, and how to change
it" note).

### Later-stage drafts (not decided) — `meta/design/`

`gate-contract.md` (one gate, scopes `cycle`/`branch`, exit codes 0–3, evidence JSON, Pest
`->group('UC-NNN')`; the merge-time check B12 follows it) · `loop-stage2-experiment-protocol.md`
(2a unattended → 2b human A/B, split approved) · `loop-stage2a-seeds.md` + runner sketch
(conflict seeds with spec-true oracles; shadow replay via shallow clone; needs PHP 8.2+) ·
`loop-reviewer-design.md` (minimal R0: deterministic pre-pass + one finder + cite-check; no
approve power) · `loop-stage3-loop-design.md` (bounded Green loop via SubagentStop; factual
gate messages; PostToolUse(`Agent`) reports to the parent; Gate 4 profiles deferred) ·
`loop-stage4-design.md` (Codex: lock tied to a wrapper invocation; shared scripts) ·
`loop-stage5-design.md` (conditional; WSL2 + sandbox runner outside the agent).

### Status

Stage 1 approved (Trial), simplified and implemented 2026-10-05 on `feat/loop-stage1`
(worktree `.claude/worktrees/loop-stage1`): `agent-guard.sh` (43 tests), `tdd-snapshot.sh`
(14 tests), all other `meta/tests` green, end-to-end `claude -p` run on 2.1.288 confirmed four
denials, the allowed app write, the log lines and the snapshot diff. Next: commit, merge, then
Stage 2a preparation (needs a PHP 8.2+ project).

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
