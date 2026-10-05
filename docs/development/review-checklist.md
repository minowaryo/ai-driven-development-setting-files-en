# review-checklist.md — Review Checklist

> Use this together with the `/review` command.
> For details, see `docs/development/review-guidelines.md`.

## Author Self-Check (Before Merging)

The single author self-check is "Pre-Review Self-Check" in
`docs/development/review-guidelines.md` — `prepare-merge` runs that list on every merge.

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
- [ ] Are E2E tests scoped to "critical flows only" (no misuse for exhaustive coverage)?

### Documentation
- [ ] Are design changes reflected in the docs?
