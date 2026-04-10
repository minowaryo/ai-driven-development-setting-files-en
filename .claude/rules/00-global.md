# 00-global.md — Global Policy

## Prerequisites: Verify these when reading this file

Check whether the following are filled in. If not, stop work and notify the user.

- [ ] Is `docs/ai-context/project-summary.md` filled in?
- [ ] Is `docs/ai-context/glossary.md` filled in?
- [ ] What is the approval status of `docs/product/use-cases.md`?

---

## Development Workflow

Always proceed in this order:

```
Explore → Plan → Implement → Test
```

1. **Explore**: Read `docs/ai-context/` and related documents to understand the current state
2. **Plan**: Organize the scope and risks of changes, present the implementation approach to the user, and get agreement
3. **Implement**: Implement according to the agreed plan (do not touch out-of-scope files)
4. **Test**: Add and run Feature Tests to verify behavior

---

## AI Development Pipeline

```
[Gate 0] docs/ai-context/ filled in
    ↓
[Gate 1] docs/product/requirements.md — reviewer approved
    ↓  AI may draft use-cases.md
use-cases.md created (AI draft → human revision)
    ↓  AI may generate mockups (/generate-mock)
Mockup creation, business review (docs/product/mockups/)
    ↓  Incorporate mockup feedback into use-cases.md
[Gate 2] docs/product/use-cases.md — final reviewer approval ★
    ↓  AI may draft acceptance-criteria.md / data-model.md
[Gate 3] docs/architecture/data-model.md — reviewer approved
    ↓
AI code generation (Claude Code)
    ↓
AI test generation
    ↓
Human review and merge
```

---

## Quality Gate Details

| Gate | Condition | Unlocks |
|---|---|---|
| Gate 0 | Required files in `docs/ai-context/` are filled in | AI assistance starts |
| Gate 1 | `docs/product/requirements.md` reviewer approved | Drafting use-cases.md, mock generation |
| Gate 2 ★ | `docs/product/use-cases.md` final reviewer approval | Code generation, drafting acceptance-criteria / data-model |
| Gate 3 | `docs/architecture/data-model.md` reviewer approved | DB implementation, creating migrations |

---

## Absolute Prohibitions

- Code generation before Gate 2 is passed
- Code-first approach (implementing without reviewing documentation)
- Bulk commits of large-scale changes
- Implementation without tests (always add regression tests for bug fixes)
- Editing out-of-scope files
- Including secrets or production credentials in prompts
- Editing, deleting, or creating files in `docs/original-docs/` (reference only)

---

## Verification Checklist for Changes

- [ ] Have you checked the related ADR?
- [ ] Does the change impact use-cases.md?
- [ ] For a change request (CR), has traceability-matrix.md been updated?
- [ ] Is there a migration plan (for DB changes)?
- [ ] Have tests been added?
- [ ] Has documentation been updated?
