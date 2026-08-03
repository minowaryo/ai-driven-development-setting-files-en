# common-commands.md — Frequently Used Commands

## Tests

```bash
# Run all tests
php artisan test

# Run a specific file
php artisan test tests/Feature/UserTest.php

# With coverage
php artisan test --coverage

# Parallel execution (faster)
php artisan test --parallel
```

## E2E Tests (Playwright)

> See the "E2E Test (Playwright)" section in `.claude/rules/30-testing.md` for details.

```bash
# Initial setup
npm install -D @playwright/test
npx playwright install

# Run all E2E tests
npx playwright test

# Run a specific file only
npx playwright test tests/e2e/uc01-user-registration.spec.ts

# UI mode (for debugging)
npx playwright test --ui

# Show the report from the most recent failure
npx playwright show-report
```

## Playwright MCP (browser automation tool, optional)

> Already defined in `.mcp.json`. See `docs/adr/ADR-0008-tdd-e2e-harness-tooling.md` for details.
> Use only against a local development environment — never connect it to a production URL or a real-data environment.

```bash
# On first use, Claude Code will show an approval prompt for .mcp.json — approve it
# (to add it manually instead)
claude mcp add playwright npx @playwright/mcp@latest
```

## TDD Enforcement Tool (Probity, optional)

> See `docs/adr/ADR-0007-tdd-enforcement-probity.md` for details.

```bash
# Initial setup
npm install -D @nizos/probity

# Check for rule violations (based on probity.config.ts)
npx probity check
```

## Code Style

```bash
# Format (auto-fix)
./vendor/bin/pint

# Check only (no fixes)
./vendor/bin/pint --test

# Static analysis
./vendor/bin/phpstan analyse
```

## Database

```bash
# Run migrations
php artisan migrate

# Rollback
php artisan migrate:rollback

# Reset DB (development only)
php artisan migrate:fresh --seed

# Check migration status
php artisan migrate:status
```

## Application

```bash
# Start development server
php artisan serve

# Clear caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Start queue worker (development)
php artisan queue:work

# Start scheduler (development)
php artisan schedule:work
```

## Code Generation (Artisan)

```bash
# Controller
php artisan make:controller UserController --resource

# Model + Migration + Factory + Seeder
php artisan make:model User -mfs

# FormRequest
php artisan make:request StoreUserRequest

# Policy
php artisan make:policy UserPolicy --model=User

# Action / Service (custom)
php artisan make:class Actions/RegisterUserAction
```

## Composer

```bash
# Install dependencies
composer install

# Add a package
composer require [package]

# Vulnerability check
composer audit

# Regenerate autoload
composer dump-autoload
```
