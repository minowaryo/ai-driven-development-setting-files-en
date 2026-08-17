# coding-standards.md — Coding Standards

> For detailed Laravel rules, see `.claude/rules/10-laravel.md`.

## Basic Policy

- PSR-12 compliant
- Format with Laravel Pint (required in CI)
- PHPStan Level 6 or higher must pass

## PHP

```php
<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\User;

final class RegisterUserService
{
    public function execute(array $data): User
    {
        // implementation
    }
}
```

### Naming Conventions

| Target | Convention | Example |
|---|---|---|
| Class names | PascalCase | `UserService` |
| Method names | camelCase | `findById()` |
| Variable names | camelCase | `$userId` |
| Constants | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| DB columns | snake_case | `created_at` |

### Type Declarations

- Add `declare(strict_types=1)` to all files
- Always declare argument and return types
- Express nullable as `?Type` (avoid overusing `mixed`)

## Comments

- Do not comment self-evident code
- Comment on **why** it was written that way (not **what** it does)
- PHPDoc is written only for public APIs

```php
// OK: explains the why
// Using MySQL ROW LOCK to prevent concurrent bookings by the same user
$booking->lockForUpdate()->find($id);

// NG: explains what (obvious from reading the code)
// Get the user
$user = User::find($id);
```

## API Conventions

- Use a consistent response shape for both success and error cases (do not let it vary from endpoint to endpoint)

```json
// Success
{
  "data": { "id": 1, "name": "example" }
}

// Error (e.g. validation errors, where multiple fields may be involved)
{
  "message": "The given data was invalid.",
  "errors": {
    "email": ["The email field is required."]
  }
}
```

- For list endpoints, put pagination info in a sibling `meta` key (alongside `data`)
- Use HTTP status codes meaningfully (200/201/204/401/403/404/422/500, etc. — do not return 200 for everything)
- Write an ADR (`docs/adr/`) for any breaking change to the response format

## Error Handling Policy

Handle errors differently depending on their type. Do not swallow all errors with the same log level and the same response.

| Type | Example | HTTP Status | Log Level |
|---|---|---|---|
| Validation error | FormRequest validation failure | 422 | Not logged (an expected input mistake) |
| Auth / authz error | Not logged in / insufficient permissions | 401 / 403 | `info` (the attempt is recorded, but it isn't an anomaly) |
| Business error | Insufficient stock, inconsistent state, etc. | 400 / 409 | `warning` |
| System error | DB connection lost, external API failure, etc. | 500 | `error` (includes stack trace, but never log PII in production — see `.claude/rules/40-security.md`) |

- Create dedicated exception classes for business errors under `app/Exceptions/`, and centralize the conversion to a response by type in `Handler` (do not scatter try/catch blocks across Controllers)
- Keep the message shown to the user separate from the details recorded in logs (do not include internal implementation details in user-facing messages)

## Git

- Commit messages should express intent in English
- One commit, one change (do not mix changes)
- Keep PRs small (a reviewable size)

### Commit Message Format

```
[type]: [summary of change]

[detailed explanation if needed]
```

type: `feat` / `fix` / `refactor` / `test` / `docs` / `chore`

Example:
```
feat: add pagination to user list API

Implemented cursor-based pagination for infinite scroll support.
See ADR-0005 for the reason for switching from offset-based.
```
