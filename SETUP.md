# SETUP.md

## ⚠️ Required Steps Before Starting the Project (Gate 0)

> **When to read this file**: once, at project kickoff, right after cloning this repository.
> It is not part of the steady-state per-session reading list in `CLAUDE.md` — once Steps 1-3 are
> complete and Gate 0-3 are passed, this file has no further effect on day-to-day work (Gate 4
> repeats per feature/UC, but that cycle is driven by `.claude/rules/30-testing.md` and the `/tdd`
> command, not by rereading this file).

Complete the following steps in order before touching any code.
AI cannot provide accurate assistance until these files are filled in.

### Step 0 — Determine adoption type

| Situation | Path |
|---|---|
| New project — no existing code, requirements not yet written | Skip the Existing-Codebase Path section that follows and continue to the **New-Project Path** (Steps 1-3, unchanged) |
| Existing codebase — adopting this harness onto a project that already has running code (also called "brownfield adoption," e.g. in `meta/adr/ADR-0010`) | Continue to **Existing-Codebase Path** directly below, then rejoin at **Step 4** |

Both paths share Step 4 (TDD Red → Gate 4 → Green → Refactor) unchanged — they differ only
in how the Gate 0-3 inputs (`docs/ai-context/`, the stack ADRs, `use-cases.md`,
`data-model.md`) are produced. See `meta/adr/ADR-0011-existing-codebase-adoption.md` for why.

```
Step 0 — determine adoption type
   ├─ existing code → Existing-Codebase Path: Steps 1B-3B ─┐
   └─ new project   → New-Project Path:       Steps 1-3  ──┤
                                                           ↓
                                              Step 4 (shared by both)
```

> This choice doesn't require reading this table first: if `docs/ai-context/project-summary.md`
> is still placeholder text and the repo already has substantial application code, its own
> template content proactively flags this and points here — before acting on whatever else
> was asked — since that file is read first in every session regardless of what the user typed.

### Existing-Codebase Path (Steps 1B-3B) — the project already has running code

> **New project? Skip this whole section** and go straight to the New-Project Path below it.
> Also called "brownfield adoption" elsewhere in this repo (e.g. `meta/adr/ADR-0010`).
> Replaces Steps 1-3; rejoin at Step 4 once the consolidated review below is complete.

**Fastest path**: right after Step 0 routes you here, run the command below to do Steps
1B-3B in one pass — the New-Project Path's Steps 1-3 do not apply to you. The rest of this
section explains what the command does and why; Steps 1B-3B are also listed individually
further down for when you want to run them by hand or re-run one.

```
/onboard-existing-codebase
```

→ Detects the stack, drafts `docs/ai-context/*`, `use-cases.md`, and `data-model.md`, and
ends by printing the Needs-confirmation and Backlog lists for human review (see
`.claude/commands/onboard-existing-codebase.md`). Once the Needs-confirmation list is
resolved, rejoin at Step 4.

**Core principle**: the running codebase is the source of truth for what currently happens.
Pre-existing org documentation (wikis, old specs, READMEs) is cross-checking material only —
never a substitute for reading the actual code, never grounds for silently overriding it.
**Never settle an ambiguity or a code-vs-docs disagreement by guessing which side is right
and drafting on that guess — put it on the Needs-confirmation list and ask.**

**Who does what**: AI drafts every document below and compiles the two lists; the human
resolves the blocking list and gives one sign-off, instead of authoring the documents by
hand. See `docs/development/ai-workflow.md`'s "Role Breakdown" for both paths side by side.

**Two lists, not one — only one of them blocks anything**:
- **"Needs confirmation"** (blocking) — anything affecting whether the drafted documents are
  trustworthy: business-meaning guesses, do-not-touch boundary guesses, use-case
  discrepancies, stack mismatches significant enough to change which rules apply. Resolving
  this list *is* the Gate 0-3 sign-off.
- **"Backlog"** (non-blocking, suggestion only) — problems in the existing code itself, not
  in the documentation: `.claude/hooks/domain-boundary-check.sh --audit-all` findings. A
  heads-up, never required before Step 4, and saved nowhere — the same findings resurface on
  every future `/review` (`ADR-0010`).

**Do not run Claude Code's built-in `/init` here**: it would overwrite this template's
`CLAUDE.md` (Gate 0 pointer, "Read first" list, etc.) with a generic one.
`/onboard-existing-codebase` is the template-aware version of the same idea, and also drafts
`use-cases.md` and `data-model.md`, which `/init` never touches.

> Why each of these is shaped this way — no case-by-case rulebook, why the built-in
> `security-review` skill is deliberately not part of onboarding, why the Backlog list is not
> persisted: `meta/adr/ADR-0011-existing-codebase-adoption.md`.

#### Step 1B — Detect the real stack, then reverse-engineer `docs/ai-context/`

- Detect the actual frontend, backend framework, DB engine, and auth mechanism from the
  code (`composer.json`/`package.json`, migrations, routes, auth config) instead of
  assuming `meta/adr/ADR-0001`/`ADR-0002`/`ADR-0003`/`ADR-0005` automatically hold
  - Matches the template's assumptions → proceed
  - Diverges (different DB engine, hand-rolled auth instead of Policy/Gate, etc.) → add to
    the "Needs confirmation" list as a named mismatch, don't silently rewrite either side
  - Backend isn't PHP/Laravel-family at all → stop and flag: this template's
    Existing-Codebase Path isn't a structural fit for this codebase
  - Record the detected frontend/backend stack via `/adr`, Decision section stating what
    was *found*, not *chosen*
- Run `.claude/hooks/domain-boundary-check.sh --audit-all`; its findings go on the
  **Backlog** list, never the Needs-confirmation list — this is exactly the "backlog, not
  a blocker" case `ADR-0010` already anticipated, and keeps inherited architecture debt
  from blocking the feature work someone actually came here to do
- Draft `project-summary.md`, `module-map.md`, `glossary.md`, `common-commands.md`,
  `do-not-touch.md` from what is actually there; only business-meaning guesses and
  uncertain do-not-touch boundaries go on the Needs-confirmation list — mechanically-read
  content doesn't go on either list

#### Step 2B — Document current behavior as `use-cases.md` (as-is, not aspirational)

- Draft `use-cases.md` from the actual code paths (routes → controllers → policies),
  labeled explicitly as current behavior, not a specification of desired behavior
- `requirements.md` is optional here — its purpose doesn't apply to code that already runs
- If the code disagrees with pre-existing org docs, add a **discrepancy note** to the
  Needs-confirmation list — never silently resolve it either direction; changing code or
  spec is a human decision under the existing rule in `.claude/rules/00-global.md`

#### Step 3B — Extract `data-model.md` from the actual schema

- Generate `data-model.md` from the real migrations/DB schema — almost entirely mechanical,
  so it rarely adds to the Needs-confirmation list, and only once the DB engine is
  confirmed in Step 1B

**Gate 0-3 for this path (one consolidated checkpoint, not four)**: a human resolves the
"Needs confirmation" list only, explicitly covering all of: ai-context accuracy, the
detected stack, `use-cases.md` accuracy, and `data-model.md` accuracy. That one sign-off
satisfies Gates 0 through 3 together. The Backlog list (architecture findings) is shown at
the same time but is never part of what's being signed off — read it or don't, act on it
now or later.

### New-Project Path (Steps 1-3) — no existing code yet

> **Came through the Existing-Codebase Path above? Skip this whole section** and go straight
> to Step 4. Steps 1-3 below are the from-scratch equivalent of Steps 1B-3B: a human authors
> the same Gate 0-3 inputs instead of AI reverse-engineering them from running code.

#### Step 1 — Select the frontend stack → fill in ai-context (do this first)

**1a. Frontend stack selection**

- Review the selection criteria and comparison table in `meta/adr/ADR-0005-frontend-stack.md` and decide this project's frontend stack
- Record the selection with the `/adr` command as `docs/adr/ADR-XXXX-frontend-stack-selection.md` (if you choose anything other than the default recommendation — Vue 3 + Inertia.js + Pinia — or are torn between candidates, document the reasoning and the rejected options)

  ```
  /adr
  ```

  → Prompts for the decision content and creates the next-numbered `docs/adr/ADR-XXXX-[title].md` (see `.claude/commands/adr.md` for the template it fills in)

**1b. Reflect the confirmed selection into the rule file**

- Rewrite `.claude/rules/15-frontend.md` to match the selected stack (if you selected Vue 3 + Inertia.js + Pinia, the default content can be used as-is)
- Rewrite the Frontend section of `docs/ai-context/module-map.md` to match the actual directory layout (do not leave it as the placeholder example)

**1c. Fill in ai-context**

> Before creating these files, place primary source materials (requirement notes, screen sketches, etc.) in `docs/original-docs/` and reference them.
> After Step 1 is complete, do not use `docs/original-docs/` as the default reference.
> Transcribe the 1a selection result into the Frontend row of `project-summary.md`.

| File | Content | Priority |
|---|---|---|
| `docs/ai-context/project-summary.md` | Full project overview, purpose, and tech stack | Required |
| `docs/ai-context/glossary.md` | Project-specific terms and abbreviations | Required |
| `docs/ai-context/module-map.md` | Directory structure and module responsibilities | Required |
| `docs/ai-context/do-not-touch.md` | Areas and files AI must not modify | Required |
| `docs/ai-context/common-commands.md` | Frequently used commands (migrate / test / lint, etc.) | Recommended |

#### Step 2 — Create requirements documents

```
docs/product/requirements.md        ← Created by business team / BA
    ↓ Gate 1: reviewer approval
docs/product/use-cases.md           ← Created by business team / BA (AI may draft)
    ↓
docs/product/mockups/               ← AI may draft (/generate-mock command)
    Business review → incorporate feedback into use-cases.md
    ↓ Gate 2: final reviewer approval ★ Code generation prohibited until this gate is passed
docs/product/acceptance-criteria.md ← AI may draft
```

Mockup generation, one UC at a time:

```
/generate-mock UC-006
```

→ Generates `docs/product/mockups/screen-UC006-[screen-name].html` and adds it to the screen list in `docs/product/mockups/README.md` (see `.claude/commands/generate-mock.md`)

> **Mockup timing principle**: Mockups should be created between Gate 1 and Gate 2.
> The purpose is to align requirements understanding with the business side — Gate 3 (data model approval) does not need to be waited for.
> Incorporate mockup feedback into use-cases.md before Gate 2 approval.

#### Step 3 — Architecture design

```
docs/architecture/data-model.md  ← Created by developers (AI may draft)
docs/architecture/overview.md    ← Created by developers
docs/adr/ADR-xxxx-[title].md     ← Created each time a technology decision is made
    ↓ Gate 3: reviewer approval
```

### Step 4 (both paths) — Code generation and implementation (only after Gates 2 and 3 are passed)

> Same procedure whichever path above you came through.

Implementation proceeds via the `/tdd` command using **TDD (Red → Green → Refactor)**.

```
Red → [Gate 4: test case approval ★ implementation (Green) prohibited until passed] → Green → Refactor → /review
```

Run one TDD cycle per feature/UC:

```
/tdd UC-006 Order list filter feature
```

→ Runs Red (failing tests via the `test-writer` sub-agent) and stops at Gate 4 for your
approval before Green (implementation via the `tdd-implementer` sub-agent) and Refactor
(see `.claude/commands/tdd.md`)

> Unlike Gates 0-3 (passed once per project), Gate 4 is repeated per feature/UC every time the TDD cycle runs.
> See `.claude/rules/30-testing.md` for the phase-by-phase steps, sub-agent setup, and when to run each skill.
