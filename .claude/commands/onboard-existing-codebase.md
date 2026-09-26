# /onboard-existing-codebase — Existing-Codebase Onboarding Command

Runs `SETUP.md`'s Existing-Codebase Path (Step 1B-3B) end to end: detects the real stack,
reverse-engineers `docs/ai-context/*`, drafts `use-cases.md` as-is, extracts
`data-model.md`, and ends in two clearly separated outputs for the human.

> Related ADR: `meta/adr/ADR-0011-existing-codebase-adoption.md`
> Related rules: `.claude/rules/00-global.md`, `docs/development/ai-workflow.md`'s Role Breakdown

## Before Running

Confirm this is the right path: an existing, already-running codebase, not a fresh project.
If unsure, see `SETUP.md`'s Step 0. Do **not** run Claude Code's built-in `/init` instead —
it would overwrite this template's `CLAUDE.md` with a generic shape (see the "Do not run
Claude Code's built-in `/init` here" note in `SETUP.md`'s Existing-Codebase Path).

## Core Principle

The running codebase is the source of truth for what currently happens. Pre-existing org
documentation is reference material for cross-checking, never a substitute for reading the
actual code. **When in doubt, put it on the Needs-confirmation list — never resolve an
ambiguity or a code-vs-docs disagreement by guessing and drafting/implementing on that
guess.** This command does not try to enumerate every kind of ambiguity in advance; it
relies on that one procedural guardrail instead.

## Steps

### Step 1B — Detect the real stack, then reverse-engineer `docs/ai-context/`

1. Detect the actual frontend, backend framework, DB engine, and auth mechanism from the
   code (`composer.json` / `package.json`, migrations, routes, auth config) instead of
   assuming `meta/adr/ADR-0001` / `ADR-0002` / `ADR-0003` / `ADR-0005` automatically hold.
   - Matches this template's assumptions → proceed.
   - Diverges (different DB engine, hand-rolled auth instead of Policy/Gate, etc.) → add a
     named mismatch to the **Needs confirmation** list. Do not silently rewrite either side.
   - Backend isn't PHP/Laravel-family at all → stop here and tell the human this template's
     Existing-Codebase Path isn't a structural fit for this codebase.
   - Record the detected frontend/backend stack via `/adr`, with the Decision section
     stating what was *found*, not *chosen*.
2. Run `.claude/hooks/domain-boundary-check.sh --audit-all`. Its findings go on the
   **Backlog** list — never the Needs-confirmation list (see `meta/adr/ADR-0010-domain-boundary-contract.md`'s
   "backlog, not blocker" framing).
3. Draft `docs/ai-context/project-summary.md`, `module-map.md`, `glossary.md`,
   `common-commands.md`, and `do-not-touch.md` from what is actually in the repo. Only
   business-meaning guesses and uncertain do-not-touch boundaries go on the
   Needs-confirmation list — mechanically-read content (directory layout, an actual command
   from `composer.json`/`package.json`) doesn't go on either list.

### Step 2B — Document current behavior as `use-cases.md` (as-is, not aspirational)

1. Draft `docs/product/use-cases.md` from the actual code paths (routes → controllers →
   policies), labeled explicitly as current behavior, not a specification of desired
   behavior.
2. `docs/product/requirements.md` is optional — its purpose doesn't apply to code that
   already runs.
3. If the code disagrees with pre-existing org docs (e.g. in `docs/original-docs/`), add a
   discrepancy note to the Needs-confirmation list. Never silently resolve it either
   direction — see `.claude/rules/00-global.md`'s "User-Facing Behavior Changes Always
   Require Approval."

### Step 3B — Extract `data-model.md` from the actual schema

1. Generate `docs/architecture/data-model.md` from the real migrations/DB schema — this is
   almost entirely mechanical extraction, so it rarely adds to the Needs-confirmation list,
   and only once the DB engine is confirmed in Step 1B.

## Output Format

End by printing exactly two lists, clearly labeled, in the same voice as `/review`'s
findings output:

1. **Needs confirmation (blocking)** — resolving this with the human *is* the Gate 0-3
   sign-off. Group by file/topic; state what's uncertain and why for each item.
2. **Backlog (non-blocking, optional)** — existing architecture debt from
   `domain-boundary-check.sh --audit-all`. Explicitly note that this list is a heads-up,
   not a requirement, and that it will resurface on every future `/review` regardless of
   whether it's acted on now.

Do not proceed to any implementation work after printing these lists — stop and wait for
the human to resolve the Needs-confirmation list.

## Constraints

- Never treat a stack mismatch, a business-meaning guess, or a code-vs-docs discrepancy as
  settled without asking — see Core Principle above.
- Do not persist the Backlog list to a new file; it is chat output only (see
  `meta/adr/ADR-0011-existing-codebase-adoption.md` for why).
- Do not run the built-in `security-review` skill as part of this command — its diff-only
  scope wouldn't cover the inherited application code (see
  `meta/adr/ADR-0011-existing-codebase-adoption.md`).

## Usage Example

```
/onboard-existing-codebase
```

→ Detects the stack, drafts `docs/ai-context/*`, `use-cases.md`, and `data-model.md`, and
prints the Needs-confirmation and Backlog lists for human review.
