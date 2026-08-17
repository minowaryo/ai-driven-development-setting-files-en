# meta/adr/

Architecture Decision Records for this template/harness itself — not for the project built
from it. These document why the rules, gates, and tooling in `.claude/`, `CLAUDE.md`, and
`docs/` are designed the way they are.

Do not add project-specific decisions here and do not renumber these when adopting the
template — a new project's own decisions go in [`docs/adr/`](../../docs/adr/), starting
from `ADR-0001`.

| ADR | Decision |
|---|---|
| ADR-0001 | Laravel as the backend framework |
| ADR-0002 | MySQL as the database |
| ADR-0003 | Auth strategy (Sanctum + Policy/Gate) |
| ADR-0004 | AI development policy |
| ADR-0005 | Frontend stack selection process (Gate 0) |
| ADR-0006 | Playwright for E2E testing |
| ADR-0007 | TDD enforcement tooling (Probity) |
| ADR-0008 | TDD/E2E harness tooling |
| ADR-0009 | Review escalation mechanism (review-score) |

## Harness-design ADR patterns to copy from

When a downstream project needs to write its own harness-design ADR (a decision about
`.claude/` tooling, AI workflow rules, or review/testing process — not a business-domain
decision), copy the shape of whichever of these fits, rather than starting from a blank
template:

| Pattern | Example | Use when... |
|---|---|---|
| Top-level policy | ADR-0004 | Defining overall AI-usage rules, role split, and workflow gates — the "constitution" a project adopts once. |
| Multi-extension harness bundle | ADR-0008 | Deciding on several related tooling additions together (subagents + slash commands + MCP server, etc.) as one coherent change, with a shared Rationale and a single "known limitations" callout. |
| Single-technology selection | ADR-0006 | Choosing one tool/library for one job (E2E framework, ORM, etc.) with a comparison table of alternatives. |
| Optional / deferred adoption | ADR-0007 | Offering a tool without mandating it (adopt-if-you-want). For a "not now, revisit later" decision instead, see the "Variant for Recording a Deferral (Not Adopted)" section in [`.claude/commands/adr.md`](../../.claude/commands/adr.md) so the evaluation is recorded and not silently repeated later. |

These four shapes are the ones worth copying directly rather than leaving new authors to
infer them from a flat list — they cover the recurring cases of a project-level policy
document, a bundled multi-tool decision, a single technology pick, and a
non-adoption/deferral record.
