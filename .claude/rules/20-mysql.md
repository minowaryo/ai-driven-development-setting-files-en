# 20-mysql.md — MySQL-Specific Rules

## Migration Policy

### Basic Rules
- **Be mindful of backward compatibility** (production DB is affected)
- Drop or rename columns gradually (deprecate first)
- Add NOT NULL only after setting a default value
- Never edit a migration file once it has been run
- Always use `utf8mb4` for character set and `utf8mb4_unicode_ci` for collation

### Safe Migration Order (example: dropping a column)
```
Step 1: Remove column references from application code
Step 2: Deploy and verify
Step 3: Run the column-drop migration
```

### Dangerous Operations (ADR required)
- `DROP TABLE`
- `DROP COLUMN`
- Changing a column type (MySQL locks all rows during column type changes)
- `ALTER TABLE` on large datasets (consider using Online DDL)
- Migrations involving data transformation on existing data

### Notes for Laravel Migrations
```php
// OK: explicitly specify utf8mb4
Schema::create('users', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->timestamps();
    $table->softDeletes();
});

// NG: timestampsTz() is unnecessary (use timestamp type in MySQL)
```

## Index Design

- Always add an index on foreign keys
- Consider adding indexes on columns used in search conditions
- Order composite indexes by highest cardinality first, then by query filter order
- Use `FULLTEXT INDEX` for full-text search (`pg_trgm` is not needed)
- Remove unused indexes (they impact write performance)

## Locking

- Avoid long-running transactions
- Use `lockForUpdate()` / `sharedLock()` with caution
- MySQL is prone to deadlocks — unify the order of table access
- If there is a deadlock risk, document it in an ADR

## Query Policy

- Prefer Eloquent Builder
- Add a comment explaining the reason when raw SQL is necessary
- Verify the execution plan with `EXPLAIN` before releasing
- Always resolve N+1 queries (use `with()` for Eager Loading)
- Avoid `SELECT *` (retrieve only the required columns)

## Types & Constraints

- Set an appropriate `length` for `string` columns (default is 255)
- Use `decimal` for monetary values (`float` / `double` are prohibited)
- Use `timestamps()` for timestamps (MySQL `timestamp` type)
- Use `softDeletes()` for soft deletion
- Use `json()` columns for JSON data (MySQL 5.7.8+)

## Strict Mode

- Enable MySQL strict mode (`strict: true` in `config/database.php`)
- Be aware that strict mode causes errors for empty string NULL inserts and zero dates

## Character Set

- Use `utf8mb4` for tables and columns (supports emoji)
- Set `charset: 'utf8mb4'` / `collation: 'utf8mb4_unicode_ci'` in `config/database.php`
