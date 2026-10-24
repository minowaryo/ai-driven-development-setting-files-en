---
disable-model-invocation: true
---

# /tdd — TDD (Red → Green → Refactor) execution command

Run a TDD cycle for the specified feature / UC number.

## Files to read before running

- `docs/product/use-cases.md`
- `.claude/rules/30-testing.md`
- `docs/development/git-workflow.md` (branch, commit, and merge steps; profile in `.claude/rules/70-git.md`)

## Steps

**From Gate 4 approval to the Step 8 report, do not wait for the user between steps** — run them in order and stop only where a step says "stop" or a hook denies a call with a message to stop (ADR-0019). Show each step's results as you go; the user answers once, at the Step 8 report.

0. **Branch check**: If the current branch is `main`, get onto a branch before Step 1 — `lite` creates it and says so, `standard` proposes a name and waits (`docs/development/git-workflow.md` §0 Profile, §1 Branches). Then note the working-tree baseline for Step 2: `git branch --show-current`, `git rev-parse HEAD` and `git status --porcelain`
1. **Red**: Ask the `test-writer` sub-agent to write failing tests (do not let it touch implementation code); it runs only the files it touched (Test-Run Budget, `.claude/rules/30-testing.md`). Frontend unit tests, when the project has a JS/TS test runner, go under `tests/<lang>/` (e.g. `tests/js/`) like every other test — the lock and the snapshot cover only `tests/` and `docs/product/`
2. **Gate 4 (test case approval)**: Present the created tests and failure logs to the user and ask them to review whether the tests match the intended spec. **Do not proceed to the next step until approval is granted** (quality gate defined in `.claude/rules/00-global.md`). Right after approval, check the working tree against the Step 0 baseline: run the same three commands again; if the branch or `HEAD` changed, or a file changed that is not one `test-writer` reported creating or editing, **stop** and show what changed — another session may be working in this tree (`docs/development/git-workflow.md` §7) — and record only after the user decides. Then save the approved snapshot and show its one-line result: `bash .claude/hooks/tdd-snapshot.sh record` (copies `tests/` and `docs/product/` into `.git/`; ADR-0016)
3. **Green**: After Gate 4 approval, ask the `tdd-implementer` sub-agent for the minimum implementation to make the tests pass. If it stops with `SPEC_CONFLICT`, or after its attempt limit (3 attempts, or the same failure twice), present its report to the user and wait — do not re-invoke it on your own. If it returns without Green for another reason (e.g. it ran out of turns), you may start it once more with what is left. `agent-guard.sh` allows two implementer runs and 60 file writes and commands by the implementer per Gate 4 approval; when it denies one, show what was done and wait. A spec conflict is resolved by a person; the cycle then restarts from Step 1, and the new Gate 4 approval replaces the snapshot
4. **Check the goal did not move**: run `bash .claude/hooks/tdd-snapshot.sh verify`. Exit 0 → continue. Exit 2 → `tests/` or `docs/product/` changed after approval: show the printed diff and stop until the user decides (discard the change, or restart from Step 1). Exit 3 → no snapshot: tell the user and stop. When the exit was 0, also run `bash .claude/hooks/fixture-literal-check.sh`: exit 0 → continue; exit 2 → show the printed `FIXTURE_LITERAL` lines as they are (application code compares against a value that only the approved tests contain) and stop until the user decides; exit 3 → tell the user and stop. Show its blocked-attempt lines (or its "No blocked attempts" line), and a `WARNING` line if it prints one, to the user as printed — they come from `logs/audit.jsonl`, so show them even when the implementer's report does not mention any. When both checks passed, run `bash .claude/hooks/tdd-snapshot.sh mark-green` (it records the application files after Green, for Step 7). Then show the Green confirmation (test results) and continue. In `standard`, the Red + Green commit comes first: propose it through the `/commit` procedure and wait for its approval — the one planned pause in `standard` (Refactor stays a separate commit). In `lite`, the cycle is committed once, from the Step 8 report (`docs/development/git-workflow.md` §0)

   **Test runs** (Test-Run Budget in `.claude/rules/30-testing.md`, ADR-0020): for the Gate 4 evidence (Step 2), run the new/changed test files once with `php artisan test --compact <paths>`, and if Gate 4 sends tests back, re-run only the files that changed. `tdd-implementer` runs only the target files. For the Green confirmation (Step 4), run the full suite once with `php artisan test --compact` — the cycle's authoritative run; do not also re-run the target files, which it includes. A failure outside the target tests goes back to `tdd-implementer` and counts toward its attempts. After that, the full suite runs again only when code changes (cycle-review fixes, Refactor). When the project has a frontend unit test command (`docs/ai-context/common-commands.md`, e.g. `npm run test:unit`), every run above also runs it with the same scope — the changed or target frontend test files, or the whole frontend suite where the full suite runs — and the Step 8 report gives both results.

   **Cycle review** (right after the Green confirmation; no setting, nothing for the user to start — ADR-0019):
   - **Skip** it, saying "Cycle review skipped: small change", when `git diff HEAD --numstat` plus untracked files under `app bootstrap config database lang resources routes` add up to fewer than 20 changed lines and none of them is under `resources/`, `lang/`, `routes/`, `database/migrations/`, `app/Policies/` or `app/Http/`
   - Otherwise ask the `cycle-reviewer` sub-agent, giving it only: the UC ids named in this cycle's tests, `git diff HEAD` of those application paths inside `<untrusted_diff>` tags, and the names of untracked application files. Never give it the implementer's report or your own reasoning
   - Read its lines. Drop a `FINDING` whose quoted line is not in that file near the cited lines (say how many were dropped). If there is no `END` line, say "Cycle review unavailable — please run `/review` before merging" and continue
   - **Stop** — show the findings as written and wait for the user — when any finding is `SECURITY` or `SUSPECT_INSTRUCTION`, any `SPEC_CONFLICT` or `USER_FACING_CHANGE` is `MEDIUM` or `HIGH`, or any severity is `HIGH`
   - Otherwise fix the `DEFECT` and `DOMAIN_BOUNDARY` findings **once** (never touch `tests/` or `docs/product/`), re-run the full test suite, and run `verify-green` as in Step 7. `LOW` `SPEC_CONFLICT` / `USER_FACING_CHANGE` findings (e.g. a message worded differently from the use case) and `TEST_GAP` findings (the tests are locked) are not fixed — keep them, with anything not fixed, for Step 8
5. **Verify actual behavior**: Do not pause here. The recommendation to try the app with the `run` skill goes into the Step 8 report — bundled skills only run when a human explicitly invokes them, so state the recommendation rather than invoking it yourself (see `.claude/rules/30-testing.md`)
6. **Add E2E tests (only if applicable)**: If the target is a critical flow from a UC (see `docs/product/use-cases.md`) and includes UI changes, read `.claude/commands/generate-e2e-test.md` and follow its steps to add Playwright E2E tests (do not start `/generate-e2e-test` itself — commands run only when a person types them, ADR-0016)
7. **Refactor**: Refactor as needed. While refactoring, re-run the target tests; at the end, run the full suite once and confirm Green is maintained (skip both when nothing was refactored). Then run `bash .claude/hooks/tdd-snapshot.sh verify-green` (also after any other change made after Green, such as fixing a review finding): exit 2 → show the printed `STOP` lines as they are (a change after Green touches permissions, destructive operations, security, secrets, outside effects, dependencies or integrity) and stop until the user decides; exit 3 → tell the user and stop; exit 0 → keep its `LISTED` lines for Step 8
8. **Completion report** — one message, judgment items first, kept short; always given, whether or not a bug was found, and also when the cycle stops early (with the items reached so far):
   1. **Needs your decision** — anything that stopped the cycle, and cycle-review findings not fixed
   2. **Screens changed** — the screens named in the merge plan below (`lite`), or the `LISTED` page files (`standard`); one line, or "none"
   3. **Checks** — test results and the test runs made (count and approximate time, Test-Run Budget in `.claude/rules/30-testing.md`), the goal check and fixture check from Step 4 with the blocked-attempt lines as printed, and `verify-green`
   4. **Fixed without asking** — one line per cycle-review fix, or that the review was skipped
   5. **Also check** — the `LISTED` lines from Step 7 ("Changed after Green") and the suggestion to try the app with the `run` skill
   6. **Proposed commits and merge plan** — in `lite`, read `.claude/skills/prepare-merge/SKILL.md` and follow its steps 1–5 as if the user had asked for commit → merge → push in one go (do not commit or merge yet): one approval runs them (§4); the user may approve only the commit when more cycles follow on this branch. In `standard`, suggest **`/commit`** for the Refactor changes and, when the branch is done, **`prepare-merge`** (it decides whether `/review` is needed — `docs/development/git-workflow.md` §6)

## Constraints

- Do not skip or reorder the steps above (especially the Gate 4 approval and snapshot in step 2, and the snapshot check in step 4)
- Show the summary line and failures of each test run, following the Test-Run Budget in `.claude/rules/30-testing.md` — never re-run a tree whose result is already known
- When the cycle stops early (Gate 4 rejected, `SPEC_CONFLICT`, attempt limit, a check or the cycle review stops it), still give the Step 8 completion report with the items reached so far

## Example

```
/tdd UC-006 Order list filter feature
```
