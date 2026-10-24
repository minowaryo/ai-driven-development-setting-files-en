# testing-strategy.md — Test Strategy

> For details, see `.claude/rules/30-testing.md`.

## Test Pyramid

```
         /E2E\         ← minimal (critical flows only)
        /------\
       / Feature \     ← main (HTTP request to response)
      /------------\
     /     Unit     \  ← complex logic only
    /----------------\
```

## Test-Run Budget and Slow Tests

How often tests run during `/tdd` and at merge is set in `.claude/rules/30-testing.md` ("Test-Run Budget") and `meta/adr/ADR-0020`. In short: sub-agents run only their target files, the main session runs the full suite once per cycle (and again only after a later code change), and the merged result is re-tested only when it differs from the tested branch tip.

A test that needs several seconds of real-data setup (e.g. importing a real source file) carries the `slow` group:

```php
use PHPUnit\Framework\Attributes\Group;

#[Group('slow')]
public function test_real_file_import_creates_expected_records(): void { ... }

// Pest
test('real file import creates expected records', function () { ... })->group('slow');
```

Make it faster first, then tag what is still slow:
- Run an expensive import once per test and assert everything from that run, instead of repeating it in every test.
- Never run DDL (`Schema::create`) in `setUp` on MySQL — it commits the `RefreshDatabase` transaction and forces a full re-migration before the next test. Use `$table->temporary()` for fixture tables (drop with `DROP TEMPORARY TABLE IF EXISTS`; a plain `DROP TABLE` also commits).

## Test Framework

- **PestPHP** (recommended) or PHPUnit
- Feature Test: End-to-end tests using an HTTP client
- Unit Test: Logic tests for individual classes
- E2E Test: **Playwright** (see `meta/adr/ADR-0006-e2e-testing-playwright.md`). Critical flows only

## Frontend Unit Tests (optional)

Applies when the project adds a JS/TS unit test runner (Vitest, Jest, …), whatever frontend stack `meta/adr/ADR-0005-frontend-stack.md` selected:

- Tests written in `/tdd` live under `tests/<lang>/` (e.g. `tests/js/cart.test.ts`), not next to their source under `resources/js/` — the Gate 4 lock (`.claude/hooks/agent-guard.sh`) and the approved snapshot (`.claude/hooks/tdd-snapshot.sh`) cover only `tests/` and `docs/product/`
- Import the code under test through the project's module alias (e.g. `import { discount } from '@/cart'`)
- Point the runner at that folder — e.g. Vitest `test.include: ['tests/js/**/*.test.{js,ts}']`, Jest `roots: ['<rootDir>/tests/js']` / `testMatch`
- Record the run command in `docs/ai-context/common-commands.md` (e.g. `npm run test:unit`); `/tdd`, both TDD sub-agents and `prepare-merge` then run it at the same points as `php artisan test` (Test-Run Budget, `.claude/rules/30-testing.md`)

## TDD (Red-Green-Refactor)

- Explicitly instruct the Red → Green → Refactor cycle for ordinary feature development, not just bug fixes (see `.claude/rules/30-testing.md` for the detailed steps and example prompts)
- If you want to enforce this mechanically, consider adopting `@nizos/probity` (see `meta/adr/ADR-0007-tdd-enforcement-probity.md` — optional)

## Priority

1. **Feature Test (highest priority)**
   - API endpoint tests
   - Authentication and authorization tests
   - Validation tests

2. **Unit Test (when needed)**
   - Complex calculation logic
   - State machines
   - Data transformation processing

3. **E2E Test (minimal, Playwright)**
   - User registration flow
   - Payment flow
   - Critical business flows
   - See `docs/development/e2e-testing.md` for layout and run commands

## Test Data Management

- **Database**: a dedicated MySQL test database, not Laravel's default in-memory SQLite (`SETUP.md` Step 4)
- **Factory**: Standard method for generating test data
- **DatabaseTransactions**: Data isolation between tests
- **RefreshDatabase**: When DB initialization is required

```php
uses(RefreshDatabase::class);

test('can create a user', function () {
    $user = User::factory()->create([
        'name' => 'Test User',
    ]);

    expect($user->name)->toBe('Test User');
});
```

## Tests in CI/CD

```yaml
# GitHub Actions example
- name: Run tests
  run: php artisan test --parallel
```

## Coverage Targets

| Target | Coverage Goal |
|---|---|
| Overall | 80% or higher |
| Services / Actions | 90% or higher |
| Controllers | 70% or higher (covered by Feature Tests) |
