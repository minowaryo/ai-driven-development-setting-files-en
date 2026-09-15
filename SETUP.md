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
| New project — no existing code, requirements not yet written | Continue to **Step 1** below (unchanged) |
| Existing codebase — adopting this harness onto a project that already has running code (also called "brownfield adoption," e.g. in `meta/adr/ADR-0010`) | Skip to **Existing-Codebase Path** below, then rejoin at **Step 4** |

Both paths share Step 4 (TDD Red → Gate 4 → Green → Refactor) unchanged — they differ only
in how the Gate 0-3 inputs (`docs/ai-context/`, the stack ADRs, `use-cases.md`,
`data-model.md`) are produced. See `meta/adr/ADR-0011-existing-codebase-adoption.md` for why.

> This choice doesn't require reading this table first: if `docs/ai-context/project-summary.md`
> is still placeholder text and the repo already has substantial application code, its own
> template content proactively flags this and points here — before acting on whatever else
> was asked — since that file is read first in every session regardless of what the user typed.

### Step 1 — Select the frontend stack → fill in ai-context (do this first)

**1a. Frontend stack selection**

- Review the selection criteria and comparison table in `meta/adr/ADR-0005-frontend-stack.md` and decide this project's frontend stack
- Record the selection with the `/adr` command as `docs/adr/ADR-XXXX-frontend-stack-selection.md` (if you choose anything other than the default recommendation — Vue 3 + Inertia.js + Pinia — or are torn between candidates, document the reasoning and the rejected options)

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

### Step 2 — Create requirements documents

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

> **Mockup timing principle**: Mockups should be created between Gate 1 and Gate 2.
> The purpose is to align requirements understanding with the business side — Gate 3 (data model approval) does not need to be waited for.
> Incorporate mockup feedback into use-cases.md before Gate 2 approval.

### Step 3 — Architecture design

```
docs/architecture/data-model.md  ← Created by developers (AI may draft)
docs/architecture/overview.md    ← Created by developers
docs/adr/ADR-xxxx-[title].md     ← Created each time a technology decision is made
    ↓ Gate 3: reviewer approval
```

### Existing-Codebase Path — adopting this harness onto a project with running code

> Also called "brownfield adoption" elsewhere in this repo (e.g. `meta/adr/ADR-0010`).
> Use instead of Steps 1-3 when the project already has running code. Rejoin at Step 4
> once the single consolidated review below is complete.

**Core principle**: the running codebase is the source of truth for what currently
happens. Pre-existing org documentation (wikis, old specs, READMEs) is reference material
for cross-checking, never a substitute for reading the actual code, and never grounds for
silently overriding what the code does. **When in doubt, put it on the Needs-confirmation
list.** This is deliberately not a rulebook that tries to classify every situation in
advance — that would only get relitigated case by case with the user anyway. The one
firm guardrail is procedural: never resolve an ambiguity or a code-vs-docs disagreement
by guessing which side is right and drafting/implementing accordingly. Ask.

**Who does what**: see `docs/development/ai-workflow.md`'s "Role Breakdown" section, which
shows the New-Project and Existing-Codebase splits side by side. In short: AI drafts
everything below and compiles two lists (see below); the human resolves the blocking one
and gives one sign-off — not manually authoring any of these documents.

**Two lists, not one — only one of them blocks anything**:
- **"Needs confirmation"** (blocking) — affects whether the drafted documents are
  trustworthy: business-meaning guesses, do-not-touch boundary guesses, use-case
  discrepancies, stack mismatches significant enough to change which rules apply. Resolving
  this list *is* the Gate 0-3 sign-off.
- **"Backlog"** (non-blocking, suggestion only) — existing problems in the code itself,
  not in the documentation: `.claude/hooks/domain-boundary-check.sh --audit-all` findings.
  Presented as a heads-up, never required before moving on to Step 4. It doesn't need
  separate tracking: these findings resurface on every future `/review` anyway (per
  `ADR-0010`), so nothing here needs to be saved. (The generic `security-review` skill is
  a separate, diff-scoped tool available for any future PR that actually touches code — not
  part of this list, since onboarding's own diff is docs-only and running a diff-scoped
  security check against it wouldn't see the inherited application code at all.)

**Relationship to Claude Code's built-in `/init`**: do not run `/init` here — it scans the
codebase and (over)writes a single generic `CLAUDE.md`, which would clobber this template's
templated `CLAUDE.md` (Gate 0 pointer, "Read first" list, etc.) with a generic shape it
doesn't know about. `/onboard-existing-codebase` is best understood as an extended,
template-aware version of the same underlying idea ("AI reads the code and drafts
documentation") — it targets this harness's specific output shape
(`docs/ai-context/`'s five files) instead of one generic `CLAUDE.md`, adds backend/DB/auth
stack detection against `ADR-0001/0002/0003/0005` (not just a generic summary),
integrates `.claude/hooks/domain-boundary-check.sh`, and goes further than `/init` ever
does by also drafting `use-cases.md` (as-is behavior) and `data-model.md` — both outside
`/init`'s scope entirely — under the confidence-flagged "Needs confirmation" list mechanism.

**Fastest path**: run `/onboard-existing-codebase` to do Steps 1B-3B below in one pass. The
steps are also listed individually for when you want to run them by hand or re-run one.

**Step 1B — Detect the real stack, then reverse-engineer `docs/ai-context/`**
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

**Step 2B — Document current behavior as `use-cases.md` (as-is, not aspirational)**
- Draft `use-cases.md` from the actual code paths (routes → controllers → policies),
  labeled explicitly as current behavior, not a specification of desired behavior
- `requirements.md` is optional here — its purpose doesn't apply to code that already runs
- If the code disagrees with pre-existing org docs, add a **discrepancy note** to the
  Needs-confirmation list — never silently resolve it either direction; changing code or
  spec is a human decision under the existing rule in `.claude/rules/00-global.md`

**Step 3B — Extract `data-model.md` from the actual schema**
- Generate `data-model.md` from the real migrations/DB schema — almost entirely mechanical,
  so it rarely adds to the Needs-confirmation list, and only once the DB engine is
  confirmed in Step 1B

**Gate 0-3 for this path (one consolidated checkpoint, not four)**: a human resolves the
"Needs confirmation" list only, explicitly covering all of: ai-context accuracy, the
detected stack, `use-cases.md` accuracy, and `data-model.md` accuracy. That one sign-off
satisfies Gates 0 through 3 together. The Backlog list (architecture findings) is shown at
the same time but is never part of what's being signed off — read it or don't, act on it
now or later.

### Step 4 — Code generation and implementation (only after Gates 2 and 3 are passed)

> Same procedure for both paths (new project and Existing-Codebase).

Implementation proceeds via the `/tdd` command using **TDD (Red → Green → Refactor)**.

```
Red → [Gate 4: test case approval ★ implementation (Green) prohibited until passed] → Green → Refactor → /review
```

> Unlike Gates 0-3 (passed once per project), Gate 4 is repeated per feature/UC every time the TDD cycle runs.
> See `.claude/rules/30-testing.md` for the phase-by-phase steps, sub-agent setup, and when to run each skill.
