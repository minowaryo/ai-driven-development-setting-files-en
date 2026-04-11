# /review — Code Review Command

Perform a code review from the following perspectives.

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

### Documentation (see `.claude/rules/60-docs.md`)
- [ ] Are design changes reflected in the docs?
- [ ] Has a decision been made that requires an ADR?

## Output Format

1. **Overall assessment** (1–2 sentences)
2. **Issues** (severity: HIGH / MEDIUM / LOW)
3. **Recommended fixes**
4. **Tests to add**
