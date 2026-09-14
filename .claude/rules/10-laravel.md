# 10-laravel.md — Laravel-Specific Rules

## Architecture Guidelines

### The Domain Boundary

> Related ADR: `meta/adr/ADR-0010-domain-boundary-contract.md`

"Fat Controller is prohibited" is too vague to act on, so the boundary is stated as an
explicit contract. The **Domain Boundary** is the Service/Action layer plus the Policy
layer. Everything that decides, authorizes, or persists lives behind it.

```
Controller → FormRequest → Service / Action  (business rules, transactions)
                         → Policy            (authorization)
                         → Eloquent Model    (schema + relations only)
```

The design goal is not "write the Controller correctly" but **"the system stays correct
even when the Controller is wrong"** — an HTTP layer that sends unexpected values, skips
an optional step, or is replaced by another client must not be able to corrupt data or
bypass authorization.

### Controller

A Controller **MAY only**:

- validate the request through a `FormRequest`
- call `authorize()`
- call **exactly one** `Service` / `Action`
- format the response (view / redirect / JSON)

A Controller **MUST NOT**:

- call `DB::` or resolve the database container (`app('db')`) — transactions belong in the Service layer
- call Eloquent write methods directly — `save` / `fill` / `update` / `updateOrCreate` / `firstOrCreate` / `create` / `insert` / `upsert` / `delete` / `forceDelete` / `restore` / `increment` / `decrement` / `attach` / `detach` / `sync` / `associate`
- check roles inline (`$user->role === 'admin'`, `$user->isAdmin()`, …) — authorization goes through a Policy, per `meta/adr/ADR-0003-auth-strategy.md`
- make a decision that depends on **more than one entity** (e.g. comparing an order's quantity against a product's stock) — that is a cross-entity invariant and belongs in a Service / Action

**This does not contradict "do not put business logic in Models" below.** Enforcement
lives in the Service / Action layer; Models stay schema-and-relations only. "Model layer"
is deliberately avoided as a term here because it means different things per framework.

`.claude/hooks/domain-boundary-check.sh` flags the mechanically detectable half of this
contract during `/review`. It cannot see the fourth rule — a cross-entity decision written
in plain PHP contains no distinctive tokens — so that one relies on review.

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
