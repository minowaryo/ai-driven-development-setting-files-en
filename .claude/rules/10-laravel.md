# 10-laravel.md — Laravel-Specific Rules

## Architecture Guidelines

### Controller
- Keep it thin (Fat Controller is prohibited)
- Delegate validation to `FormRequest`
- Delegate business logic to `Service` / `Action`
- Do not call `DB::` directly

### Service / Action
- Follow the single responsibility principle (one class, one responsibility)
- `Action` classes aggregate processing in the `execute()` method
- Manage transactions at the Service layer

### Model
- Explicitly declare `$fillable` (`$guarded = []` is prohibited)
- Define scopes on the Model
- Actively define relationships
- Do not put business logic in Models

#### Actor Stamps (`created_by` / `updated_by` / `deleted_by`)

Recording "who did it" on a record is **opt-in per model**. Apply it only to models where
`docs/product/use-cases.md` or `docs/architecture/data-model.md` calls for an audit trail —
do not apply it globally through a base model or a wildcard observer.

- Reuse one shared trait (`app/Concerns/HasActorStamps.php`) that fills the columns from Model events — never set them by hand in Controllers or Services
- Migration convention: one nullable FK per column, e.g. `foreignId('created_by')->nullable()->constrained('users')->nullOnDelete()` (nullable because console / system-originated writes have no authenticated actor)
- Model convention: `use HasActorStamps;` only — do not add the three columns to `$fillable` (the trait sets them, so they must not be mass-assignable)
- **Soft-delete caveat**: Eloquent's `runSoftDelete()` writes `deleted_at` with its own query and never goes through `save()`, so save-side hooks do not fire. Set `deleted_by` inside the `deleting` event with an explicit update query, and clear it on `restoring`
- Cover the trait itself with a Unit Test against a fixture model / table for all four paths (create / update / delete / restore) — do not rely on indirect coverage from Feature Tests

### Authorization
- **Always use Policy / Gate** (manual checks are prohibited)
- Explicitly call `authorize()` in Controllers
- Centralize role checks in Middleware or Policy

### FormRequest
- Write validation rules in FormRequest
- Implement `authorize()` appropriately

## Naming Conventions

| Target | Convention | Example |
|---|---|---|
| Controller | PascalCase + Controller | `UserController` |
| Service | PascalCase + Service | `UserRegistrationService` |
| Action | PascalCase + Action | `RegisterUserAction` |
| FormRequest | PascalCase + Request | `StoreUserRequest` |
| Policy | PascalCase + Policy | `UserPolicy` |
| Event | PascalCase (past tense) | `UserRegistered` |
| Job | PascalCase | `SendWelcomeEmail` |

## Prohibited Practices

- Raw SQL via `DB::statement()` (write an ADR if necessary)
- `$guarded = []`
- Business logic in Controllers
- N+1 queries (use `with()` for Eager Loading proactively)
