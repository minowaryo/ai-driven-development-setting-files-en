---
name: grill-me
description: A one-question-at-a-time interview technique for drafting or updating docs/product/requirements.md before Gate 1 — surfaces ambiguous actors, success criteria, edge cases, and non-functional constraints one at a time instead of guessing at them. Use when starting or substantially revising requirements.md. Adapted from mattpocock/skills' grill-me/grilling pattern (credited below). Status: Trial (see meta/adr/ADR-0013) — the item most worth watching for added back-and-forth friction; use it only where the requirement is genuinely unclear, not on every line.
---

# Grill Me

Adapted from [mattpocock/skills](https://github.com/mattpocock/skills)' `grill-me` /
`grilling` pattern, rewritten for this repo's Gate/UC vocabulary.

An interview technique for turning a vague or partial requirement into something
`docs/product/requirements.md` can state precisely — used only for the parts that are
actually ambiguous, not as a forced ritual over an already-clear requirement.

## Scope

- Applies only to `docs/product/requirements.md`. Do not use it to draft
  `docs/product/use-cases.md` or any code — that would cross the Gate 1 → Gate 2
  boundary in `.claude/rules/00-global.md`.

## Process

1. Read what's already in `docs/product/requirements.md` and `docs/original-docs/`
   for this requirement.
2. Identify the open questions: who the actors are, what counts as success, edge
   cases, non-functional constraints (performance, data volume, compliance).
3. Ask **one question at a time** — wait for the answer before asking the next one.
   Don't front-load a long list of questions; a single unclear point is easier to
   answer than a wall of them.
4. Update `requirements.md` incrementally as each answer comes in, rather than
   batching all edits until the end.
5. Repeat until no open questions remain, then say so explicitly: "No open questions
   — ready for Gate 1 review."

## Guardrail

**Never fill in an assumed answer to move faster.** An unanswered question blocks
Gate 1 review — it does not get silently guessed and written down as if answered.
Guessing here is exactly the failure mode Gate 1 exists to catch, just moved earlier
and made less visible.

## Related
- `docs/product/requirements.md`
- `.claude/rules/00-global.md` — Gate 1 condition
- `docs/original-docs/` — primary sources this draws from (read-only)
