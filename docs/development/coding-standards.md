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
