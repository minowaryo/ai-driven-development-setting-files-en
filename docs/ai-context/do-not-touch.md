# do-not-touch.md — Areas Not to Touch

> Both AI and humans must handle the areas listed here with care.
> If changes are necessary, always write an ADR and go through a review.

## Production Environment Configuration

| Target | Reason |
|---|---|
| `.env` (production) | Misconfigured environment variables can cause service outages |
| `config/database.php` (production connection) | Incorrect DB connection settings risk data loss |

## Authentication & Authorization Infrastructure

| Target | Reason |
|---|---|
| `app/Http/Middleware/Authenticate.php` | Risk of authentication bypass |
| All of `app/Policies/` | Risk of privilege escalation |
| Auth middleware settings in `routes/api.php` | Risk of breaking API authentication |

## Database

| Target | Reason |
|---|---|
| Already-run migration files | Editing them causes schema inconsistency |
| Old files in `database/migrations/` | Breaks consistency with the production DB |

## External Integrations

| Target | Reason |
|---|---|
| [External service name] configuration | [Reason] |

## Primary Source Materials (original-docs)

| Target | Reason |
|---|---|
| Everything under `docs/original-docs/` | Primary source materials brought in by humans. AI must not edit, delete, or move these files. |

* Reading (loading) is permitted. Modifying, creating, and deleting are not.

---

## Change Procedure

Steps for changing any of the above:

1. Create an ADR documenting the reason for the change and its scope of impact
2. Get a review from a senior engineer or team leader
3. Test thoroughly in the staging environment
4. Apply to production within a maintenance window
5. Prepare a rollback procedure in advance
