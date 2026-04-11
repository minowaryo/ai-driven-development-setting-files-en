# data-model.md — Data Model Design

> Always refer to this document before making DB changes.
> For migration policy, see `.claude/rules/20-mysql.md`.

## ER Diagram (Overview)

```
[users] ──< [user_roles] >── [roles]
   |
   └──< [posts]
           |
           └──< [comments]
```

## Table Definitions

### users

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| id | bigint | NO | auto | Primary key |
| name | varchar(255) | NO | - | Display name |
| email | varchar(255) | NO | - | Email address (unique) |
| email_verified_at | timestamp | YES | null | Email verification timestamp |
| password | varchar(255) | NO | - | Hashed password |
| created_at | timestamp | NO | now() | Created at |
| updated_at | timestamp | NO | now() | Updated at |
| deleted_at | timestamp | YES | null | Soft delete timestamp |

**Index**: `email` (unique)

---

### [table_name]

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| id | bigint | NO | auto | Primary key |
| [column] | [type] | NO/YES | [default] | [description] |
| created_at | timestamp | NO | now() | Created at |
| updated_at | timestamp | NO | now() | Updated at |

**Index**: [index definition]
**FK**: `[column]` → `[referenced_table](id)`

---

## Design Principles

- Primary keys use `bigint` (auto increment)
- Timestamps use `timestamp` (character set is utf8mb4)
- Tables requiring soft deletion include `deleted_at`
- Monetary values use `decimal(15, 2)` (float is prohibited)
- Always create an index on foreign keys

## Change History

| Date | Change | ADR |
|---|---|---|
| YYYY-MM-DD | Initial version | - |
