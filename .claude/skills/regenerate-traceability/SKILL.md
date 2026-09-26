---
name: regenerate-traceability
description: Rebuild the Matrix table in docs/rcid/traceability-matrix.md from use-cases.md and the code/tests actually present in the repo. Use when asked to regenerate, refresh, rebuild, or check the traceability matrix; when a change request (CR) needs it brought up to date; or when asked which use cases are missing implementation or test coverage.
---

# Regenerate the Traceability Matrix

Rebuilds the **Matrix** table in `docs/rcid/traceability-matrix.md` by re-deriving
UC → Requirement ID → implementation → test from the repo as it is now. Per-commit
hand-upkeep is what lets a table like this go stale, so this runs periodically instead —
during `/review`, or before a release.

## Scope — what this rewrites, and what it must not touch

| Section | Action |
|---|---|
| `## Matrix` | **Replace the whole table body**, including any placeholder rows (`F-001` / `UC-001` etc.) — never append to it |
| `Last regenerated:` | Set to today's date |
| `## Change Tracking` | **Never touch.** It is a hand-maintained audit record of approved changes and cannot be re-derived from code — overwriting it destroys history |
| Every other section | Leave verbatim (`RCID Naming Convention`, `Status Definitions`, `Usage`, `Maintenance`) |

Also never edit `docs/product/use-cases.md` from this skill — it is an input here, and
changing it is a Gate 2 matter.

## Before running

Check that `docs/product/use-cases.md` has real content. If it is still the template
placeholder, stop and say so — regenerating against it would produce a table of nothing
and overwrite whatever the previous run found.

## Steps

1. Extract `UC ID → title → Requirement ID(s)` from `docs/product/use-cases.md`: its UC
   headings, each followed by a `**Related requirement**` line.
2. For each UC, locate its implementation file(s) and test file(s) by resource-name search.
   Use `docs/ai-context/module-map.md` to know where application code and tests actually
   live in this project. Only read file contents when the name match is ambiguous.
3. Assign Status per the definitions already in `docs/rcid/traceability-matrix.md`:
   - **Complete** — implementation plus a Feature/Unit test that exercises the actual
     behavior (a test that only covers Policy/authorization does not qualify)
   - **Partial** — implementation exists, but test coverage is missing, indirect, or
     authorization-only
   - **Not Found** — neither implementation nor test could be located
4. Write the rebuilt Matrix and the `Last regenerated:` date.
5. Report per the output format below.

## Guardrails

- **Never guess a match.** If a UC could plausibly map to more than one file, or to none
  under a different name, record the row with what is certain and raise it in the
  Unresolved list — a confidently wrong row is worse than an admitted gap, because the next
  reader trusts the table.
- A row's Status is a statement about what was *found*, not about what *should* exist. Do
  not mark something Complete because the UC says it ought to be.
- Do not create implementation or test files to close a gap found here. Report the gap and
  stop — writing the missing test is a `/tdd` cycle with its own Gate 4.
- A Requirement ID present in `docs/product/requirements.md` with no matching UC goes in the
  report, not in the Matrix.

## Output Format

1. **Summary** — number of UCs processed, and the count per Status
2. **Status regressions** — rows whose Status dropped since the previous table (e.g.
   `Complete` → `Not Found`). List these first: the usual cause is a renamed or deleted
   file, or a match that silently stopped working, and either is worth knowing before a
   release
3. **Unresolved** — ambiguous matches from step 2, with what was ambiguous about each
4. **Requirement IDs with no matching UC**

If a list is empty, say so explicitly rather than omitting the heading.
