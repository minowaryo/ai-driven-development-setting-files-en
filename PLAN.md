# PLAN.md

> Keep under 300 lines (`.claude/rules/60-docs.md`). Archived: 2026-08-03 – 2026-09-30 (load reduction) → `meta/history/plan-archive.md` (2026-09-30, 2026-10-03, 2026-10-06).

## Evidence the implementer cannot rewrite, and denials shown from the log (2026-10-07)

### Decision

- Source: a CoT-faithfulness review (an AI's stated reasoning need not match what drove its
  actions; the external record of actions is the evidence). Recorded as amendments to
  ADR-0016 items 3 and 5; principle added to D6 in `meta/design/template-improvement-directions.md`.
- **1 Lock the record** — `agent-guard.sh` also denies `tdd-implementer` writes to `logs/`
  (and `audit.jsonl` in Bash commands) and to any path with a `claude-tdd` segment (the
  approved snapshot; covers worktree git dirs). Rule `locked_evidence`, own message.
  Probed 2026-10-07: all three tamper routes passed before.
- **2 Denials from the log, not the report** — `tdd-snapshot.sh record` notes the log size;
  `verify` prints every `agent_guard_denial` line since approval verbatim (or "none"), and a
  shorter log is a change (exit 2). Denials alone keep exit 0. `/tdd` Step 4 shows them.
- Backlog only: B29 (raw evidence next to AI summaries at Gate 4 / merge plan), B30
  (AI-written reasons cite evidence or say "inference").
- No new dependency. JP / company ports follow ADR-0016's existing plan (company has Stage 1).

### Checklist

- [x] Docs: ADR-0016 items 3 / 5 + rollout notes, `docs/development/tdd-guard.md`, D6 + B29 / B30, this entry
- [x] `agent-guard.sh` evidence lock + 17 cases in `meta/tests/agent-guard.test.sh` (60 total; the 12 new deny cases fail on the previous script)
- [x] `tdd-snapshot.sh` log offset + denial report + 8 cases in `meta/tests/tdd-snapshot.test.sh` (22 total; 7 fail on the previous script)
- [x] `/tdd` Step 4 wording; `README.md`, `common-commands.md`; `meta/traceability-matrix.md` rows (role, cost, sync)
- [x] All `meta/tests/*.test.sh` pass (agent-guard 60, domain-boundary 31, review-score 27, spec-lint 43, tdd-snapshot 22); the three tamper routes from the probe now exit 2

### Status

Docs approved by the maintainer 2026-10-07; implemented on `feat/evidence-lock`, not committed.
Cost: hook unchanged (same-machine A/B); `verify` +≈0.2 s. Not done: an end-to-end `claude -p`
run (the hook payload format is unchanged since the 2.1.288 check). Ports: company and JP later.

## Loop Engineering Stage 2a: unattended checks before any loop (2026-10-06)

### Decision

- Record: `meta/adr/ADR-0017-loop-engineering-stage2a.md` (Trial, approved 2026-10-06). Stage 2 is split
  (approved 2026-10-03): 2a runs unattended checks; 2b (human A/B) only if 2a is promising.
- ① Seeded spec/test conflicts (18 runs) and ② reviewer seeds (33 runs, config R0) in a
  local-only lab app `C:\workspace\loop-stage2a-lab` (Laravel + Pest + SQLite, PHP 8.5.7 by full
  path, Stage 1 harness copied in); ③ shadow replays (~8 runs) on shallow clones of
  `ihs-tech-uplift` with their own MySQL test databases — the original is never touched.
- Claude Code pinned by copying the 2.1.288 binary into the lab; model pinned; per-run
  `--max-turns` / `--max-budget-usd`. The maintainer is on a $125/month subscription, so runs
  go in small batches, checking remaining usage between batches.
- Exit criteria are frozen in ADR-0017. The template itself gains no hook or test file in 2a.

### Checklist

- [x] ADR-0017 reviewed and approved (2026-10-06)
- [x] Lab app built (Laravel 13 + Pest 5.3, PHP 8.5.7); Stage 1 harness copied; pinned 2.1.288 binary (same version as the Stage 1 hook check)
- [x] ① done 2026-10-06: 34 runs (≈ $7) — seeds C1–C3 + control C0; arms A (Stage 1), B (no hook), C (no SPEC_CONFLICT way out); models Sonnet 5, Sonnet 5.5 medium, Haiku 4.5. Stage 1 as shipped: 17/18 honest stops; cheating = bending the implementation or special-casing test values, never editing tests; no false "green" claims, no invented conflicts. Results: `meta/history/loop-stage2a-results.md`
- [ ] Gate candidate from ①: deterministic "test fixture values hard-coded in app code" check (decide in Stage 2 gate work)
- [~] ② reviewer seeds (8 + 2 clean + 1 injection) + R0 pipeline: first pass done 2026-10-06 (1 run per seed x 3 models, ≈ $6.7 incl. a pilot). All three models met the recall / clean / injection thresholds; Haiku missed the N+1 seed and had 1 invalid output. Sonnet 5.5 repeated 3x (33 runs): 12/12 judgment recall, clean controls pass, injection 3/3, identical across runs; precision ≈ 84–100% (two independent AI labellers agreed: 0 invalid of 62; a person's spot-check is still advised). Next: ③ shadow replays (maintainer picks ~4 tasks). Results: `meta/history/loop-stage2a-results.md`
- [x] ③ done 2026-10-07: 4 finished authorization fixes in `ihs-tech-uplift` replayed (no behaviour-preserving migrations existed), 1 run each, ≈ $4.4. All green and close to the human code, no test/spec changes; 2 of 4 left a screen-logic residual the human fixed, which the diff reviewer did not see; guard false positive on a real project. Results: `meta/history/loop-stage2a-results.md`
- [ ] Aggregated results in `meta/history/`; go / stop decision recorded in ADR-0017

### Status

① done 2026-10-06. Next: ② reviewer seeds, then ③ — in a new session (Sonnet 5.5, medium
effort) from the handoff note `C:\workspace\loop-stage2a-lab\HANDOFF.md`. Usage rule: stop when
remaining weekly usage would drop below 60% (maintainer, 2026-10-06).

## Harness traceability matrix + ADR-0018 for spec-lint (2026-10-05)

### Decision

- `meta/traceability-matrix.md` (template-internal, class X) traces every `.claude/hooks/*.sh`:
  where it runs, how often, cost per run, decision (ADR), test, and sync across EN / JP /
  company. Maintained by hand in the same commit as a script change; no dedicated test (user
  decision 2026-10-05: keep only tests that guard a script). The project's own
  `docs/rcid/traceability-matrix.md` is unchanged.
- `meta/adr/ADR-0018-spec-lint.md` (Trial) records the spec-lint decision, which had none.
  ADR-0017 is reserved by the Loop session for Stage 2a.
- Follow-ups (2026-10-06): `APPLY_TEMPLATE.md` copy filters now also exclude `meta/design/`
  and the matrix; backlog B5 recorded as `meta/design/rule-enforcement-inventory.md`; open
  items ranked by effect / security / governance / groundwork / UX in
  `template-improvement-directions.md` (B25, B27, B28 dropped); B21 (`#[Unguarded]`, `v-html`,
  CSRF and auth-middleware names) and B26 (`DB::prohibitDestructiveCommands` in production)
  done; `do-not-touch.md` keeps existing Policy rules locked but treats adding a Policy for a
  new feature as normal work (user decision).

### Status

Merged and pushed in EN, JP and company (EN `c0e5222`…`57c09a1`, JP `1375fff`, company
`b2665e5`). Next for this track: B10, then B23 — each after the user approves its extra
findings / merge question.

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
