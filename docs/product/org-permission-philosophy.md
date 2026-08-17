# Organizational Permission & Role Philosophy

> This file defines the business-side permission philosophy of "who should be able to do what, and why."
> Technical implementation (Policy/Gate/Middleware) is documented in `docs/architecture/authz-authn.md`,
> which references this document as its rationale (Why).

---

## Role List

| Role | Target Users | Permission Summary |
|---|---|---|
| `[ROLE_NAME]` | [e.g. Administrator] | [e.g. View/edit/delete all resources] |
| `[ROLE_NAME]` | [e.g. Regular user] | [e.g. Can only operate on resources they own] |

---

## Permission Design Principles

- [e.g. Apply the Principle of Least Privilege]
- [e.g. No access whatsoever to another organization's data (multi-tenant isolation)]
- [e.g. Delete operations are restricted to higher-privileged roles only]

---

## Resource × Role Matrix

| Resource | `[ROLE_A]` | `[ROLE_B]` |
|---|---|---|
| [e.g. User management] | CRUD | View only |
| [e.g. Billing information] | CRUD | Not allowed |

---

## Rules for Changes

- When changing the role/permission model, update this file and `docs/architecture/authz-authn.md` in the same PR
- Always consider creating an ADR (`docs/adr/`) for permission-related changes (see `.claude/rules/60-docs.md`)
