# ADR-0020: Test-Run Budget for `/tdd` and Merges, and a Result Report at the End of Each Phase (Trial)

## Status
Trial — promote to Accepted after use on a real project, or roll back.

## Date
2026-10-13 (measured and adopted in the real project `ihs-tech-uplift` as its ADR-0034; ported here)

## Context

On a real project (Laravel + MySQL, 466 tests), one `/tdd` cycle for a small UC change took about
50 minutes, most of it waiting on test runs rather than writing code.

- The full suite (5m46s) ran four times: by `tdd-implementer`, again by the main session on the same
  tree, on the merge result (identical to the branch tip, because `main` had not moved), and once for
  measurement. Two of those runs repeated a known result.
- Subagents also re-ran unchanged test files several times (a second Red pass that added two Unit
  tests took about 15 minutes).
- Waiting costs no tokens, but every run's output is read back into context; one line per test (plus a
  deprecation note per test on that project) inflated it.
- 16 of the 466 tests used about 222 of the 317 test-seconds:
  - 12 import tests re-imported the full real data file in every test.
  - One test ran `Schema::create` in `setUp`. On MySQL that DDL commits the `RefreshDatabase`
    transaction; Laravel notices and re-migrates before the next test, so each test cost a full
    migration (~5 s).
- The cycle ended without one report of what happened (tests written, approvals, Green result,
  checks, commit and merge outcome), whether or not a bug was found.

## Decision

1. **Test-run budget** (`.claude/rules/30-testing.md`, `/tdd`, both TDD subagents):
   - Red: `test-writer` runs only the test files it created or edited. The main session runs those
     files once for the Gate 4 evidence. Nobody runs the full suite in Red.
   - Green: `tdd-implementer` runs only the target test files and never the full suite. The main
     session runs the full suite once at `/tdd` Step 4 — the cycle's authoritative run. A failure
     there goes back to the implementer and counts toward its attempts.
   - After Green, the full suite runs again only when code changed (cycle-review fixes, Refactor).
   - While iterating, a wider check may use `--exclude-group slow`; the authoritative run includes it.
   - AI-driven runs use `--compact` and read only the summary line and failure blocks.
2. **Merge-result test run** (`docs/development/git-workflow.md` §5, `prepare-merge`): skipped when
   both hold — the base has not moved since the branch was cut (`git merge-base --is-ancestor <base> <branch>`,
   so the `--no-ff` merge tree equals the branch tip), and the full suite passed in this session on
   exactly the committed tree. The `Tests:` trailer then says so. Otherwise, or when unsure, it runs.
3. **`slow` group**: a test that needs several seconds of real-data setup carries `#[Group('slow')]`
   (Pest: `->group('slow')`). Make it faster first (expensive setup once per test; no DDL in `setUp`
   on MySQL — use a temporary table).
4. **Phase reports** (chat only, no file): `/tdd`, `/commit` and `prepare-merge` always end with a
   result report — whether or not a bug was found, and also when they stop early. For `/tdd` this is
   the Step 8 completion report (ADR-0019, `feat/stretch-limits` `cc1a523`), with the test runs made
   added to its "Checks" item; `/commit` and `prepare-merge` get a fixed table in their step 8.

## Rationale

Most of the waiting came from repeated runs of the same tree and from a few tests that redo expensive
setup. Running each tree once, where its result is used, removes the repetition without lowering what
is checked: the full suite still runs once per cycle, again after any later code change, and on any
merge whose result differs from the tested tree.

### Rejected Alternatives

- **`php artisan schema:dump`**: measured migration cost was about 5–7 s per run — a small gain — and
  loading the dump needs the `mysql` client on `PATH` everywhere tests run. Revisit if migrations
  come to dominate a target-file run.
- **`php artisan test --parallel`**: needs `brianium/paratest` (a new dependency, own ADR) and
  per-process test databases.
- **Saving phase reports to files**: duplicates `git log` (merge trailers) and `PLAN.md`; little reuse.
- **Always testing the merge result**: when the base has not moved, the merge tree is byte-identical
  to the tested branch tip.

## Consequences

### Benefits
- Measured on the real project after its slow-test refactor: 466 tests / 317 test-seconds
  (5m17s–5m46s wall) → 460 tests / 151 test-seconds (2m30s–2m50s wall; about ±15 s run to run).
  Excluding `slow` then saved only 15–40 s, because the slow tests themselves were fixed.
- Expected, not yet measured: a cycle of that size about 50 → 25–30 minutes, mostly from one
  full-suite run per cycle instead of three. To be confirmed on the next real `/tdd` cycle.
- Merging the slow tests exposed a real defect the old re-run test had masked (an import command's
  lookup map not reset between runs in one process).
- Each cycle ends with one readable report.

### Drawbacks / Risks
- One authoritative full-suite run per cycle: a flaky test shows up once instead of being retried by
  chance.
- The merge-test skip relies on the session knowing that the tested tree equals the committed tree;
  when unsure, the merge result is tested.
- A merged test reports a failure less specifically; per-aspect assertion messages compensate.

## Related
- `.claude/rules/30-testing.md`, `.claude/commands/tdd.md`, `.claude/commands/commit.md`,
  `.claude/agents/test-writer.md`, `.claude/agents/tdd-implementer.md`,
  `.claude/skills/prepare-merge/SKILL.md`, `docs/development/git-workflow.md` §5,
  `.claude/rules/70-git.md`, `docs/development/testing-strategy.md`
- `ADR-0007` (TDD guideline), `ADR-0015` (Git workflow), `ADR-0016` (TDD guard), `ADR-0019` (cycle review)
