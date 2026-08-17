# /generate-e2e-test — Playwright E2E test generation command

Generate a draft Playwright E2E test for the critical flow of the UC number given as an argument.

## Files to read before running

- `docs/product/use-cases.md`
- `.claude/rules/31-e2e-testing.md`
- `docs/product/mockups/` (if present, to confirm screen structure)

## Steps

1. Read the operation flow (screen transitions, inputs, expected results) for the specified UC from `use-cases.md`
2. If the Playwright MCP server (`playwright` in `.mcp.json`) is available, connect to the locally running app (assumed started via `php artisan serve`) and inspect the actual DOM structure and accessibility attributes before deciding on selectors
   - If Playwright MCP is not available, read the relevant component under `resources/js/Pages/` and check which attributes can be used with `getByLabel` / `getByRole`
3. Save the test as `tests/e2e/{UC-number}-{flow-summary}.spec.ts` (see `.claude/rules/31-e2e-testing.md` for naming conventions)
4. After generating it, run `npx playwright test tests/e2e/{filename}` and confirm it fails if the target screen is not yet implemented

## Constraints

- Scope is **critical flows only** (do not add flows that are not documented in use-cases.md — do not misuse this for exhaustive coverage)
- Do not use real data or real credentials (test Factories or seed data only)
- Do not connect Playwright MCP to a production URL or a real data environment (local development only)

## Example

```
/generate-e2e-test UC-001
```

→ generates `tests/e2e/uc001-user-registration.spec.ts`
