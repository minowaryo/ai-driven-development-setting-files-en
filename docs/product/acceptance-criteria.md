# acceptance-criteria.md — Acceptance Criteria

> Defines the release acceptance criteria for each feature.
> Also used as the criteria for QA testing.

---

## Acceptance Criteria Template (Given-When-Then format)

---

### AC-001: [Feature Name]

**Related requirements**: F-001 / UC-001

```
Given: [precondition state]
When:  [action]
Then:  [expected result]
```

Example:
```
Given: The admin is logged in
When:  The admin accesses the user list page
Then:  A list of all users is displayed
  And: Each user's name, email, and status are displayed
  And: Pagination works correctly
```

---

### AC-002: [Feature Name]

**Related requirements**: F-002 / UC-002

```
Given: [precondition state]
When:  [action]
Then:  [expected result]
```

---

## Common Acceptance Criteria (applies to all features)

### Security
- [ ] Unauthenticated users cannot access protected resources
- [ ] Unauthorized users receive a 403 response
- [ ] Input validation errors return 422

### Performance
- [ ] List APIs respond within 200ms (P95)
- [ ] No N+1 queries occur

### Tests
- [ ] Feature Tests cover all criteria
- [ ] Tests pass in CI
