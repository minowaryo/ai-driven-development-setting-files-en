# PLAN.md

> Keep under 300 lines (`.claude/rules/60-docs.md`). Archived: 2026-08-03 – 2026-09-29 → `meta/history/plan-archive.md` (2026-09-30, 2026-10-03).

## Deterministic checks, group 1: strict Eloquent in tests, spec-lint, doc consistency (2026-10-03)

### Decision

- From a whole-cycle survey (`meta/design/template-improvement-directions.md`, B11–B20):
  group 1 (B14–B16) adds no dependency and does not overlap ADR-0016; group 2 (B11–B13,
  B17) went to the Loop session.
- **1 Strict modes in tests** — `10-laravel.md`: `Model::shouldBeStrict(! $this->app->isProduction())`
  in `AppServiceProvider::boot()` (not `isLocal()`, false under `APP_ENV=testing`);
  `30-testing.md`: `Http::preventStrayRequests()` in `tests/TestCase.php`. `SETUP.md` Step 4
  adds both once. Existing codebases: a Backlog item, on only by human decision.
- **2 `.claude/hooks/spec-lint.sh`** — read-only bash + awk, exit 0 / 1 findings / 2 usage.
  UC heading `### UC-NNN: title` and F-ID format/uniqueness; each UC has Actor, Basic Flow,
  Error Cases, Permissions with content; `Related requirement` resolves; unused F-IDs;
  leftover placeholders outside the Approval Record; mockups vs UC IDs; warn-only words in
  the four high-precision smell categories (EN + short JA list). Skips requirements checks
  when `requirements.md` is a pointer. The AI runs it before Gate 1 / Gate 2 / the Gate 0-3
  sign-off (`SETUP.md` Steps 2, 2B; `/onboard-existing-codebase`); it informs, never decides.
  Tests: `meta/tests/spec-lint.test.sh`. Gate definitions unchanged.
- **3 Doc consistency** — PHPStan only where Larastan is installed (Vue starter kit: level 7;
  adding it = ADR + baseline); raw SQL stated once in `20-mysql.md` (bindings + why-comment;
  `DB::statement`/`unprepared` need an ADR), pointed to from `10-laravel` / `40-security`;
  one author self-check in `review-guidelines.md` (`review-checklist.md` points to it);
  UC IDs `UC-006` in docs, `UC006`/`uc006` in file names; `phpunit.xml` defaults to in-memory
  SQLite (verified, 13.x) → `SETUP.md` Step 4 sets a MySQL test DB; `ValidateCsrfToken`;
  `20-mysql.md` utf8mb4 example; Pint "required in CI" → before merge.

### Files touched

`.claude/hooks/spec-lint.sh`, `meta/tests/spec-lint.test.sh` (new); `.claude/rules/{10,20,30,40}-*.md`;
`SETUP.md`; `.claude/commands/{onboard-existing-codebase,generate-mock}.md`;
`docs/development/{ai-workflow,coding-standards,review-checklist,review-guidelines,e2e-testing}.md`;
`docs/product/{use-cases,ui-guidelines}.md`, `uat-results/README.md`; `docs/development/testing-strategy.md`;
`docs/ai-context/common-commands.md`; `CLAUDE.md`, `AGENTS.md` (one row each); `README.md`; `meta/design/template-improvement-directions.md`; `PLAN.md`.

### Status

Merged into `main` from `feat/deterministic-checks` (`--no-ff`); spec-lint tests 40/40, review-score 27/27.
Unverified: `SETUP.md` Step 4 snippets not run in a real Laravel app — check on the first project.

## Domain Boundary check: accuracy + own tests, then run it at prepare-merge (2026-10-03)

### Decision

- Part 1 (merged, `84f26bc`): fixture-found misses and false positives fixed inside
  `.claude/hooks/domain-boundary-check.sh`, pinned by `meta/tests/domain-boundary-check.test.sh`
  (31 cases); details and remaining gaps in the 2026-10-03 note on `meta/adr/ADR-0010`.
- Part 2: the check only ran from `/review`, which `lite` rarely asks for on an ordinary
  Controller change — so it usually never ran before a merge. `prepare-merge` now runs it in
  step 2 next to `review-score.sh`, every merge, both profiles (deterministic, ~1s).
- Findings never change the tier and never make `/review` mandatory (pattern matches, not
  verdicts — ADR-0010). Violations or a priority file, with no `/review` since the last
  commit → ask once in plain words: fix first, run `/review`, or merge as is. After a
  `/review`, they are only listed in the plan. Heuristic-only warnings are listed, not asked.
- The count goes into the `Merge-Check:` trailer (`boundary N`, only when non-zero), so
  `git log --first-parent` shows whether the boundary holds over time.
- A script error or "skipping" output does not stop the merge; it is shown in the plan.
- Not touched (another branch edits it): the self-check list in `review-guidelines.md`.

### Checklist

- [x] Part 1 merged and pushed
- [x] Part 2 docs: `git-workflow.md` §5/§6, ADR-0010 + ADR-0015 notes, pointers in `10-laravel.md`, `README.md`
- [x] Part 2 procedure: `.claude/skills/prepare-merge/SKILL.md` steps 2-5
- [x] Verify: scratch repos — violating Controller (`>> 2 violation(s) ... 1 priority file(s)`, exit 1 → ask), clean one (exit 0 → silent); this repo (`nothing to check`, exit 0)

### Status

Part 2 implemented on branch `feat/boundary-check-at-merge` (worktree `.claude/worktrees/boundary-check-at-merge`); not committed.
Later, separately: a PostToolUse hook (needs an ADR-0014 / ADR-0010 revision).

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
- [ ] 3 Test-lock PreToolUse hook (`.claude/hooks/`, registered in `.claude/settings.json`); locked paths `tests/` **and `docs/product/`**; bash builtins only and no lingering child process (a timed-out hook fails open — verified 2026-10-03)
- [ ] 4 Hook tests in `meta/tests/`
- [ ] 3b The hook also denies index/worktree-changing git commands for `tdd-implementer` (`add`, `commit`, `stash`, `checkout`, `restore`, `reset`, `rm`, `mv`, `apply`, `update-index`); drop the "`git add` is fine" line in `tdd-implementer.md`
- [ ] 5 Green evidence: at Gate 4 approval record a tree hash of the locked paths (`tests/`, `docs/product/`) via a temporary index (`GIT_INDEX_FILE=<tmp> git add -A -- tests/ docs/product/ && GIT_INDEX_FILE=<tmp> git write-tree`), store it under `.git/claude-tdd/` and print it; after Green the same computation must match (covers modified, deleted and new files; independent of the real index). Amended 2026-10-03: the index-based check was bypassable with a tampered test + `git add -A` — reproduced, and the fix verified, in a scratch repo
- [ ] 6 Update notes on ADR-0007 (Probity limits) and ADR-0014 (Laravel Boost MCP-only install)
- [ ] 7 `disable-model-invocation: true` on all `.claude/commands/*.md` (verified on command files 2026-10-03; fallback `skillOverrides`); `/tdd` step 6 and `prepare-merge` step 1 change from "run `/<cmd>`" to "read `.claude/commands/<cmd>.md` and follow its steps"; `"code-review": "user-invocable-only"` in `skillOverrides`; correction note on ADR-0012. `/review` precedence verified 2026-10-03: project command wins (undocumented)
- [ ] 8 `APPLY_TEMPLATE.md` class C also merges `hooks` from `.claude/settings.json`
- [ ] 9 Denial log `logs/audit.jsonl` (`GLOBAL_CLAUDE.md` convention; git-ignored, no file contents, with `session_id` and an `event` type such as `agent_guard_denial`); one line in the docs distinguishing it from the app's `audit` channel (`storage/logs/audit.log`)
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
  Update 2026-10-03 (28 headless runs): both open problems resolved — a factual gate message
  plus a trust sentence in the agent definition gave 3/3 compliance (imperative without it:
  0/3); PostToolUse(`Agent`) `additionalContext` reaches the parent. U1–U4, U6 confirmed; U7
  partial (hook timeout fails open on Windows); hitting `maxTurns` skips SubagentStop.
- `meta/design/loop-stage2a-seeds.md` (+ `loop-stage2a-runner.sketch.sh`) — three conflict
  seeds with spec-true oracle tests (catches implementations bent against the spec that pass
  every locked test), reviewer seeds, shadow replay via shallow clone (a worktree leaks the
  human solution), runner sketch; needs Stage 1 implemented and a PHP 8.2+ environment.
- `meta/design/gate-contract.md` — one gate script for two scopes (`cycle` for `/tdd` and the
  loop, `branch` for `prepare-merge`), exit codes 0/1/2/3, evidence JSON, and the Pest
  `->group('UC-NNN')` convention; the merge-time check (backlog B12) is built against it so
  Stage 2 reuses it. Mutation score added to Stage 2 as an optional test-strength metric.
- `meta/design/loop-stage5-design.md` — conditional Stage 5: start criteria; a dedicated WSL2
  distro + Bash sandbox (same script portable to a two-job GitLab CI later); runner outside
  the agent restores locked paths before each gate run and judges by JUnit id-set equality;
  runtime policy via `--settings` (repo settings cannot enable isolation or credentials);
  publisher holds push credentials; opt-in folder first, separate repo only on criteria.
  Residual risk: the gate executes agent code that could forge test output.
- `meta/design/loop-reviewer-design.md` — evidence-based reviewer: deterministic pre-pass,
  finder(s), cite-check, optional verifier, script-computed route, no approve power; start
  with the minimal config (R0) and add passes only on Stage 2a numbers.

Done when: hook tests pass in Git Bash, a real `/tdd`-style run shows a denied
`tdd-implementer` write logged, and docs (`README.md`, `common-commands.md`, `30-testing.md`
pointer) are updated.

### Files touched (so far)

`meta/design/loop_engineering_design_memo.txt` (new; original in `docs/original-docs/` to be
deleted by hand), `APPLY_TEMPLATE.md`, `SETUP.md`, `README.md`,
`meta/adr/ADR-0016-loop-engineering-stage1.md` (new), `meta/adr/README.md`, `PLAN.md`,
`meta/design/template-improvement-directions.md` (new), `docs/development/ai-workflow.md`,
`meta/design/loop-stage2-experiment-protocol.md` (new), `meta/design/loop-stage3-loop-design.md` (new),
`meta/design/loop-reviewer-design.md` (new), `meta/design/loop-stage2a-seeds.md` (new),
`meta/design/loop-stage2a-runner.sketch.sh` (new), `meta/design/gate-contract.md` (new),
`meta/design/loop-stage5-design.md` (new),
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
