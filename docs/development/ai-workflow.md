# ai-workflow.md — AI Development Workflow

> Rules for using Claude Code / Codex.
> Related ADR: `docs/adr/ADR-0004-ai-development-policy.md`

## Role Breakdown

| Role | Tasks |
|---|---|
| **Humans only** | Business understanding, requirements definition, use-case approval, ADR creation, final review and merge |
| **AI primary** | Code generation, test generation, code review assistance, refactoring suggestions |
| **AI support** | Design consultation, document drafting, bug root cause investigation |

## Using Claude Code

### Recommended Workflow

```
1. Explore
   - Read related files
   - Understand existing implementations and patterns

2. Plan
   - Organize the scope of impact of changes
   - Present the implementation approach and get agreement

3. Implement (via the `/tdd` command)
   - Proceed through the cycle: Red → Gate 4 (test case approval) → Green → Refactor
   - Do not stray beyond the planned scope

4. Test (and verify)
   - In addition to running the tests, use the `verify` skill to confirm actual behavior (tests being Green doesn't guarantee the feature works)
   - Run `/review` before merging
```

See `.claude/rules/30-testing.md` for the sub-agent setup, when to run each skill, and how to decide on adopting `@nizos/probity`.

### Effective Prompts

See `docs/ai-context/prompt-patterns.md`.

### Context to Load for Claude Code

**Every time (required):**
- `docs/ai-context/project-summary.md`
- `docs/ai-context/common-commands.md`

**Task-specific:**
- DB changes → `docs/architecture/data-model.md`
- Auth changes → `docs/architecture/authz-authn.md`
- Architecture changes → `docs/adr/`

## Using Codex

### Recommended Use Cases
- Automatic diff generation
- Code review automation
- Implementing repetitive patterns

### Required Reads (via AGENTS.md)
- `docs/ai-context/project-summary.md`
- Related ADRs
- Task-specific documents

## Prohibited Actions

- Requesting code generation before use-cases.md is approved
- Merging AI-generated code without review
- Including secrets or production credentials in prompts
- Accepting AI suggestions without human review

## Quality Gates

AI-generated code must satisfy:
1. `php artisan test` passes
2. `./vendor/bin/pint --test` passes
3. `./vendor/bin/phpstan analyse` passes
4. If a critical flow changed, `npx playwright test` passes
5. Review in `docs/development/review-checklist.md` is complete
