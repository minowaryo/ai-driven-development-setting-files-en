---
disable-model-invocation: true
---

# /onboard-existing-codebase — Existing-Codebase Onboarding Command

Runs `SETUP.md`'s Existing-Codebase Path (Step 1B-3B) end to end: detects the real stack,
reverse-engineers `docs/ai-context/*`, drafts `use-cases.md` as-is, extracts
`data-model.md`, triages every finding, and ends with a prioritized Review Guide plus two
clearly separated lists for the human.

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
actual code. **Never resolve an ambiguity or a code-vs-docs disagreement by guessing and
drafting/implementing on that guess.** If more code reading can settle it, settle it and
record the result as a fact; if a conservative default is harmless (see do-not-touch
below), apply it and say so; otherwise put it on the Needs-confirmation list. This command
does not try to enumerate every kind of ambiguity in advance; it relies on that one
procedural guardrail instead.

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
     stating what was *found*, not *chosen*. This ADR is the canonical home for stack and
     auth facts — other files point to it instead of restating them.
   - When a mismatch is found, ask only what is needed to start development (`SETUP.md`
     Step 4) — typically "is this detection accurate?" and "which rules apply to *new*
     code?". Whether to migrate the stack is out of scope for onboarding; do not ask it.
2. Reconcile the harness files that assume the template's default stack. Left as-is, they
   are read by AI via `CLAUDE.md`'s task table and actively mislead it:
   - `docs/architecture/authz-authn.md` — if the detected auth differs from Sanctum +
     Policy/Gate, replace the template content with the as-is facts, pointing to the stack
     ADR for the mechanism. List it as its own **P1** review item, pointing the human at
     the "who can do what" part — a misread here is the costliest error in the output.
   - `.claude/rules/15-frontend.md` (frontend differs from Vue 3 + Inertia.js + Pinia) and
     `.claude/rules/20-mysql.md` (DB engine differs from MySQL) — which rules new code
     should follow is a human decision: add it as a **P1** Needs-confirmation question, and
     prepend a short banner to the file stating that it does not describe this codebase and
     that the human must be asked before writing code it covers. Rewrite the body only
     after the answer.
   - Never add a banner to or rewrite `00-global.md`, `10-laravel.md`, `40-security.md`, or
     `CLAUDE.md`'s global rules. If existing code does not follow their auth rules
     (Policy/Gate, Sanctum), make that a P1 question; the rules keep applying to new code
     until the human answers.
3. Run `.claude/hooks/domain-boundary-check.sh --audit-all`. Its findings go on the
   **Backlog** list — never the Needs-confirmation list (see `meta/adr/ADR-0010-domain-boundary-contract.md`'s
   "backlog, not blocker" framing).
4. Draft `docs/ai-context/project-summary.md`, `module-map.md`, `glossary.md`,
   `common-commands.md`, and `do-not-touch.md` from what is actually in the repo. Keep
   them short (`.claude/rules/60-docs.md`: ai-context is a summary layer) — summarize and
   link to the canonical file rather than copying detail (`project-summary.md` still keeps
   a one-line stack summary, since it is read every session). Mark every business-meaning
   guess inline with **[inferred]**; only those go on the Needs-confirmation list —
   mechanically-read content (directory layout, an actual command from
   `composer.json`/`package.json`) doesn't go on either list.
   - For an uncertain do-not-touch boundary, apply the conservative default (treat it as
     do-not-touch) and list it under "Defaults applied" in the Review Guide instead of
     asking — a human can loosen it later, and an over-cautious boundary causes no harm in
     the meantime.
5. Fill the other template files that are read as if they described this project:
   - `CLAUDE.md`'s **Project** section (loaded every session): project name, stack (one
     line, pointing to the stack ADR), and type are mechanical; **Main domains** is a
     business-meaning guess → **[inferred]**, P2.
   - `docs/product/org-permission-philosophy.md` (read for any auth change): list the
     roles that exist in the code; each role's purpose and target users are
     **[inferred]**, P2.
   - `docs/product/ui-guidelines.md` (read for any UI work): write only what existing
     styles/theme config actually define; if nothing is defined, replace the placeholders
     with one line saying so and that new screens follow the existing ones.

### Step 2B — Document current behavior as `use-cases.md` (as-is, not aspirational)

1. Draft `docs/product/use-cases.md` from the actual code paths (routes → controllers →
   policies), labeled explicitly as current behavior, not a specification of desired
   behavior. Also trace the entry points that bypass routes — console commands, scheduled
   tasks, queued jobs, event listeners — since whatever is missed here is missed silently.
   Mark business-meaning guesses with **[inferred]**, as in Step 1B.
2. `docs/product/requirements.md` is optional — its purpose doesn't apply to code that
   already runs. Do not leave the template placeholder in place: replace it with a
   one-line note that this project was onboarded via the Existing-Codebase Path and that
   `use-cases.md` is the behavior reference (no review needed).
3. If the code disagrees with pre-existing org docs (e.g. in `docs/original-docs/`), add a
   discrepancy note to the Needs-confirmation list. Never silently resolve it either
   direction — see `.claude/rules/00-global.md`'s "User-Facing Behavior Changes Always
   Require Approval."
4. Run `bash .claude/hooks/spec-lint.sh` and fix every structural finding (ids, missing
   sections, leftover template text). Unresolved `[inferred]` markers stay — they are
   settled through the Needs-confirmation list.

### Step 3B — Extract `data-model.md` from the actual schema

1. Generate `docs/architecture/data-model.md` from the real migrations/DB schema — this is
   almost entirely mechanical extraction, so it rarely adds to the Needs-confirmation list,
   and only once the DB engine is confirmed in Step 1B.
2. Replace the template content of `docs/architecture/overview.md` with the as-is system
   context: components, every DB connection, external APIs, and how the frontend is served.
   This is mechanical — keep it to a diagram and a component table, and point to the stack
   ADR for detail.

### Triage — sort every candidate item before printing anything

The goal of the output is to minimize human review effort: a human should only be asked
what the code cannot answer (business meaning and intent). Sort every item collected in
Steps 1B-3B into exactly one bucket:

| Bucket | Test | Where it goes |
|---|---|---|
| Mechanical fact | Read directly from code/config/schema | The drafted docs only — never a list item |
| AI-verifiable | Can be settled by reading more code, grepping, or running a read-only command that touches no real database or external service (e.g. "does this class resolve?", "is this route referenced?") | Verify it now, then record the result as a fact. Do not ask the human |
| Code defect | A problem in the code itself (injection-shaped SQL, dead code, unsafe HTTP verb, wrong status code, domain-boundary violations) — the docs describe it accurately either way | **Backlog**. If users can observe it (e.g. a wrong status code), `use-cases.md` also records it as as-is behavior, not as a question |
| Needs human | Business meaning, intent, or a decision about which rules apply — cannot be derived from code, or requires access the AI must not use (e.g. the production DB) | **Needs confirmation** |

State each fact once, in its canonical file (stack/auth facts → the stack ADR), and point to
it from other files instead of repeating it — every duplicate is one more place to review.

## Output Format

Print the following three sections, in this order. Write them in the user's conversation
language.

### 1. Review Guide (print first)

The entry point that tells the human where to start. Keep it scannable.

1. **What was generated** — a table of every file created or changed, with *New* / *Replaced
   template* / *Partially edited* and a one-line summary of its content.
2. **Review order** — the files that contain a Needs-confirmation item, plus a replaced
   `authz-authn.md`, ranked:
   - **P1** — facts or decisions that change which rules apply or would invalidate other
     documents (e.g. the stack ADR, a replaced `authz-authn.md`, whether missing auth is
     intentional, which frontend rules apply). Answer these first, because the other
     answers depend on them.
   - **P2** — documents containing business-meaning inferences (e.g. `use-cases.md`,
     `glossary.md`, `CLAUDE.md`'s Main domains, `org-permission-philosophy.md`).
   - **P3** — mechanically extracted documents with isolated anomalies (e.g. `data-model.md`
     with one missing-migration discrepancy).

   For each file, state *what to look at* (the specific section or items) and *which
   question numbers* from section 2 it relates to — never "review the whole file."
3. **Defaults applied** — conservative defaults the AI chose instead of asking (e.g.
   uncertain do-not-touch boundaries). The human only acts if one is wrong.
4. **No review needed** — list the files that are purely mechanical extraction or replaced
   with as-is facts (e.g. `module-map.md`, `common-commands.md`, `overview.md`,
   `requirements.md`, `ui-guidelines.md`), so the human can explicitly skip or skim them.
   A file with any **[inferred]** marker or Needs-confirmation item never goes here, even
   if it is one of these examples.

### 2. Needs confirmation (blocking)

Resolving this list with the human *is* the Gate 0-3 sign-off.

- Number every item and phrase it as a question that can be answered in one line
  (yes/no, a choice, or a short definition). Tag it with its priority (P1-P3) and the
  file(s) its answer will update.
- Order by priority, then by dependency (an answer that changes other questions comes first).
- Ask the glossary terms, `CLAUDE.md`'s Main domains, and the role purposes from
  `org-permission-philosophy.md` as one question with a table to fill in. If the list
  still exceeds ~10 items, group other related ones the same way rather than listing them
  individually.
- Tell the human they can answer in chat by question number — the AI updates the documents,
  not the human.

### 3. Backlog (non-blocking, optional)

Existing code defects: `domain-boundary-check.sh --audit-all` findings plus the Code-defect
bucket from Triage, security-relevant items first. Explicitly note that this list is a
heads-up, not a requirement. Say which items come back on their own and which do not:
domain-boundary findings resurface on every future `/review`, but other code defects are
shown only this once, so the human should record any they want to keep (e.g. in their issue
tracker). Also list, when absent, the one-time test setup from `SETUP.md` Step 4
(`Model::shouldBeStrict`, `DB::prohibitDestructiveCommands`, `Http::preventStrayRequests()`, tests on MySQL instead of SQLite):
it can make existing tests fail and staging throw, so switching it on is the human's call.

Close with an explicit reminder to the human: **human review is required before any
development** — answer the Needs-confirmation questions (this is the Gate 0-3 sign-off),
and `/tdd` must not start until they are resolved. Then stop and wait; do not proceed to
any implementation work.

## After the Human Answers

1. Reflect each answer into the files tagged on that question; remove the resolved
   **[inferred]** markers and Needs-confirmation notes.
2. If an answer creates a new question, ask it — do not guess.
3. Once every item is resolved, re-run `bash .claude/hooks/spec-lint.sh` and show any
   remaining finding (e.g. an `[inferred]` marker left behind) with the sign-off request.
   Then ask the human for an explicit sign-off. Only after they
   give it, record it in `docs/product/use-cases.md`'s Approval Record (with the human as
   reviewer) and in `PLAN.md`. This single sign-off satisfies Gates 0-3. Never record it on
   your own judgment that everything is resolved.

## Constraints

- Never treat a stack mismatch, a business-meaning guess, or a code-vs-docs discrepancy as
  settled without verifying it in code or asking — see Core Principle above.
- Do not persist the Backlog list to a new file; it is chat output only (see
  `meta/adr/ADR-0011-existing-codebase-adoption.md` for why).
- Do not run the built-in `security-review` skill as part of this command — its diff-only
  scope wouldn't cover the inherited application code (see
  `meta/adr/ADR-0011-existing-codebase-adoption.md`).

## Usage Example

```
/onboard-existing-codebase
```

→ Runs the steps above and prints the three sections in Output Format.
