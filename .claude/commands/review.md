# /review — Code Review Command

Perform a code review from the following perspectives.

## Step 0: Determine Review Intensity (review-score)

> Related ADR: `meta/adr/ADR-0009-review-escalation-mechanism.md`

Before starting the review, always run the following and check the score:

```bash
bash .claude/hooks/review-score.sh
```

- If the output ends with `RECOMMENDATION=normal` → review at the normal level (go through the checklist below in a single pass)
- If the output ends with `RECOMMENDATION=enhanced` → review at the enhanced level. In addition to the checklist below, add an adversarial re-check pass: revisit each finding (HIGH/MEDIUM) skeptically and ask "is this really a risk? am I missing an assumption?"
- If `review-score.sh` fails, or in an environment where the `main` branch doesn't exist, treat it as the normal level

## Files to Read Before Reviewing

- `docs/product/use-cases.md` — to verify that the implementation matches the requirements
- `docs/architecture/data-model.md` — to verify DB schema and migration consistency
- `docs/product/mockups/` — to verify that the UI implementation matches the mockups (if they exist)

## Review Target

Recently changed files (or specified files)

## Checklist

### Features & Design
- [ ] Does the implementation match the requirements in `docs/product/use-cases.md`?
- [ ] Is the Controller too fat (Fat Controller)?
- [ ] Is authorization going through Policy / Gate?
- [ ] Are there any N+1 queries?

### Security (see `.claude/rules/40-security.md`)
- [ ] Is validation appropriate?
- [ ] Are secrets or PII included in the code?
- [ ] Is personal information being output in logs?

### Tests (see `.claude/rules/30-testing.md`)
- [ ] Is a Feature Test added?
- [ ] Are there tests for happy path, error cases, and authorization?
- [ ] If a new data model (migration) was added, are the create/edit/delete operations that `use-cases.md` defines as provided for it consistently covered by Feature Tests (cross-check against the model list in `docs/architecture/data-model.md`; do not demand extra implementation/tests for operations not defined there)?

### Documentation (see `.claude/rules/60-docs.md`)
- [ ] Are design changes reflected in the docs?
- [ ] Has a decision been made that requires an ADR?

## Output Format

1. **Overall assessment** (1–2 sentences)
2. **Issues** (severity: HIGH / MEDIUM / LOW)
3. **Recommended fixes**
4. **Tests to add**
