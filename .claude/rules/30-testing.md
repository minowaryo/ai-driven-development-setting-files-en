# 30-testing.md — Test Strategy

## Test Priority

1. **Feature Test (highest priority)**: Integration tests from HTTP request to response
2. **Unit Test**: Complex business logic and calculation logic
3. **E2E Test (Playwright)**: Critical user flows (see the end of this file for details)

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

> Related ADR: `docs/adr/ADR-0007-tdd-enforcement-probity.md`

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
- If you want to enforce this mechanically, consider adopting `@nizos/probity` (see `docs/adr/ADR-0007-tdd-enforcement-probity.md`). This guideline applies regardless of whether that tool is adopted

### Running skills after the Green phase completes

"Tests pass" does not necessarily mean "the feature works" (mocking gaps or coverage gaps in the tests can hide this). When the Green phase completes, do the following before moving to the next phase:

1. Run the **`verify` skill** to actually exercise the feature and confirm it behaves as expected
2. If the target is a UC critical flow (`docs/product/use-cases.md`) and includes UI changes, add Playwright E2E tests with **`/generate-e2e-test`**
3. After Refactor completes, run **`/review`** before merging (see `.claude/rules/50-review.md`)

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

## Commands

```bash
# Run all tests
php artisan test

# Run a specific file only
php artisan test tests/Feature/UserTest.php

# Check coverage
php artisan test --coverage
```

---

## E2E Test (Playwright)

> Related ADR: `docs/adr/ADR-0006-e2e-testing-playwright.md`

### Scope

- Cover **only the critical flows** documented in `docs/product/use-cases.md` (do not use Playwright for exhaustive coverage)
- Examples: sign-up through login, the payment flow, screen-transition control by authorization role
- Individual screen rendering and per-field validation are covered by (server-side) Feature Tests — do not duplicate them in Playwright

### Layout & naming conventions

| Item | Convention |
|---|---|
| Location | `tests/e2e/` |
| File name | `{UC-number}-{flow-summary}.spec.ts` (e.g. `uc01-user-registration.spec.ts`) |
| Test name | Written in English, based on the UC title in `use-cases.md` |

```ts
// tests/e2e/uc01-user-registration.spec.ts
import { test, expect } from '@playwright/test';

test('a user can create an account from the registration form', async ({ page }) => {
  await page.goto('/register');
  await page.getByLabel('Email').fill('test@example.com');
  await page.getByLabel('Password').fill('password');
  await page.getByRole('button', { name: 'Register' }).click();

  await page.waitForURL('/dashboard');
  await expect(page.getByText('Welcome')).toBeVisible();
});
```

### Inertia.js-specific notes (when Vue/React + Inertia.js was selected in `docs/adr/ADR-0005-frontend-stack.md`)

- Because Inertia transitions between pages without a full reload, asserting on an element immediately after `page.click()` can evaluate before rendering completes. **Always use `page.waitForURL()` after a transition, or rely on the destination element's visibility wait (`toBeVisible()`'s built-in auto-retry)**
- Avoid direct DOM manipulation such as `document.querySelector` in test code too — use Playwright's role-based selectors (`getByRole` / `getByLabel`, etc.), consistent with the ban on direct DOM manipulation in `.claude/rules/15-frontend.md`
- Validation error display depends on `useForm()`'s `errors`, so explicitly wait for the relevant message to appear after form submission
- This section does not apply to non-Inertia stacks such as Blade / Livewire — use `page.waitForURL()` / a visibility wait as you would for an ordinary full-reload transition

### Execution environment

- The target app is a Laravel app started with `php artisan serve` (how the screen renders depends on the selected frontend stack — with Vue+Inertia, Vue is rendered via Inertia)
- Configure `playwright.config.ts`'s `webServer` option to auto-start and wait for the Laravel server

### Commands

```bash
# Initial setup
npm install -D @playwright/test
npx playwright install

# Run all E2E tests
npx playwright test

# Run a specific file only
npx playwright test tests/e2e/uc01-user-registration.spec.ts

# Show the report from the most recent run (pass/fail list, screenshots, video)
npx playwright show-report
```

### Visualizing results (optional, debugging only)

**Regular runs (CI / day-to-day checks) always use the headless `npx playwright test` above** (fastest, no display).
Only use the following individually when a human needs to visually investigate a failure.

| Method | Command | Use |
|---|---|---|
| UI Mode | `npx playwright test --ui` | Step-by-step execution, rewinding the timeline for debugging (slower) |
| HTML report | `npx playwright show-report` | View results, screenshots, and video after a headless run (no extra run needed) |
| Trace Viewer | `npx playwright show-trace trace.zip` | Detailed investigation of a failure trace (network, DOM, action history) |
