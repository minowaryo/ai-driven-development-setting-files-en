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
| **Humans only** | Business understanding, requirements definition, use-case approval, ADR creation, final review and merge, approving commits and pushes |
| **AI primary** | Code generation, test generation, code review assistance, refactoring suggestions, proposing commit splits and merge messages (`docs/development/git-workflow.md`) |
| **AI support** | Design consultation, document drafting, bug root cause investigation |

### Existing-Codebase Adoption

See `SETUP.md`'s Existing-Codebase Path and `meta/adr/ADR-0011-existing-codebase-adoption.md`.

| Role | Tasks |
|---|---|
| **AI** | Detect the real stack (frontend/backend/DB/auth); run `.claude/hooks/domain-boundary-check.sh --audit-all`; draft `docs/ai-context/*`, `use-cases.md` (as-is), `data-model.md`; compile the "Needs confirmation" and "Backlog" lists |
| **Human** | Resolve the "Needs confirmation" list (term meanings, code-vs-old-doc discrepancies, which rules apply to new code); check the "Defaults applied" list (e.g. do-not-touch boundaries); give the one consolidated Gate 0-3 sign-off; final review and merge (unchanged from the greenfield case) |

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
   - Run `/review` before merging when the pre-merge check calls for it (`docs/development/git-workflow.md` §6)
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
3. `./vendor/bin/phpstan analyse` passes — where Larastan is installed (the Laravel Vue
   starter kit ships it at level 7; the bare `laravel/laravel` skeleton does not). Adding it
   to a project is an ADR decision, adopted with `--generate-baseline` so only new code is held
   to it
4. If a critical flow changed, `npx playwright test` passes
5. The author self-check in `docs/development/review-guidelines.md` is complete

## Division of Labor: Deterministic Tools First

For any rule or task, ask in this order, and hand the AI only what is left:

1. **Can a tool check it?** Prefer a check over a prose rule (Pest arch tests, Larastan,
   `.claude/hooks/domain-boundary-check.sh`, strict test settings).
2. **Can a tool do it?** Let deterministic tools make the changes they can (`pint` for
   formatting, Rector for mechanical rewrites) before the AI touches the code.
3. **Can a tool find where?** Let tools produce the work list (static analysis, the Domain
   Boundary audit); the AI fixes one item at a time; the check confirms each fix.

The AI handles the judgment-heavy remainder. Machine-fixable failures should not consume
AI iterations, and a check that runs every time beats a rule the AI may skip.
