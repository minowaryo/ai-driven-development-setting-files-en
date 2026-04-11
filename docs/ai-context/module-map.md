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
