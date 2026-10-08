# common-commands.md — Frequently Used Commands

## Claude Code Entry Points (`.claude/commands/` and `.claude/skills/`)

> Which of the two a given entry point lives in follows the criterion in
> `meta/adr/ADR-0012-skills-vs-commands.md`: a skill may be invoked by AI on its own, a
> command only when a human types it (every command carries `disable-model-invocation: true`
> — asking in plain words, e.g. "review this", does not start it; type the command).

| Entry point | When to run it | Who triggers it |
|---|---|---|
| `/onboard-existing-codebase` | Once, when adopting this harness onto a project that already has running code (Steps 1B-3B, then the consolidated Gate 0-3 sign-off) | Human |
| `/generate-mock UC-XXX` | Between Gate 1 and Gate 2 — HTML mockups for the business-side review | Human |
| `/adr` | Whenever a technical decision is made — generates the ADR skeleton for a human to finalize | Human (AI proposes it) |
| `/tdd UC-XXX [summary]` | Every feature / UC implementation: Red → Gate 4 approval → Green → Refactor | Human |
| `/generate-e2e-test UC-XXX` | A UC critical flow that includes UI changes | Human — or `/tdd` Step 6 follows its steps when applicable |
| `/review` | Before merging, when the pre-merge check calls for it (`docs/development/git-workflow.md` §6). Step 0 scores the branch diff to pick the review level | Human — `/tdd` and `prepare-merge` only remind you (deliberate; see `meta/adr/ADR-0009-review-escalation-mechanism.md`) |
| `/commit` | When work is ready to commit — proposes the commit split and messages, commits after one approval, never pushes | Human |
| `prepare-merge` (Trial) | When a branch is done ("merge this" / "マージして") — pre-merge check, drafted merge message, `--no-ff` merge only on instruction | AI or human — it is a skill; see `meta/adr/ADR-0015` |
| `/regenerate-traceability` | Periodically rather than per-commit — during `/review`, or before a release. Rebuilds the Matrix table in `docs/rcid/traceability-matrix.md` (never the hand-maintained Change Tracking table) | Human or AI — it is a skill, so AI may propose it when the matrix has gone stale |
| `systematic-debugging` (Trial) | Investigating an unclear or non-trivial bug, or after a fix attempt didn't work | AI — see `meta/adr/ADR-0013` |
| `verification-before-completion` (Trial) | Before reporting any task/fix/feature as complete | AI — see `meta/adr/ADR-0013` |
| `grill-me` (Trial) | Drafting/revising `docs/product/requirements.md`, for genuinely ambiguous points | AI — see `meta/adr/ADR-0013` |

> Verifying actual behavior after Green (the `run` skill) is recommended rather than run automatically — a human has to invoke it. See `.claude/rules/30-testing.md`.

## When Git Gets Stuck

Stuck on a merge, a conflict, or a wrong commit? See `docs/development/git-troubleshooting.md` (what to ask the AI in each situation).

## Tests

```bash
# Run all tests
php artisan test

# Run a specific file
php artisan test tests/Feature/UserTest.php

# With coverage
php artisan test --coverage

# Parallel execution (faster)
php artisan test --parallel
```

## E2E Tests (Playwright)

> See `docs/development/e2e-testing.md` for details.

```bash
# Initial setup
npm install -D @playwright/test
npx playwright install

# Run all E2E tests
npx playwright test

# Run a specific file only
npx playwright test tests/e2e/uc001-user-registration.spec.ts

# UI mode (for debugging)
npx playwright test --ui

# Show the report from the most recent failure
npx playwright show-report
```

## Playwright MCP (browser automation tool, optional)

> Already defined in `.mcp.json`. See `meta/adr/ADR-0008-tdd-e2e-harness-tooling.md` for details.
> Use only against a local development environment — never connect it to a production URL or a real-data environment.

```bash
# On first use, Claude Code will show an approval prompt for .mcp.json — approve it
# (to add it manually instead)
claude mcp add playwright npx @playwright/mcp@latest
```

## TDD Enforcement Tool (Probity, optional)

> See `meta/adr/ADR-0007-tdd-enforcement-probity.md` for details.

```bash
# Initial setup
npm install -D @nizos/probity

# Check for rule violations (based on probity.config.ts)
npx probity check
```

## Code Style

```bash
# Format (auto-fix)
./vendor/bin/pint

# Check only (no fixes)
./vendor/bin/pint --test

# Static analysis (only where Larastan is installed — see Quality Gates in docs/development/ai-workflow.md)
./vendor/bin/phpstan analyse
```

## Spec Checks

```bash
# Before Gate 2: requirements + use cases + mockups (structure only; findings inform the reviewer)
bash .claude/hooks/spec-lint.sh

# Before Gate 1: requirements.md only
bash .claude/hooks/spec-lint.sh --requirements
```

## TDD Guard (tests and spec locked for tdd-implementer)

`/tdd` runs these itself (`docs/development/tdd-guard.md`); run them by hand to check.

```bash
# Compare tests/ and docs/product/ with the snapshot saved at Gate 4 approval,
# and list tdd-implementer's blocked attempts since then (from logs/audit.jsonl)
bash .claude/hooks/tdd-snapshot.sh verify

# Find application code that compares against a value only the approved tests contain
# (exit 2 = found; run after Green, from the project root)
bash .claude/hooks/fixture-literal-check.sh

# Save a new snapshot (what Gate 4 approval does)
bash .claude/hooks/tdd-snapshot.sh record
```

## Database

```bash
# Run migrations
php artisan migrate

# Rollback
php artisan migrate:rollback

# Reset DB (development only)
php artisan migrate:fresh --seed

# Check migration status
php artisan migrate:status
```

## Application

```bash
# Start development server
php artisan serve

# Clear caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Start queue worker (development)
php artisan queue:work

# Start scheduler (development)
php artisan schedule:work
```

## Code Generation (Artisan)

```bash
# Controller
php artisan make:controller UserController --resource

# Model + Migration + Factory + Seeder
php artisan make:model User -mfs

# FormRequest
php artisan make:request StoreUserRequest

# Policy
php artisan make:policy UserPolicy --model=User

# Action / Service (custom)
php artisan make:class Actions/RegisterUserAction
```

## Composer

```bash
# Install dependencies
composer install

# Add a package
composer require [package]

# Vulnerability check
composer audit

# Regenerate autoload
composer dump-autoload
```
