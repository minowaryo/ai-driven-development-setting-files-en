# 30-testing.md — Test Strategy

## Test Priority

1. **Feature Test (highest priority)**: Integration tests from HTTP request to response
2. **Unit Test**: Complex business logic and calculation logic
3. **E2E Test (Playwright)**: Critical user flows (see `.claude/rules/31-e2e-testing.md` for details; no need to read it during the normal TDD cycle)

## Files to Read Before Writing Tests

- `docs/product/use-cases.md` — source for test case names and coverage scope (UCs define the baseline for happy path / error cases / authorization)
- `docs/architecture/data-model.md` — verify DB assertions, Factory types, and constraints
- `docs/product/mockups/` — verify screen structure and operation flow for E2E tests (if they exist)

## Basic Rules

- Always add a Feature Test for every change
- For bug fixes, write a regression test first (TDD)
- Do not mock the DB in tests (use a real DB)
- Use Factories to generate test data
- Name test cases based on UC titles and flows from `use-cases.md`

---

## TDD Workflow (shared by Claude Code / Codex)

> Related ADR: `meta/adr/ADR-0007-tdd-enforcement-probity.md`

Claude Code / Codex tend to write the implementation first and bolt tests on afterward.
**Explicitly instruct the Red → Green → Refactor cycle for ordinary feature development, not just bug fixes.**

### Cycle

1. **Red**: Have it write only a failing test. Do not let it write implementation code in the same turn
2. **Green**: Have it write only the minimum implementation to make that test pass (do not let it implement more than the test requires)
3. **Refactor**: Have it refactor while keeping the test Green

### Example prompts

```
# Red
"Write a failing Feature Test for XYZ. Do not write any implementation code yet."

# Green
"Implement the minimum needed to make this test pass. Do not do anything beyond what the test requires."

# Refactor
"Clean up the implementation while keeping the tests Green."
```

### Gate 4 — Test Case Approval

- Do not bundle the Red phase and the Green phase into a single request (doing so makes it easy for the AI to bend the tests to fit the implementation)
- After the tests are written in the Red phase, **a human must review and approve the test content before moving on to the Green phase (implementation)** (Gate 4 in `.claude/rules/00-global.md`)
  - Review points: does the test fail for the intended reason, and do the test cases cover the happy path / error cases / authorization described in `use-cases.md`?
  - The `/tdd` command will not auto-advance to the Green phase until this approval is given
- If you want to enforce this mechanically, consider adopting `@nizos/probity` (see `meta/adr/ADR-0007-tdd-enforcement-probity.md`). This guideline applies regardless of whether that tool is adopted

### Running skills after the Green phase completes

"Tests pass" does not necessarily mean "the feature works" (mocking gaps or coverage gaps in the tests can hide this). When the Green phase completes, do the following before moving to the next phase:

1. Run the **`run` skill** to actually launch the app and confirm the feature behaves as expected
2. If the target is a UC critical flow (`docs/product/use-cases.md`) and includes UI changes, add Playwright E2E tests with **`/generate-e2e-test`**
3. After Refactor completes, run **`/review`** before merging (see `.claude/rules/50-review.md`)
   - The review-score auto-computed as Step 0 of `/review` (see `meta/adr/ADR-0009-review-escalation-mechanism.md`) automatically selects the normal or enhanced review level

## Naming Convention

```php
// Feature Test: be clear about what is being tested
test('admin can retrieve the user list', function () { ... });
test('regular user cannot access the user list', function () { ... });
test('unauthenticated user is redirected to the login page', function () { ... });
```

## Test Structure (AAA Pattern)

```php
test('example', function () {
    // Arrange: prepare test data and preconditions
    $user = User::factory()->create();

    // Act: execute the operation under test
    $response = $this->actingAs($user)->get('/dashboard');

    // Assert: verify the expected result
    $response->assertOk();
});
```

## Always Test

- [ ] Happy path (normal flow)
- [ ] Authentication and authorization (unauthenticated / unauthorized)
- [ ] Validation errors
- [ ] Boundary values and edge cases
- [ ] Side effects of delete and update operations

## CRUD Coverage Rule When Adding a Data Model

When a new data model (migration / Eloquent Model) is added, cover the create/edit/delete operations that **`docs/product/use-cases.md` defines as user-facing operations for that model** with Feature Tests (also cover list/detail retrieval if the UC includes them).

- Scope is limited to "operations that use-cases.md actually defines as provided." Do not add unnecessary edit/delete functionality or tests **just to satisfy this rule** for models that have no such functionality defined — pivot tables only manipulated through a parent model, reference-only master data, log/audit tables, etc. (out-of-scope implementation is prohibited; see `.claude/rules/00-global.md`)
- For each provided operation, prepare at least one test case per model (a single integration test covering a full flow is acceptable)
- For operations involving authorization (Policy), verify both the "authorized" and "unauthorized" cases for each provided operation
- Cross-check coverage against the model definitions in `docs/architecture/data-model.md` and the operation scope in `docs/product/use-cases.md` to confirm nothing is missed
- Confirm this rule is satisfied when running `/review` (see `.claude/rules/50-review.md`)

## Commands

```bash
# Run all tests
php artisan test

# Run a specific file only
php artisan test tests/Feature/UserTest.php

# Check coverage
php artisan test --coverage
```

> The E2E Test (Playwright) policy, layout conventions, and run commands live in `.claude/rules/31-e2e-testing.md` (only needed when running `/generate-e2e-test` — not part of the normal TDD cycle).
