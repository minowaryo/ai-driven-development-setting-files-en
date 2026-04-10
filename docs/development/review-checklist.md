# review-checklist.md — PR Review Checklist

> Use this together with the `/review` command.
> For details, see `.claude/rules/50-review.md`.

## Author Self-Check (Before Opening a PR)

### Requirements & Design
- [ ] Is it linked to the corresponding use case in `docs/product/use-cases.md`?
- [ ] If there is a design change, has an ADR been created?

### Code Quality
- [ ] Has `./vendor/bin/pint` been run to format the code?
- [ ] Are there no errors from `./vendor/bin/phpstan analyse`?
- [ ] Is the Controller too fat (Fat Controller)?
- [ ] Are there any N+1 queries? (Check with Telescope / Debugbar)

### Authentication & Authorization
- [ ] Is `$this->authorize()` called appropriately in the relevant Controller?
- [ ] Has authentication middleware been set on new endpoints?

### Security
- [ ] Are secrets or API keys included in the code?
- [ ] Is PII being output in logs?
- [ ] Is validation appropriate (using FormRequest)?

### Tests
- [ ] Does `php artisan test` pass?
- [ ] Is there a Feature Test for the happy path?
- [ ] Is there a test for authorization (unauthenticated / unauthorized)?
- [ ] Is there a test for validation errors?

### Documentation
- [ ] For DB changes → has `docs/architecture/data-model.md` been updated?
- [ ] For design changes → have the relevant docs been updated?

---

## Reviewer Check

### Features & Design
- [ ] Does the implementation align with the intent of the use cases?
- [ ] Is it consistent with existing design patterns?
- [ ] Have any unrelated files been changed?

### Security
- [ ] Is the authorization check appropriate (going through Policy / Gate)?
- [ ] Is validation sufficient?
- [ ] Are secrets included?

### Performance
- [ ] Is there any suspicion of N+1 queries?
- [ ] Is an index in use for heavy queries?

### Tests
- [ ] Do the tests actually cover failing cases?
- [ ] Are test names clear and descriptive?

### Documentation
- [ ] Are design changes reflected in the docs?
