# PLAN.md

> Keep under 300 lines (`.claude/rules/60-docs.md`). Archived: 2026-08-03 – 2026-10-03 (Loop Stage 1) → `meta/history/plan-archive.md` (2026-09-30, 2026-10-03, 2026-10-06, 2026-10-09).

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
run (the hook payload format is unchanged since the 2.1.288 check). Merged (`3a88c98`) and pushed.
JP: ported 2026-10-07 together with all of Stage 1 (maintainer's decision, ahead of Stage 4).
Company: later.

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
- [x] Aggregated results in `meta/history/`; go / stop decision recorded in ADR-0017 (2026-10-07: conditional go)
- [x] Prerequisite 1 (branch `feat/fixture-literal-check`): `.claude/hooks/fixture-literal-check.sh` + its one test, wired into `/tdd` Step 4. Real script on the stored lab data: the 1 known special case caught, 0 false positives on the other 33 runs and the 4 real-project diffs; 21 test cases incl. 2 documented gaps
- [x] Prerequisite 2 (branch `fix/guard-php-arrow`): the hook no longer reads PHP `$obj->prop` / `=>` as a redirect (the false positive seen in ③); 4 cases added to the existing agent-guard test, one reproduced against the old hook
- [x] Prerequisite 3 (design + lab; built into the template when Stage 3 adopts the reviewer): narrow the reviewer input to the cycle's UC section; find a way to catch repeated rules left unchanged on the screen side
  - Design drafted 2026-10-08: `meta/design/reviewer-input-and-residuals.md` (UC slicing: prompt 99 KB → 6–15 KB; two residual hints fire on the 2 known cases only). Re-run done 2026-10-08: cost ≈ 48% of before (target 40% not met — accepted by the maintainer), both residuals now reported, no new noise on t1/t2
- [x] Company: all of Stage 1 incl. the PHP-arrow fix and the fixture-literal check ported 2026-10-08 (`249ae2d`). JP: PHP-arrow fix and fixture-literal check not ported yet
- [x] Analysis A (2026-10-08, no model usage): past Green cycles in `ihs-tech-uplift` needed 1 implementer call in 9 of 10, with no "try again" requests; people's time went to go-aheads, starting checks and late spec/UX judgments. Results: `meta/history/loop-stage2a-results.md`
- [x] Stage 2b (human A/B) — skipped (maintainer, 2026-10-08): analysis A showed a retry loop would save little, and the goal below does not need it
- [x] Goal agreed (maintainer, 2026-10-08): after approval the work runs without stopping through checks, review, in-spec fixes and a completion report, and stops only where a machine-checked guardrail says a person must decide. Merge stays human (design memo v1). Gate 4 stays human per cycle for now — so the non-stop stretch starts at Gate 4 approval; moving its start to spec approval waits until a machine check is shown, with numbers, to replace Gate 4
- [ ] Goal definition document (one page): the non-stop stretch, the stop conditions, what the person sees at the end
  - Idea (maintainer, 2026-10-08): when a screen changed, the completion report links screenshots of it (especially when Playwright ran) — saved and linked, not read back by the model, so no extra tokens
- [x] Bugs that escaped tests classified, and a viewpoint trial for test-writer (2026-10-09, ≈ $8.7): `meta/history/test-viewpoints-results.md`. Only the list viewpoint paid off — 3/3 vs 0/3 on repeat runs, mean Red cost +10% (within run-to-run spread), report +14%
- [x] `test-writer` gains two lines (approved 2026-10-09, branch `fix/test-writer-302`): the list viewpoint (only when a UC shows a list / calendar / index) and "web forms answer validation errors with a redirect, not 422" + the matching row in `coding-standards.md`. JP / company: not ported
- [ ] Decide later: frontend-path static check; spec-time viewpoints. Main users will likely be on Standard seats — keep per-cycle tokens and Gate 4 reading flat

### Status

2a and its prerequisites are done; 2b skipped. Next: the one-page goal definition, then a
guardrail inventory against its stop conditions. Usage rule: stop at about 50% weekly usage
(maintainer, 2026-10-08).

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
