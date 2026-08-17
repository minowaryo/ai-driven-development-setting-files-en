# prompt-patterns.md — Standard Prompt Templates

> A collection of standard prompts for giving effective instructions to Claude Code / Codex.
> These can be copied and used as-is.

## New Feature Implementation

```
Please implement [feature name].

First, check the following:
1. docs/ai-context/project-summary.md (overall overview)
2. docs/product/use-cases.md (related use cases)
3. docs/architecture/data-model.md (DB design)

Present a plan before implementing (follow the Explore → Plan → Implement order).
```

## Bug Fix

```
Please fix [bug description].

Before fixing:
1. Identify and explain the root cause
2. Present a regression test first
3. Confirm the fix approach before implementing
```

## Code Review

```
Please review the following code:
[code or file path]

Review criteria:
- Check according to docs/development/review-checklist.md
- Security perspective (see .claude/rules/40-security.md)
- Test coverage
- Compliance with design patterns
```

## Migration Creation

```
Please create a migration for [table name / change description].

Notes:
- Check docs/architecture/data-model.md
- Follow the migration policy in .claude/rules/20-mysql.md
- Be mindful of backward compatibility
- Warn if the operation is dangerous (DROP, etc.)
```

## ADR Creation

```
Please create an ADR for [decision content].

Template: Refer to the existing ADRs in meta/adr/ for formatting (docs/adr/ starts empty for this project's own decisions)
Required sections: Context / Decision / Rationale / Consequences
```

## Test Creation

```
Please create a Feature Test for [feature / class name].

Target:
- Happy path
- Authentication and authorization (unauthenticated / unauthorized)
- Validation errors

Follow the policy in .claude/rules/30-testing.md.
```

## Documentation Update Check

```
Please identify which documents need to be updated due to this change.
Refer to the mapping table in .claude/rules/60-docs.md.
```
