# ADR-0004: AI-Driven Development Policy

## Status
Accepted

## Date
[YYYY-MM-DD]

## Context

This project uses Claude Code and Codex (or other AI coding tools) in combination.
Without defining usage rules, responsibilities, and prohibitions for AI tools, quality, security, and design consistency will be compromised.

## Decision

Adopt the following AI-driven development policy.

### AI Responsibilities

| Role | Tasks |
|---|---|
| AI | API code generation, Controller/Model/Migration generation, test generation, code review assistance |
| Human | Business understanding, use-case review and approval, design decisions, ADR creation, final approval |

### Development Workflow

```
requirements.md (defined by humans)
      ↓
use-cases.md (human review and approval ← quality gate)
      ↓
data-model.md / openapi.yaml
      ↓
AI code generation (Claude Code / Codex)
      ↓
AI test generation
      ↓
Human review and merge
```

### Rules for Instructing AI
- Provide context via `CLAUDE.md` / `AGENTS.md` as the entry point
- Do not make AI read all documents every time (only what is needed)
- Do not include secrets or PII in AI prompts

### Prohibited Actions
- Requesting code generation from AI before use-cases.md is approved
- Merging AI-generated code without human review
- Passing API keys or production credentials to AI

## Rationale

**Reasons for this policy:**
- Using use-cases.md as a quality gate ensures AI code generation quality is grounded in specifications
- Documenting AI rules allows all team members to use AI in a consistent way
- Secrets protection is especially important risk management in the AI era

### Rejected Alternatives
- **Development without AI**: Rejected for speed and cost efficiency reasons
- **Full AI automation (no human review)**: Quality and security risks are too high

## Consequences

### Benefits
- Increased development speed
- Consistent code quality
- Quality assurance through automated test generation

### Drawbacks / Risks
- The quality of use-cases.md determines the overall project quality
- Humans need the skills to review AI-generated code for errors

## Related
- `CLAUDE.md`
- `AGENTS.md`
- `.claude/rules/00-global.md`
- `docs/development/ai-workflow.md`
