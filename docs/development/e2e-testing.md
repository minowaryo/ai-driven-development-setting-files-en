# e2e-testing.md — E2E Test (Playwright)

> Related ADR: `meta/adr/ADR-0006-e2e-testing-playwright.md`
> For Feature Test / Unit Test / TDD workflow policy, see `.claude/rules/30-testing.md`.
> Read this file only when implementing E2E tests (e.g. when running `/generate-e2e-test`) — it is not loaded every session and is not needed during the normal TDD cycle.

## Scope

- Cover **only the critical flows** documented in `docs/product/use-cases.md` (do not use Playwright for exhaustive coverage)
- Examples: sign-up through login, the payment flow, screen-transition control by authorization role
- Individual screen rendering and per-field validation are covered by (server-side) Feature Tests — do not duplicate them in Playwright

## Layout & naming conventions

| Item | Convention |
|---|---|
| Location | `tests/e2e/` |
| File name | `uc{UC number}-{flow-summary}.spec.ts` (e.g. `uc001-user-registration.spec.ts`) |
| Test name | Written in English, based on the UC title in `use-cases.md` |

```ts
// tests/e2e/uc001-user-registration.spec.ts
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
npx playwright test tests/e2e/uc001-user-registration.spec.ts

# Show the report from the most recent run (pass/fail list, screenshots, video)
npx playwright show-report
```

## Changed screens and screenshots (merge plan)

`prepare-merge` names the screens a branch added or changed, and captures new screens so the
person can look at them per role without launching the app. Read this section only when a
capture is about to run. Never open the images yourself — save them and give the path; the
person looks.

**Which screens** — git only, run as given (`prepare-merge` step 2):

```bash
base=$(git merge-base HEAD "${REVIEW_SCORE_BASE_BRANCH:-main}")
git diff --name-status "$base" -- resources/js/Pages resources/js/pages resources/js/Components resources/js/components resources/js/Layouts resources/js/layouts resources/views
git ls-files --others --exclude-standard -- resources/js/Pages resources/js/pages resources/views
```

A page that is `A` or untracked is **new**; anything else except `D` is **changed**, named by its
own file (a component is named as the component). Paths that do not exist match nothing, so
they need no editing per stack.

**Capturing** — only where `playwright.config.ts` and `tests/e2e/` exist. New screens are
captured automatically; changed ones when the person asks ("take screenshots" / 「撮って」).
For a changed component, pick the pages you know use it.

1. Every screen to capture needs a line in `tests/e2e/screens.ts` (committed). Add the missing
   ones — URL and roles only, no navigation code. `roles` lists only roles that see the screen
   differently (e.g. a button for one role, none for another), at least one. A state that needs
   interaction (an open modal) is captured as first shown.

   ```ts
   // tests/e2e/screens.ts — one line per screen, read by screen-capture.spec.ts
   export type Screen = { page: string; uc: string; name: string; url: string; roles: string[] };

   export const screens: Screen[] = [
     { page: 'Schedules/Edit', uc: 'UC-042', name: 'schedule-edit', url: '/schedules/1/edit', roles: ['section-head', 'staff'] },
   ];
   ```

2. On first use, create the capture spec and the login helper (the helper logs in as a user of
   that role from the E2E seed data):

   ```ts
   // tests/e2e/screen-capture.spec.ts — runs only when CAPTURE_SCREENS is set
   import { test } from '@playwright/test';
   import { screens } from './screens';
   import { loginAs } from './support/login';

   const wanted = (process.env.CAPTURE_SCREENS ?? '').split(',').map((s) => s.trim()).filter(Boolean);

   for (const screen of screens.filter((s) => wanted.includes(s.page))) {
     for (const role of screen.roles) {
       const file = `${screen.uc.replace('-', '').toLowerCase()}_${screen.name}_${role}.png`;
       test(`capture ${file}`, async ({ page }) => {
         await loginAs(page, role);
         await page.goto(screen.url);
         await page.waitForLoadState('networkidle');
         await page.screenshot({ path: `tests/e2e/.screenshots/${file}`, fullPage: true });
       });
     }
   }
   ```

   ```ts
   // tests/e2e/support/login.ts — map each role to a user the E2E seed creates
   import type { Page } from '@playwright/test';

   const users: Record<string, { login: string; password: string }> = {
     // 'section-head': { login: '...', password: '...' },  (seed data only — never real accounts)
   };

   export async function loginAs(page: Page, role: string) {
     const user = users[role];
     if (!user) throw new Error(`no E2E user for role "${role}"`);
     await page.goto('/login');
     // fill the project's login form with user.login / user.password, submit, wait for the next page
   }
   ```

3. Run (empties the folder first; `--reporter=line` keeps the output short and stops an HTML
   report from opening and holding the command):

   ```bash
   rm -rf tests/e2e/.screenshots && CAPTURE_SCREENS="Schedules/Index,Schedules/Edit" npx playwright test tests/e2e/screen-capture.spec.ts --reporter=line
   ```

Images land in `tests/e2e/.screenshots/` (git-ignored), named `{uc}_{screen}_{role}.png`, e.g.
`uc042_schedule-edit_section-head.png`. A screen that cannot be captured (no seed record or role
user, page error, server did not start) does not stop anything; take the first reason from the
failure output and do not change seeders to make it pass.

**In the merge plan — one line**, in the reply language, names shortened to the path below the
folder without the extension, at most 5 then "and N more":

```
Screens: new Schedules/Index (2 screenshots in tests/e2e/.screenshots/), changed Schedules/Edit, DatePicker and 3 more — say "take screenshots" to capture the changed ones.
```

No screen changed → no line. No Playwright → names only. When the person asks for screenshots,
list one row per image (screen × role → path) in that reply.

## Visualizing results (optional, debugging only)

**Regular runs (CI / day-to-day checks) always use the headless `npx playwright test` above** (fastest, no display).
Only use the following individually when a human needs to visually investigate a failure.

| Method | Command | Use |
|---|---|---|
| UI Mode | `npx playwright test --ui` | Step-by-step execution, rewinding the timeline for debugging (slower) |
| HTML report | `npx playwright show-report` | View results, screenshots, and video after a headless run (no extra run needed) |
| Trace Viewer | `npx playwright show-trace trace.zip` | Detailed investigation of a failure trace (network, DOM, action history) |
