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
