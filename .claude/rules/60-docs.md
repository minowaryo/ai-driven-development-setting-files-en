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
| Gate condition / quality-gate process changes | `.claude/rules/00-global.md` (details table, absolute prohibitions) + `SETUP.md` (Step procedures) + `AGENTS.md` (for Codex — Gate definitions are duplicated there, so all 3 files need to stay in sync) |

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

## PLAN.md Size-Limit Rule (Archive Workflow)

`PLAN.md` is the ongoing task ledger referenced across sessions. Appending to it without limit eventually bloats the file to the point where it becomes hard to scan. Keep it within a bounded size using the following rule.

- **Limit**: keep `PLAN.md` **under 300 lines** (treat crossing 250 lines as the trigger to consider archiving)
- **Archive destination**: `docs/history/plan-archive.md` (create it if it does not yet exist in the project)
- **What to archive first**: `PLAN.md` is maintained with new entries prepended to the top, so archive **starting from the bottom (oldest) entries**, and only entries whose Status is "done"-equivalent (e.g., Completed, Green confirmed, Merged, Implemented — i.e., no follow-up work is still pending). Leave in place any entry that is awaiting user approval, in progress, or has a next action noted
- **Procedure**:
  1. Move the target entry (the full `##`-heading unit — Decision / Files touched / Status sections together) verbatim into `docs/history/plan-archive.md`. Order the archive newest-first as well (i.e., the entry that most recently left `PLAN.md` goes at the top)
  2. Update the archive file's opening description (the range of dates/entries it covers)
  3. Update the "archived" note at the top of `PLAN.md` (range and date)
  4. Move entry bodies and file paths verbatim — do not summarize or abbreviate them (doing so would make it impossible to trace the history later)
- **Where this rule lives**: don't restate the procedure inside `PLAN.md` itself — this file (`.claude/rules/60-docs.md`) is the source of truth. `PLAN.md` should only note that it must stay under 300 lines and point back here

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
