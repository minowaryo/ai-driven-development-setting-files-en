# module-map.md — Module & Directory Responsibility Map

## Backend (Laravel)

| Path | Role | Notes |
|---|---|---|
| `app/Http/Controllers/` | Receive HTTP requests and return responses | Fat Controller is prohibited |
| `app/Http/Requests/` | Validation rules | Always use FormRequest |
| `app/Http/Middleware/` | Authentication, authorization, logging | Apply globally with caution |
| `app/Services/` | Business logic | One class, one responsibility |
| `app/Actions/` | Single-operation actions | Aggregate in `execute()` method |
| `app/Models/` | Eloquent models and relationships | Do not write business logic here |
| `app/Policies/` | Authorization rules | Always call via Gate |
| `app/Events/` | Domain events | Use past-tense names |
| `app/Listeners/` | Event handlers | Offload heavy processing to Queue |
| `app/Jobs/` | Async jobs | Run via Horizon |

## Frontend (fill in based on the stack selected in `meta/adr/ADR-0005-frontend-stack.md`)

> The table below is an example for when the selected stack is **Vue 3 + Inertia.js + Pinia** (the default recommendation).
> If Blade / Livewire / React / etc. was selected instead, replace it with that stack's directory layout.

| Path | Role | Notes |
|---|---|---|
| `resources/js/Pages/` | Inertia page components (one per route) | Returned via the Controller's `return` |
| `resources/js/Components/` | Generic / shared components | Keep single-responsibility and reusable |
| `resources/js/Composables/` | Composables for logic separation (`use~` naming) | Consolidate component logic here |
| `resources/js/stores/` | Pinia stores (`useXxxStore` naming) | Do not put local state here |
| `resources/js/app.js` | Entry point | Inertia initialization |

## Database

| Path | Role |
|---|---|
| `database/migrations/` | Schema change history (do not edit after running) |
| `database/factories/` | Test data generation |
| `database/seeders/` | Initial data seeding |

## Tests

| Path | Role |
|---|---|
| `tests/Feature/` | Integration tests (highest priority) |
| `tests/Unit/` | Unit tests (business logic) |

## Docs

| Path | Role | Updated by |
|---|---|---|
| `docs/ai-context/` | AI-facing summary (keep short and accurate) | Developers |
| `docs/product/` | Requirements and use cases | Business side |
| `docs/architecture/` | System design | Developers |
| `docs/adr/` | Architecture Decision Records | Developers |
| `docs/development/` | Development process | Developers |
| `docs/security/` | Security policy | Security team |

## Do-Not-Touch Areas

See `docs/ai-context/do-not-touch.md`.
