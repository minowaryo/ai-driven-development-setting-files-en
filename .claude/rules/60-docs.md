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
| Resolved a library/framework-specific pitfall | `docs/ai-context/known-pitfalls.md` (not loaded every time, so it doesn't need to be in the same PR as the code change — append whenever one is resolved) |
| Gate condition / quality-gate process changes | `.claude/rules/00-global.md` (details table, absolute prohibitions) + `CLAUDE.md` (Step procedures) + `AGENTS.md` (for Codex — Gate definitions are duplicated there, so all 3 files need to stay in sync) |

## Documentation Update Principles

1. **Update documentation in the same PR as the code change**
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

## ADR Template

Create as `docs/adr/ADR-XXXX-[title].md`:

```markdown
# ADR-XXXX: [Title]

## Status
[Proposed / Accepted / Deprecated / Superseded by ADR-XXXX]

## Date
YYYY-MM-DD

## Context
[Why this decision was needed]

## Decision
[What was decided]

## Rationale
[Why this decision was made, and rejected alternatives]

## Consequences
[Impact and trade-offs of this decision]
```

For how to phrase the Title, Status, and Decision when recording a "considered it, but not adopting it for now" (deferral) conclusion, see the "Variant for Recording a Deferral (Not Adopted)" section in `.claude/commands/adr.md`.
