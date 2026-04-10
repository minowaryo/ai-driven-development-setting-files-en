# 50-review.md — PR Review Guidelines

## Pre-Review Self-Check (Author)

Check these yourself before opening a PR:

- [ ] Is it linked to requirements in `docs/product/use-cases.md`?
- [ ] Is there a Feature Test?
- [ ] Does `php artisan test` pass?
- [ ] Is code style clean after running `./vendor/bin/pint`?
- [ ] Are there any dangerous operations in the migration?
- [ ] Are secrets or PII included in the code?
- [ ] Have any unrelated files been edited?

## Reviewer Perspectives

### Features & Design
- [ ] Does the implementation match the requirements (use-cases.md)?
- [ ] Does it follow existing design patterns?
- [ ] Is the Controller too fat (Fat Controller)?
- [ ] Is authorization going through Policy / Gate?

### DB & Performance
- [ ] Is the migration backward-compatible?
- [ ] Are there any N+1 queries?
- [ ] Are the necessary indexes in place?

### Security
- [ ] Is validation appropriate?
- [ ] Is there an authorization check?
- [ ] Are secrets included?
- [ ] Is PII appearing in logs?

### Tests
- [ ] Do the tests cover happy path and error cases?
- [ ] Are test names clear and descriptive?

### Documentation
- [ ] Are design changes reflected in the docs?
- [ ] Has a decision been made that requires a new ADR?

## AI Review Command

```
/review
```

See `.claude/commands/review.md`.
