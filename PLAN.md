# PLAN.md

> Keep under 300 lines (`.claude/rules/60-docs.md`). Archived: 2026-08-03 – 2026-09-26 → `meta/history/plan-archive.md` (2026-09-30, 2026-10-03).

## Loop Engineering roadmap + Stage 1: mechanical TDD enforcement (2026-10-03)

### Decision

- Source: `meta/design/loop_engineering_design_memo.txt` (moved out of `docs/original-docs/`,
  which is for project primary sources; `meta/design/` is class X, removed in `SETUP.md`).
  Evaluated with research, red-team and tool-adoption passes; full reasoning in
  `meta/adr/ADR-0016-loop-engineering-stage1.md` (Proposed).
- Goal: AI iterates implement → verify → review while TDD discipline and human decisions
  stay intact. TDD is not negotiable; checking moves to machines, deciding stays with humans.
- Five stages, each gated by measured exit criteria (ADR-0016 "Stages"). Gate definitions do
  not change before Stage 3; no orchestrator and no separate repo before Stage 5.
- Build only what nothing covers: a test-lock hook keyed on `agent_type` and a thin gate
  wrapper; adopt built-ins and existing tools for the rest (ADR-0016 "Rationale").
- Verified on Claude Code 2.1.278: a `settings.json` PreToolUse hook receives
  `agent_type: "tdd-implementer"` for subagent writes (none for the main session); the same
  hook in the subagent's frontmatter did not run under `claude -p`.
- Stage 1 adds no new dependency (Bash + POSIX tools + Git only).
- Stages 2–3 also use deterministic tools on the change side (Google/Slack migration
  hybrids): auto-fixers before the LLM, machine-found work lists, and migration-type tasks
  in the Stage 2 experiment (ADR-0016 "Deterministic tools on the change side too").
- Loop-independent perspectives are mapped in `meta/design/template-improvement-directions.md`
  (directions D1–D11 + backlog B1–B9). B1 done: "Deterministic Tools First" section in
  `docs/development/ai-workflow.md`. Other backlog items get their own entries when started.

### Stage 1 checklist (ADR-0016 items 1-9)

- [ ] 1 SPEC_CONFLICT stop-and-report in `tdd-implementer.md`
- [ ] 2 Stop conditions in `/tdd` (3 Green attempts; same failure twice → human)
- [ ] 3 Test-lock PreToolUse hook (`.claude/hooks/`, registered in `.claude/settings.json`)
- [ ] 4 Hook tests in `meta/tests/`
- [ ] 5 Green evidence: stage Red at Gate 4 approval; after Green, `tests/` matches the index and has no new untracked files
- [ ] 6 Update notes on ADR-0007 (Probity limits) and ADR-0014 (Laravel Boost MCP-only install)
- [ ] 7 `disable-model-invocation: true` on all `.claude/commands/*.md` (verify it works on command files; fallback `skillOverrides`); `"code-review": "user-invocable-only"` in `skillOverrides`; correction note on ADR-0012. `/review` precedence verified 2026-10-03: project command wins (undocumented)
- [ ] 8 `APPLY_TEMPLATE.md` class C also merges `hooks` from `.claude/settings.json`
- [ ] 9 Denial log `logs/audit.jsonl` (git-ignored, no file contents, with `session_id`)
- [ ] 10 Re-verify the hook facts on the Claude Code version actually in use (extension ran 2.1.283–284; CLI verified 2.1.278)

Item 3 detail (verified 2026-10-03): deny via exit 2 or JSON both work; the hook must also
check Bash `command` strings (a path-only check let a Bash write through); use bash builtins
only (~83 ms vs ~500 ms per call).

### Stage 2 / 3 design drafts (not decided)

- `meta/design/loop-stage2-experiment-protocol.md` — split (approved 2026-10-03) into 2a (unattended: seeded
  spec/test conflicts, shadow replays of migration tasks, reviewer seeds) and 2b (human A/B,
  ~20 tasks, only if 2a is promising); hypotheses, metrics, frozen decision rule, budget.
- `meta/design/loop-stage3-loop-design.md` — state machine, SubagentStop-driven bounded
  Green loop, Gate 4 `lite`/`standard`, minimal reviewer output, user-facing change rule.
  Open problems: the subagent may ignore the block reason as untrusted hook output; the
  parent sees only the subagent's final message. Unverified U1–U8 listed there.

Done when: hook tests pass in Git Bash, a real `/tdd`-style run shows a denied
`tdd-implementer` write logged, and docs (`README.md`, `common-commands.md`, `30-testing.md`
pointer) are updated.

### Files touched (so far)

`meta/design/loop_engineering_design_memo.txt` (new; original in `docs/original-docs/` to be
deleted by hand), `APPLY_TEMPLATE.md`, `SETUP.md`, `README.md`,
`meta/adr/ADR-0016-loop-engineering-stage1.md` (new), `meta/adr/README.md`, `PLAN.md`,
`meta/design/template-improvement-directions.md` (new), `docs/development/ai-workflow.md`,
`meta/design/loop-stage2-experiment-protocol.md` (new), `meta/design/loop-stage3-loop-design.md` (new),
`meta/history/plan-archive.md` (2026-09-26 and 2026-09-15 entries archived).

### Status

ADR-0016 approved 2026-10-03 (Trial). Stage 1 implementation is handed to a separate
session on branch `feat/loop-stage1`; this session continues Loop Engineering research and
planning (Stages 2–5). Not committed.

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
