# 50-review.md — PR Review Guidelines

## Pre-Review Self-Check (Author)

Check these yourself before opening a PR:

- [ ] Is it linked to requirements in `docs/product/use-cases.md`?
- [ ] Is there a Feature Test?
- [ ] Did you follow TDD (Red → Green → Refactor) — did the test exist before the implementation?
- [ ] Does `php artisan test` pass?
- [ ] If a critical flow changed, did you add a Playwright E2E test and does `npx playwright test` pass?
- [ ] Is code style clean after running `./vendor/bin/pint`?
- [ ] Are there any dangerous operations in the migration?
- [ ] Are secrets or PII included in the code?
- [ ] Have any unrelated files been edited?
- [ ] Do Vue components use `<script setup>` + the Composition API (if Vue+Inertia was selected and there is a frontend change; if another stack was selected, check against that stack's rule file instead)?
- [ ] Do `npm run lint` / `npm run build` pass (if there is a frontend change)?

## Reviewer Perspectives

### Features & Design
- [ ] Does the implementation match the requirements (use-cases.md)?
- [ ] Does it follow existing design patterns?
- [ ] Is the Controller too fat (Fat Controller)?
- [ ] Is authorization going through Policy / Gate?

### DB & Performance
- [ ] Is the migration backward-compatible?
- [ ] Are there any N+1 queries?
- [ ] Are the necessary indexes in place?

### Security
- [ ] Is validation appropriate?
- [ ] Is there an authorization check?
- [ ] Are secrets included?
- [ ] Is PII appearing in logs?

### Tests
- [ ] Do the tests cover happy path and error cases?
- [ ] Are test names clear and descriptive?
- [ ] Are E2E tests scoped to "critical flows only" (no misuse for exhaustive coverage)?

### Frontend (applied based on the selection in `docs/adr/ADR-0005-frontend-stack.md`)

The items below apply when Vue 3 + Inertia.js + Pinia was selected. If another stack was selected, substitute the perspectives from that stack's implementation rule file instead.

- [ ] Are Page components under `Pages/` and shared components under `Components/`?
- [ ] Do the Props / Emits declarations match the project's language setting (TS: type-parameter form / JS: runtime declaration form)?
- [ ] Is logic separated into Composables / Stores (no Fat components)?
- [ ] Is there no direct DOM manipulation?
- [ ] Are validation errors handled via Inertia's `useForm()`?

### Documentation
- [ ] Are design changes reflected in the docs?
- [ ] Has a decision been made that requires a new ADR?

## AI Review Command

```
/review
```

See `.claude/commands/review.md`.
