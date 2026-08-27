# traceability-matrix.md — Traceability Matrix

> Manages the mapping between Requirement IDs ↔ Use Cases ↔ Code ↔ Tests.
> Used for change management, impact analysis, and audit purposes.
> Maintain this table either by hand (update it alongside each Change Tracking entry below) or by periodic bulk regeneration (see **Maintenance**) — pick whichever matches how actively this project issues RCIDs.

## Matrix

| Requirement ID | Use Case | Implementation File | Test File | Status |
|---|---|---|---|---|
| F-001 | UC-001 | `app/Http/Controllers/UserController.php` | `tests/Feature/UserControllerTest.php` | Complete |
| F-002 | UC-002 | `app/Services/UserRegistrationService.php` | `tests/Feature/UserRegistrationTest.php` | Partial |
| F-003 | UC-003 | - | - | Not Found |

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
| Complete | Implementation file(s) and a Feature/Unit test that exercises the actual behavior (not just Policy/authorization) were both located |
| Partial | Implementation exists, but test coverage is missing, indirect, or authorization-only |
| Not Found | Neither implementation nor test could be located — treat as a likely gap and verify before relying on this table |

## Usage

1. When adding a new feature: Decide the Requirement ID and UCID before requesting code generation
2. When fixing a bug: Identify the related Requirement ID to maintain traceability
3. Change management: Issue an RCID to link code and requirement changes, or — if this project instead keeps the table current by regeneration — rebuild it per the Maintenance steps below rather than hand-editing a single row

## Maintenance (regeneration, not per-commit upkeep)

For a project that would rather not hand-update this table on every commit — per-commit upkeep is what lets a table like this go stale — regenerate it periodically instead (e.g. during `/review`, or before a release):

1. Extract UC ID → title → Requirement ID(s) from `docs/product/use-cases.md` (its UC headings, followed by their `**Related requirement**` line).
2. For each UC, match its implementation file(s) under the app code and its test file(s) under the test suite by resource-name search; only read file contents when the name match is ambiguous.
3. Mark Status per the definitions above, and note any Requirement ID with no matching UC.

Last regenerated: [date, if this project uses the regeneration workflow]
