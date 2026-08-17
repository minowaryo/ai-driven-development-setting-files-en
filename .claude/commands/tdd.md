# /tdd — TDD (Red → Green → Refactor) execution command

Run a TDD cycle for the specified feature / UC number.

## Files to read before running

- `docs/product/use-cases.md`
- `.claude/rules/30-testing.md`

## Steps

1. **Red**: Ask the `test-writer` sub-agent to write failing tests (do not let it touch implementation code)
2. **Gate 4 (test case approval)**: Present the created tests and failure logs to the user and ask them to review whether the tests match the intended spec. **Do not proceed to the next step until approval is granted** (quality gate defined in `.claude/rules/00-global.md`)
3. **Green**: After Gate 4 approval, ask the `tdd-implementer` sub-agent for the minimum implementation to make the tests pass
4. Present the execution results (Green confirmation) to the user
5. **Verify actual behavior**: Run the `run` skill to launch the app and confirm the feature actually works
6. **Add E2E tests (only if applicable)**: If the target is a critical flow from a UC (see `docs/product/use-cases.md`) and includes UI changes, run `/generate-e2e-test` to add Playwright E2E tests
7. **Refactor**: Refactor as needed. After refactoring, always re-run the tests and confirm Green is maintained
8. Summarize the final diff and test results, and tell the user to **run `/review` before merging**

## Constraints

- Do not skip or reorder the steps above (especially the Gate 4 approval in step 2)
- After each phase completes, run the corresponding test command (e.g. `php artisan test` — see `.claude/rules/30-testing.md` for details) and show the results

## Example

```
/tdd UC-006 Order list filter feature
```
