# traceability-matrix.md — Traceability Matrix

> Manages the mapping between Requirement IDs ↔ Use Cases ↔ Code ↔ Tests.
> Used for change management, impact analysis, and audit purposes.

## Matrix

| Requirement ID | Use Case | Implementation File | Test File | Status |
|---|---|---|---|---|
| F-001 | UC-001 | `app/Http/Controllers/UserController.php` | `tests/Feature/UserControllerTest.php` | Complete |
| F-002 | UC-002 | `app/Services/UserRegistrationService.php` | `tests/Feature/UserRegistrationTest.php` | In Progress |
| F-003 | UC-003 | - | - | Not Started |

## Change Tracking

| Change ID (RCID) | Change Summary | Affected Requirements | Change Date | Approver |
|---|---|---|---|---|
| CHG-001 | [change summary] | F-001 | YYYY-MM-DD | [Name] |

## RCID Naming Convention

```
CHG-[4-digit sequential number]
e.g. CHG-0001, CHG-0042
```

## Status Definitions

| Status | Meaning |
|---|---|
| Not Started | Defined in use-cases but not yet implemented |
| In Progress | Currently in development |
| Complete | Implementation, testing, and review all done |
| On Hold | Temporarily paused due to priority changes, etc. |
| Deprecated | No longer needed due to requirement deletion or change |

## Usage

1. When adding a new feature: Decide the Requirement ID and UCID before requesting code generation
2. When fixing a bug: Identify the related Requirement ID to maintain traceability
3. Change management: Issue an RCID to link code and requirement changes
