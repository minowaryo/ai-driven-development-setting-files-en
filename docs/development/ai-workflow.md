# ai-workflow.md — AI Development Workflow

> Rules for using Claude Code / Codex.
> Related ADR: `meta/adr/ADR-0004-ai-development-policy.md`

## Role Breakdown

The split below assumes a new project (`SETUP.md` Step 1-4). For adopting this harness
onto a project with existing code, see "Existing-Codebase Adoption" below — the overall
shape (AI drafts/generates, human decides/approves) is the same; what differs is *what*
the human is deciding on.

### New Project (Greenfield)

| Role | Tasks |
|---|---|
| **Humans only** | Business understanding, requirements definition, use-case approval, ADR creation, final review and merge |
| **AI primary** | Code generation, test generation, code review assistance, refactoring suggestions |
| **AI support** | Design consultation, document drafting, bug root cause investigation |

### Existing-Codebase Adoption

See `SETUP.md`'s Existing-Codebase Path and `meta/adr/ADR-0011-existing-codebase-adoption.md`.

| Role | Tasks |
|---|---|
| **AI** | Detect the real stack (frontend/backend/DB/auth); run `.claude/hooks/domain-boundary-check.sh --audit-all`; draft `docs/ai-context/*`, `use-cases.md` (as-is), `data-model.md`; compile the "Needs confirmation" and "Backlog" lists |
| **Human** | Resolve the "Needs confirmation" list (term meanings, do-not-touch boundaries, code-vs-old-doc discrepancies); give the one consolidated Gate 0-3 sign-off; final review and merge (unchanged from the greenfield case) |

**Same in both**: AI never generates implementation code before human approval (Gate 2 /
the Gate 0-3 consolidated checkpoint); final review and merge stays human-only.
**Differs**: greenfield's human role is *authoring* from a blank page; existing-codebase's
human role is *verifying/judging* AI-drafted content against the real system — narrower
and faster by design, not a lighter-weight version of the same authorship task.

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
   - In addition to running the tests, use the `run` skill to confirm actual behavior (tests being Green doesn't guarantee the feature works)
   - Run `/review` before merging
```

See `.claude/rules/30-testing.md` for the sub-agent setup, when to run each skill, and how to decide on adopting `@nizos/probity`.

### Context to Load for Claude Code

**Every time (required):**
- `docs/ai-context/project-summary.md`
- `docs/ai-context/glossary.md`
- `docs/ai-context/module-map.md`
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
