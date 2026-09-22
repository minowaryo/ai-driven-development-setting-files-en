# /adr — ADR Creation Command

Creates a new Architecture Decision Record (ADR).

## Steps

1. Check existing ADRs in `docs/adr/` to identify the next number. If there are none yet, start at `0001`.
2. Create a new file as `docs/adr/ADR-XXXX-[title].md`, where `XXXX` is that number, zero-padded to 4
   digits, and the file always starts with the literal `ADR-` prefix — e.g. `docs/adr/ADR-0001-adopt-redis-for-sessions.md`.
   Never drop the `ADR-` prefix or use an unpadded/differently-shaped number (e.g. `0001-adopt-redis-for-sessions.md` is wrong).
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

## Variant for Recording a Deferral (Not Adopted)

Record a "considered it, but not adopting it for now" conclusion using the same ADR format as any other decision. If you skip writing an ADR and leave it only in verbal or chat discussion, the same evaluation tends to get repeated later.

- **Title**: append `— Not Adopted` at the end, so the conclusion is clear without opening the file from the index
- **Status**: `Accepted` is still correct (what's approved is the decision not to adopt, not the adoption of the tool itself)
- **Decision**: state clearly that it is not being adopted now, and the conditions/timing under which it should be reconsidered (e.g. "revisit once XYZ becomes a real problem in production")
- **Rationale**: state the reason for deferring (e.g. "premature" at this stage). Writing down the intended configuration policy for future adoption (exclusion paths, etc.) ahead of time makes reconsidering and adopting it later smoother
- Reference implementation: `meta/adr/ADR-0007-tdd-enforcement-probity.md` (this repo's example of the "optional adoption" pattern — see also "Harness-design ADR patterns" in `meta/adr/README.md`)

## When to Write an ADR

- Adopting a new library or framework
- Changing an architectural pattern
- Changing security policy
- Large-scale DB schema changes
- Changing AI development policy
- Deciding, after evaluation, deliberately not to adopt something (a deferral — see the variant above)
