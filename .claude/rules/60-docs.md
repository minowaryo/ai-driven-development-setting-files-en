# 60-docs.md — Documentation Update Rules

## Change-to-Document Mapping

| Change | Document(s) to Update |
|---|---|
| DB schema change | `docs/architecture/data-model.md` |
| API added / changed | `docs/architecture/overview.md` |
| Auth / authz change | `docs/architecture/authz-authn.md` |
| Architecture decision | `docs/adr/ADR-XXXX-xxx.md` (create new) |
| Coding standards change | `docs/development/coding-standards.md` |
| Test strategy change | `docs/development/testing-strategy.md` |
| New common command | `docs/ai-context/common-commands.md` |
| New domain / module added | `docs/ai-context/module-map.md` |
| New term added | `docs/ai-context/glossary.md` |
| Change to do-not-touch areas | `docs/ai-context/do-not-touch.md` |
| UI / design spec change | `docs/product/ui-guidelines.md` |
| Mockup added / updated | `docs/product/mockups/README.md` (update screen list) |
| Mockup feedback incorporated into UC | `docs/product/use-cases.md` + `docs/product/mockups/README.md` |
| Frontend screen / component added | `docs/ai-context/module-map.md` |
| State management (store for whichever stack was selected — Pinia, Vuex, Redux, etc.) added / changed | `docs/architecture/overview.md` |
| Frontend technology decision (library change, etc.) | `docs/adr/ADR-XXXX-xxx.md` (create new) |
| Business policy change for permissions / roles | `docs/product/org-permission-philosophy.md` + `docs/architecture/authz-authn.md` |
| User-facing feature / usage change | `docs/product/user-guide.md` |
| UAT scenario / result additions (optional) | `docs/product/uat-scenarios.md` / `docs/product/uat-results/` (see the UAT section in `.claude/rules/00-global.md`; non-blocking) |
| Resolved a library/framework-specific pitfall | `docs/ai-context/known-pitfalls.md` (not loaded every time, so it doesn't need to be in the same commit as the code change — append whenever one is resolved) |
| New data model added (CRUD coverage) | see `.claude/rules/30-testing.md` (CRUD coverage rule) |
| New dev/test credential or API key location noted | `docs/credentials/README.md` (never commit the actual secret) |
| Error-handling or response-format convention change | `docs/development/coding-standards.md` |
| Gate condition / quality-gate process changes | `.claude/rules/00-global.md` (details table, absolute prohibitions) + `SETUP.md` (Step procedures) + `AGENTS.md` (for Codex — Gate definitions are duplicated there, so all 3 files need to stay in sync) |
| Human/AI role-division change (new adoption path, new AI capability, etc.) | `docs/development/ai-workflow.md` (Role Breakdown) + a pointer amendment on `meta/adr/ADR-0004` if it's policy-level (see its 2026-07-15 / 2026-09-15 amendment notes for the style) |
| New AI entry point added (skill or command) | `docs/ai-context/common-commands.md` (entry-point table) + `README.md` (directory tree). Choose `.claude/skills/` vs `.claude/commands/` by the criterion in `meta/adr/ADR-0012-skills-vs-commands.md` |
| Git workflow change (branches, commits, push, merge, pre-merge check) | `docs/development/git-workflow.md` (+ `.claude/rules/70-git.md` only for the always-on core) — other files keep at most a one-line pointer (+ an ADR if policy-level; see `meta/adr/ADR-0015`) |

## Documentation Update Principles

1. **Update documentation in the same commit as the code change**
2. Specification changes should be documented before coding (document-first)
3. ADRs must always include "why this decision was made" (not just What, but Why)
4. Keep `docs/ai-context/` short and accurate (it is the AI-facing summary layer)

## When to Write an ADR

Always create an ADR when making the following decisions:

- Adopting a new library or framework
- Changing or retiring an existing library
- Changing an architectural pattern
- Changing security policy
- Large-scale DB schema changes
- Changing AI development policy

## PLAN.md Size-Limit Rule (Archive Workflow)

`PLAN.md` is the ongoing task ledger referenced across sessions. Appending to it without limit eventually bloats the file to the point where it becomes hard to scan. Keep it within a bounded size using the following rule.

- **Limit**: keep `PLAN.md` **under 300 lines** (treat crossing 250 lines as the trigger to consider archiving)
- **Archive destination**: `docs/history/plan-archive.md` (create it if it does not yet exist in the project). Only in the harness template repository itself (the one that contains `APPLY_TEMPLATE.md`), use `meta/history/plan-archive.md` instead — it is template-internal and never reaches projects (`APPLY_TEMPLATE.md` class X; removed in `SETUP.md`)
- **Procedure** (what to move, how, and the "archived" note): `docs/development/plan-archiving.md`

## ADR Template

Use the template in `.claude/commands/adr.md` (the `/adr` command) — it is the single source, including the "Variant for Recording a Deferral (Not Adopted)" section.
