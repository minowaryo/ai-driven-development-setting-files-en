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
