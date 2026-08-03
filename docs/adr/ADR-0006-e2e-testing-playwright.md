# ADR-0006: E2E Testing Framework Selection (Playwright)

## Status
Accepted

## Date
2026-07-15

## Context

`.claude/rules/30-testing.md` defined "E2E Test (critical user flows)" as the top tier of the test pyramid, but the concrete tool, file location, and run commands were undefined.
`docs/adr/ADR-0005-frontend-stack.md` now has each project select its own frontend stack, but regardless of which stack is chosen — including the default recommendation, Vue 3 + Inertia.js — we need a way to actually verify browser-level user interactions (screen transitions, form input, validation display) with a UI integration test.

Options considered:

1. **Playwright**
2. **Cypress**
3. **Laravel Dusk**

## Decision

Adopt **Playwright** (`@playwright/test`).

- Location: `tests/e2e/`
- Scope: only the critical flows documented in `docs/product/use-cases.md` (not for exhaustive coverage)
- Target app: a Laravel app started with `php artisan serve` (how the screen renders depends on the frontend stack selected via `docs/adr/ADR-0005-frontend-stack.md`; Playwright applies equally to Blade, Livewire, or Inertia)

## Rationale

### Why Playwright
- Supports multiple browser engines (Chromium / Firefox / WebKit) through a single API, and runs stably in CI
- Its auto-waiting mechanism curbs the flakiness that often arises from unrendered elements during SPA-style page transitions with no full reload (when Vue/React + Inertia.js is selected); it runs just as stably against ordinary full-reload transitions in Blade / Livewire
- Trace capture, screenshots, and video recording are built in, keeping the cost of investigating failures low
- Strong TypeScript affinity, making it easy to share types when the frontend uses Vue 3 / React + TypeScript (optional)
- The same E2E tool can be reused regardless of the frontend stack chosen in `docs/adr/ADR-0005-frontend-stack.md`, making it easy to share testing know-how across projects

### Alternatives rejected
- **Cypress**: constraints around multi-tab / multi-origin make it a poor fit for flows involving external redirects via Inertia (e.g. payments)
- **Laravel Dusk**: mixes test code into the PHP side, so frontend changes can't be tested using frontend-only knowledge; also adds ChromeDriver management overhead

## Consequences

### Benefits
- Critical flows (sign-up, payment, authorization-based screen transitions, etc.) can be verified in a real browser, catching UI breakage and JS exceptions that Feature Tests can't detect
- Multi-browser CI execution is straightforward

### Drawbacks / Risks
- Requires adding a Node.js build/run environment purely for testing
- E2E tests are slow to run, so scope must be disciplined to "critical flows only" (otherwise CI time balloons)
- Requires configuration to synchronize the startup timing of the Laravel app (`php artisan serve` or a test server) with Playwright

### Implementation rules
See `.claude/rules/30-testing.md` for detailed layout conventions, naming rules, and run commands.

## Related
- `.claude/rules/30-testing.md`
- `docs/development/testing-strategy.md`
- `docs/ai-context/common-commands.md`
- ADR-0005-frontend-stack
