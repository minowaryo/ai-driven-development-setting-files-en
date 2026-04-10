# /adr — ADR Creation Command

Creates a new Architecture Decision Record (ADR).

## Steps

1. Check existing ADRs in `docs/adr/` to identify the next number
2. Create a new file as `docs/adr/ADR-XXXX-[title].md`
3. Fill it in using the template below

## Template

```markdown
# ADR-XXXX: [Title of the decision]

## Status
Proposed

## Date
[YYYY-MM-DD]

## Context
[Why this decision was needed. Describe the background, problem, and constraints.]

## Decision
[What was decided. Describe it specifically.]

## Rationale
[Why this decision was made. Also list rejected alternatives.]

### Rejected Alternatives
- **[Alternative 1]**: [Reason for rejection]
- **[Alternative 2]**: [Reason for rejection]

## Consequences
[Impact and trade-offs of this decision.]

### Benefits
-

### Drawbacks / Risks
-

## Related
- [Links to related ADRs and documents]
```

## When to Write an ADR

- Adopting a new library or framework
- Changing an architectural pattern
- Changing security policy
- Large-scale DB schema changes
- Changing AI development policy
