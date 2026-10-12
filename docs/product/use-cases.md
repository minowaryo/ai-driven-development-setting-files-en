# use-cases.md — Use Case Definitions

> **Importance: ★★★★★ (Most Critical)**
> Audience: Final human review checkpoint
> Specification quality is determined here. AI code generation quality depends on the quality of this document.

---

## Review Criteria

Verify that each use case defines the following:

- [ ] Is the Actor clearly defined?
- [ ] Are inputs defined?
- [ ] Are outputs defined?
- [ ] Are errors defined?
- [ ] Are business rules stated?
- [ ] Are state changes clearly defined?
- [ ] Are permissions considered?
- [ ] Are all CRUD operations covered?
- [ ] For each list, calendar or index: is it stated what each role sees (including records linked through a capability, e.g. "sessions I train")?
- [ ] Is the behavior defined when there is nothing to show, and when the user submits with no change?
- [ ] Do bulk or irreversible operations state what the user confirms first (and what they see before confirming)?
- [ ] Where the same figure appears on more than one screen, is it defined once so the screens agree?

> `bash .claude/hooks/spec-lint.sh` pre-checks the structure (UC ids, Actor / Basic Flow /
> Error Cases / Permissions present, requirement links, leftover placeholders) — spend the
> review on whether the content is right and complete.
> UC ids are `UC-NNN` here and in other documents; file names drop the hyphen
> (`screen-UC006-…`, `uc006-…`).

---

## Use Case Template

---

### UC-001: [Use Case Name]

**Actor**: [e.g. Admin]
**Preconditions**: [State that must be satisfied before executing this use case]
**Related requirement**: F-001

#### Basic Flow
1. [Actor] performs [action]
2. System performs [processing]
3. System returns [result]

#### Inputs
| Field | Type | Required | Validation |
|---|---|---|---|
| [field name] | [type] | Required / Optional | [rule] |

#### Outputs
| Field | Type | Description |
|---|---|---|
| [field name] | [type] | [description] |

#### Business Rules
- [Rule 1]
- [Rule 2]

#### Error Cases
| Case | HTTP Status | Message |
|---|---|---|
| [error condition] | 400 / 401 / 403 / 404 / 422 | [message] |

#### Permissions
- [Actor]: Allowed
- [Other Actor]: Not allowed (403)

---

### UC-002: [Use Case Name]

[Repeat the template above]

---

## Approval Record

| Date | Reviewer | Result | Comment |
|---|---|---|---|
| YYYY-MM-DD | [Name] | Approved / Rejected | [Comment] |
