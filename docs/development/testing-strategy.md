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

## Test Framework

- **PestPHP** (recommended) or PHPUnit
- Feature Test: End-to-end tests using an HTTP client
- Unit Test: Logic tests for individual classes

## Priority

1. **Feature Test (highest priority)**
   - API endpoint tests
   - Authentication and authorization tests
   - Validation tests

2. **Unit Test (when needed)**
   - Complex calculation logic
   - State machines
   - Data transformation processing

3. **E2E Test (minimal)**
   - User registration flow
   - Payment flow
   - Critical business flows

## Test Data Management

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
