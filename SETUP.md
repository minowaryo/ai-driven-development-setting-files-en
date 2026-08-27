# SETUP.md

## ⚠️ Required Steps Before Starting the Project (Gate 0)

> **When to read this file**: once, at project kickoff, right after cloning this repository.
> It is not part of the steady-state per-session reading list in `CLAUDE.md` — once Steps 1-3 are
> complete and Gate 0-3 are passed, this file has no further effect on day-to-day work (Gate 4
> repeats per feature/UC, but that cycle is driven by `.claude/rules/30-testing.md` and the `/tdd`
> command, not by rereading this file).

Complete the following steps in order before touching any code.
AI cannot provide accurate assistance until these files are filled in.

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
| `docs/ai-context/prompt-patterns.md` | Standard prompt templates | Optional |

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

### Step 4 — Code generation and implementation (only after Gates 2 and 3 are passed)

Implementation proceeds via the `/tdd` command using **TDD (Red → Green → Refactor)**.

```
Red → [Gate 4: test case approval ★ implementation (Green) prohibited until passed] → Green → Refactor → /review
```

> Unlike Gates 0-3 (passed once per project), Gate 4 is repeated per feature/UC every time the TDD cycle runs.
> See `.claude/rules/30-testing.md` for the phase-by-phase steps, sub-agent setup, and when to run each skill.
