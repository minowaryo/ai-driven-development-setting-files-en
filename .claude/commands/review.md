# /review — Code Review Command

Perform a code review from the following perspectives.

## Step 0: Determine Review Intensity (review-score)

> Related ADR: `meta/adr/ADR-0009-review-escalation-mechanism.md`

Before starting the review, always run the following and check the score:

```bash
bash "${CLAUDE_PLUGIN_ROOT:-.claude}/hooks/review-score.sh"
```

- If the output ends with `RECOMMENDATION=normal` → review at the normal level (go through the checklist below in a single pass)
- If the output ends with `RECOMMENDATION=enhanced` → review at the enhanced level. In addition to the checklist below, add an adversarial re-check pass: revisit each finding (HIGH/MEDIUM) skeptically and ask "is this really a risk? am I missing an assumption?"
- If `review-score.sh` fails, or in an environment where the `main` branch doesn't exist, treat it as the normal level

Then run the Domain Boundary check as a **separate command** (it exits 1 when it finds something, so chaining it with `&&` would look like a failure):

```bash
bash "${CLAUDE_PLUGIN_ROOT:-.claude}/hooks/domain-boundary-check.sh"
```

> Related ADR: `meta/adr/ADR-0010-domain-boundary-contract.md`

- Exit 1 means "findings to look at", not "the check failed" — carry the findings into the checklist below
- **Start with the `READ THESE FIRST` section.** Those files mutate data, guard it only with hand-written role checks, and never call a Policy — the shape in which a missing object-level authorization check hides. Read each one and verify that every write is authorized *for the specific record being written*, including that a nested child actually belongs to its parent
- Each line is a **pattern match, not a verdict**: confirm it against the Domain Boundary contract in `.claude/rules/10-laravel.md` before reporting it
- `db-access` / `eloquent-write` / `role-check` are violations of that contract; the branch-density entries are a heuristic pointing at methods that may be making business decisions in the Controller
- The check cannot see a cross-entity decision written in plain PHP (no distinctive tokens), so a clean run is not proof — still review for that by reading

## Files to Read Before Reviewing

- `docs/product/use-cases.md` — to verify that the implementation matches the requirements
- `docs/architecture/data-model.md` — to verify DB schema and migration consistency
- `docs/product/mockups/` — to verify that the UI implementation matches the mockups (if they exist)

## Review Target

Recently changed files (or specified files)

## Checklist

### Features & Design
- [ ] Does the implementation match the requirements in `docs/product/use-cases.md`?
- [ ] Does every Controller satisfy the Domain Boundary contract in `.claude/rules/10-laravel.md` (no `DB::`, no Eloquent writes, no inline role checks, no decision spanning more than one entity)?
- [ ] Were the findings from `domain-boundary-check.sh` each confirmed or dismissed with a reason?
- [ ] Is authorization going through Policy / Gate?
- [ ] Are there any N+1 queries?

### Security (see `.claude/rules/40-security.md`)
- [ ] Is validation appropriate?
- [ ] Are secrets or PII included in the code?
- [ ] Is personal information being output in logs?
- [ ] Are privileged / destructive operations recorded on the `audit` channel with the fixed minimal schema (`.claude/rules/40-security.md`)?

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
