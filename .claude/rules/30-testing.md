# 30-testing.md — Test Strategy

## Test Priority

1. **Feature Test (highest priority)**: Integration tests from HTTP request to response
2. **Unit Test**: Complex business logic and calculation logic
3. **E2E Test**: Critical user flows

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
