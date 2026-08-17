# 31-e2e-testing.md — E2E Test (Playwright)

> Related ADR: `meta/adr/ADR-0006-e2e-testing-playwright.md`
> For Feature Test / Unit Test / TDD workflow policy, see `.claude/rules/30-testing.md`.
> Read this file only when implementing E2E tests (e.g. when running `/generate-e2e-test`) — it does not need to be read during the normal TDD cycle.

## Scope

- Cover **only the critical flows** documented in `docs/product/use-cases.md` (do not use Playwright for exhaustive coverage)
- Examples: sign-up through login, the payment flow, screen-transition control by authorization role
- Individual screen rendering and per-field validation are covered by (server-side) Feature Tests — do not duplicate them in Playwright

## Layout & naming conventions

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

## Inertia.js-specific notes (when Vue/React + Inertia.js was selected in `meta/adr/ADR-0005-frontend-stack.md`)

- Because Inertia transitions between pages without a full reload, asserting on an element immediately after `page.click()` can evaluate before rendering completes. **Always use `page.waitForURL()` after a transition, or rely on the destination element's visibility wait (`toBeVisible()`'s built-in auto-retry)**
- Avoid direct DOM manipulation such as `document.querySelector` in test code too — use Playwright's role-based selectors (`getByRole` / `getByLabel`, etc.), consistent with the ban on direct DOM manipulation in `.claude/rules/15-frontend.md`
- Validation error display depends on `useForm()`'s `errors`, so explicitly wait for the relevant message to appear after form submission
- This section does not apply to non-Inertia stacks such as Blade / Livewire — use `page.waitForURL()` / a visibility wait as you would for an ordinary full-reload transition

## Execution environment

- The target app is a Laravel app started with `php artisan serve` (how the screen renders depends on the selected frontend stack — with Vue+Inertia, Vue is rendered via Inertia)
- Configure `playwright.config.ts`'s `webServer` option to auto-start and wait for the Laravel server

## Commands

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

## Visualizing results (optional, debugging only)

**Regular runs (CI / day-to-day checks) always use the headless `npx playwright test` above** (fastest, no display).
Only use the following individually when a human needs to visually investigate a failure.

| Method | Command | Use |
|---|---|---|
| UI Mode | `npx playwright test --ui` | Step-by-step execution, rewinding the timeline for debugging (slower) |
| HTML report | `npx playwright show-report` | View results, screenshots, and video after a headless run (no extra run needed) |
| Trace Viewer | `npx playwright show-trace trace.zip` | Detailed investigation of a failure trace (network, DOM, action history) |
