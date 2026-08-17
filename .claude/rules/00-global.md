# 00-global.md — Global Policy

## Prerequisites: Verify these when reading this file

Check whether the following are filled in. If not, stop work and notify the user.

- [ ] Is `docs/ai-context/project-summary.md` filled in?
- [ ] Is `docs/ai-context/glossary.md` filled in?
- [ ] Does an ADR for the frontend stack selection exist under `docs/adr/` (has the selection process in `meta/adr/ADR-0005-frontend-stack.md` been completed)?
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

> For the full pipeline diagram (document creation → Gate approval → TDD implementation), see `CLAUDE.md` Step 1-4 (do not duplicate the diagram in this file — if the diagram changes, update it only in `CLAUDE.md`).
> See the "Quality Gate Details" table below for the condition and unlocks of each Gate 0-4.
> See `.claude/rules/30-testing.md` for the detailed steps of each phase and when to run each skill.
> See the next section for where UAT (optional, non-blocking) fits in.

---

## UAT (Acceptance Testing, Optional)

- `docs/product/uat-scenarios.md` may be drafted by AI after merging
- Real-device verification and final confirmation are done by a human (reviewer / business side), who records the results in `docs/product/uat-results/` (this final confirmation itself is required work, but it is not treated as a Gate)
- **UAT belongs to none of Gates 0-4** and does not block the Gate 0-4 pipeline or TDD cycle of other features/UCs
- Non-completion or non-approval of UAT is never a reason to halt subsequent development work (implementing another feature, starting the next TDD cycle, etc.)

---

## Quality Gate Details

| Gate | Condition | Unlocks |
|---|---|---|
| Gate 0 | Required files in `docs/ai-context/` are filled in AND a frontend stack selection ADR has been created | AI assistance starts |
| Gate 1 | `docs/product/requirements.md` reviewer approved | Drafting use-cases.md, mock generation |
| Gate 2 ★ | `docs/product/use-cases.md` final reviewer approval | Code generation, drafting acceptance-criteria / data-model |
| Gate 3 | `docs/architecture/data-model.md` reviewer approved | DB implementation, creating migrations |
| Gate 4 | TDD Red-phase test cases (Feature/Unit) reviewer approved | Implementation (Green phase) may start |

> **Difference in gate nature**: Gates 0-3 are document-approval gates passed once per project. Gate 4 is an implementation gate, repeated per feature/UC every time the TDD cycle (`/tdd`) runs.
> **Mockup review has no gate number**: the business-side review of `docs/product/mockups/` is not an independent gate — it is treated as a precondition for Gate 2 (final approval of use-cases.md). Feedback is incorporated into use-cases.md before Gate 2 approval is granted.

---

## Absolute Prohibitions

- Code generation before Gate 2 is passed
- Starting implementation (Green phase) before Gate 4 is passed (generating implementation code before test case approval)
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
- [ ] Was Gate 4 (test case approval) obtained before starting implementation (Green)?
- [ ] For a change request (CR), has traceability-matrix.md been updated?
- [ ] Is there a migration plan (for DB changes)?
- [ ] Have tests been added?
- [ ] Has documentation been updated?
