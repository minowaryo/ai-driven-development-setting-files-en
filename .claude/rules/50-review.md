# 50-review.md — PR Review Guidelines

## Automatic Review-Intensity Determination (review-score)

> Related ADR: `meta/adr/ADR-0009-review-escalation-mechanism.md`

When `/review` runs, its first step (Step 0) automatically executes the `review-score` script, which scores **the diff from the point where the current branch diverged from `main` (`git merge-base main HEAD`) to the current HEAD**. It keeps no state file. Since it's local processing that never calls AI, computing it on every `/review` invocation costs essentially nothing and takes negligible time.

- The score is a weighted sum of "number of changed files," "number of changed lines," and "matches against sensitive paths" (DB migrations, Policies, auth-related directories, etc.)
- If the score exceeds the threshold, the review runs at the enhanced level (a Workflow with multiple perspectives and adversarial verification); at or below the threshold, it runs at the normal level
- The score's scope is automatically separated per branch, so moving between multiple branches doesn't get affected by another branch's diff (only the diff on your own branch since it diverged from `main` is considered)
- It does not distinguish between a cohesive Phase-unit development effort and an ad-hoc small fix outside a Phase — either is picked up automatically as long as it's part of the diff since diverging from `main`, so developers don't need to classify anything
- Running `/review` multiple times on the same branch re-evaluates the entire branch diff each time, including already-reviewed parts (the diff is not reset after each review). This can cause redundant re-checking, which is accepted as a trade-off
- This mechanism automatically determines "what intensity to review at when a review runs" — it does not "prompt you to run `/review` in the first place" (not automating the invocation itself is a deliberate design choice, Option A; see `meta/adr/ADR-0009-review-escalation-mechanism.md` for details). The timing of when to run it still follows the operating rule in `.claude/rules/30-testing.md` (after Refactor completes, before merging)

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
- [ ] Are privileged / destructive operations recorded on the `audit` channel with the fixed minimal schema (`.claude/rules/40-security.md`)?

### Tests
- [ ] Do the tests cover happy path and error cases?
- [ ] Are test names clear and descriptive?
- [ ] Are E2E tests scoped to "critical flows only" (no misuse for exhaustive coverage)?
- [ ] If a new data model (migration) was added, are the create/edit/delete operations that `use-cases.md` defines as provided for it covered by Feature Tests (do not demand extra implementation/tests for operations not defined there; see the CRUD coverage rule in `.claude/rules/30-testing.md`)?

### Frontend (applied based on the selection in `meta/adr/ADR-0005-frontend-stack.md`)

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
