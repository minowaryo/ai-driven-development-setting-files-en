# ADR-0011: Existing-Codebase Adoption Path for Gate 0-3

## Status
Accepted

## Date
2026-09-15

## Context

`meta/adr/ADR-0004-ai-development-policy.md`'s workflow diagram assumes a **greenfield**
project: a human writes `requirements.md` from a blank page, then `use-cases.md`, then
`data-model.md`, before any code exists. Nothing in this harness addresses the opposite
case: adopting it onto a project that **already has running code** (mid-project adoption,
a legacy handoff, adding this harness to an existing app). In that case:

- There is no "we haven't decided what to build" step — the code already embodies
  decisions, possibly undocumented or drifted from whatever org docs exist.
- The natural Gate 0 activity flips from "a human authors `docs/ai-context/*` and
  `use-cases.md` from scratch" to "AI drafts them by reading the actual code, a human
  verifies against the running system."
- The running code, not pre-existing org documentation, is the source of truth for current
  behavior — a reverse-engineered `use-cases.md` must record disagreements between code and
  old docs as findings, never silently resolve them either direction. This is not a new
  rule: `.claude/rules/00-global.md`'s "User-Facing Behavior Changes Always Require
  Approval" already establishes, for any project at any stage, that a spec-vs-implementation
  mismatch is a finding to report, never a mandate to act. This ADR applies that existing
  rule to a specific drafting step; it does not introduce a competing one.
- This harness's own fixed stack assumptions (`ADR-0001` Laravel, `ADR-0002` MySQL,
  `ADR-0003` Sanctum + Policy/Gate) are not guaranteed to match an existing codebase the way
  they're guaranteed to match a fresh project built from this template. Only the frontend
  (`ADR-0005`) currently has a "detect/select per project" treatment — backend framework,
  DB engine, and auth mechanism do not, and existing code can easily diverge from all three.
- Human review time is the actual bottleneck this harness protects throughout (see
  `ADR-0009`'s `review-score` escalation and `ADR-0010`'s findings-priority signal); an
  onboarding design that asks a human to re-verify everything an AI drafts defeats the
  point of automating the drafting in the first place.

## Decision

### 1. A Step 0 branch inside Gate 0, not a fork

Add a "Step 0 — Determine adoption type" to `SETUP.md`, before the existing Step 1: a new
project continues to Step 1-4 unchanged; a project with existing code follows a new
"Existing-Codebase Path" (Step 1B-3B) instead, then rejoins at the existing Step 4 (TDD Red
→ Gate 4 → Green → Refactor, identical for both paths). This mirrors `ADR-0005`'s existing
pattern of branching *inside* Gate 0 rather than forking a file or a repository per
variant — Gate 1-4 mechanics and `.claude/rules/10-60` are identical either way, and only
how the Gate 0-3 *inputs* are produced differs.

Terminology: this repo already uses "brownfield" once, in `ADR-0010`, for exactly this
situation. New headings lead with the plain description ("Existing-Codebase Path") and keep
"(brownfield adoption)" as a parenthetical, rather than introducing a second competing term.

### 2. Stack detection, generalized from frontend to the whole stack

Step 1B detects frontend AND backend framework AND DB engine AND auth mechanism from the
actual code — the same "detect, don't just assume" treatment `ADR-0005` already gives the
frontend alone. A mismatch against `ADR-0001`/`ADR-0002`/`ADR-0003` (a different DB engine,
hand-rolled auth instead of Policy/Gate) is recorded as a "Needs confirmation" item, never
silently papered over. A **fundamental** mismatch (the backend isn't PHP/Laravel-family at
all) is a stop-and-flag: this path isn't a structural fit for that codebase, and forcing
Laravel-specific rules onto non-Laravel code would be actively misleading.

### 3. Two separate output lists — only one of them blocks anything

- **"Needs confirmation" list (blocking)** — only things affecting whether the *drafted
  documents themselves* are trustworthy: business-meaning guesses, do-not-touch boundary
  guesses, use-case-vs-old-doc discrepancies, and stack mismatches significant enough to
  change which rule files validly apply. Resolving this list *is* the Gate 0-3 sign-off —
  one consolidated human review, not four separate sequential approvals, since Step 1B-3B
  produce all of `docs/ai-context/*`, the stack ADR, `use-cases.md`, and `data-model.md` in
  one drafting pass. Gating them as four separate approvals (as greenfield does, where each
  document naturally arrives weeks apart) would be artificial ceremony here.
- **"Backlog" list (non-blocking, suggestion-only)** — existing problems *in the code
  itself*, not in the documentation about it: `.claude/hooks/domain-boundary-check.sh
  --audit-all` findings (Controllers doing DB access, inline role checks, etc.). Presented
  alongside the Needs-confirmation list but explicitly labeled "not required before
  proceeding." This directly operationalizes `ADR-0010`'s own framing, "brownfield adoption
  surfaces a backlog, not a blocker" — an earlier draft of this decision folded these
  findings into the blocking list, which directly contradicted that framing, and was
  corrected.
- **No dedicated file or directory for the Backlog list.** It is chat output only, the same
  as `/review`'s findings today. `domain-boundary-check.sh` already re-derives the identical
  findings live on every future `/review` per `ADR-0010`, so a saved snapshot would be a
  stale duplicate of something the harness already recomputes on demand, not a useful
  record.
- **The built-in `security-review` skill is deliberately not wired into onboarding.** Its
  own scope is "the pending changes on the current branch" (diff-scoped, like `/review`),
  unlike `domain-boundary-check.sh`, which specifically gained an `--audit-all` mode for
  whole-tree scans. Onboarding itself produces a docs-only diff — running a diff-scoped
  security review against *that* diff would review markdown files and miss the inherited
  application code entirely, giving a false sense of coverage. `security-review` stays what
  it already is: a general-purpose tool available on any future PR that actually touches
  code, run at the human's discretion — not a step this path adds, automates, or gives any
  special treatment to.

### 4. Confidence-flagged drafting

Every draft distinguishes *mechanically extracted* content (read verbatim from code/config
— usable as AI reference immediately, no human check needed) from *inferred/judgment*
content (guessed business meaning, guessed do-not-touch boundaries, stack mismatches,
use-case discrepancies). Only the latter goes on the Needs-confirmation list; existing-code
problems go on the Backlog list instead of either.

### 5. Human/AI division of labor, stated explicitly

`docs/development/ai-workflow.md`'s "Role Breakdown" now shows the New-Project and
Existing-Codebase splits side by side, not as a bolt-on note: same overall shape in both (AI
drafts/generates, human decides/approves; AI never generates implementation code before
human approval; final review and merge stays human-only) — what differs is *what* the human
is deciding on. Greenfield's human role is authoring from a blank page; existing-codebase's
is verifying/judging AI-drafted content against the real system.

### 6. Branch-start is partly automatic

`.claude/rules/00-global.md` is not in `CLAUDE.md`'s "Read first (every session)" list — it
is only consulted when relevant (e.g. during `/review`), so a detection heuristic placed
only there would not fire on an arbitrary first prompt like "add a login feature." The one
file guaranteed to be read first, every session, is `docs/ai-context/project-summary.md`
(it says so about itself, and it is the first line of `CLAUDE.md`'s "Read first" list). Its
template placeholder content therefore carries the detection heuristic: if it still shows
bracketed placeholders *and* the repo already contains substantial application code, flag
existing-codebase adoption before acting on whatever else was asked. `00-global.md` keeps a
secondary copy of the check as reinforcement, not as the primary trip-wire.

### 7. A new slash command, understood as an extended `/init`

`.claude/commands/onboard-existing-codebase.md`, same shape as `/generate-mock` / `/adr` /
`/tdd` / `/review`, runs Step 1B-3B end to end and ends in the two outputs above. Running
Claude Code's built-in `/init` on this template is not recommended — it scans the codebase
and (over)writes a single generic `CLAUDE.md`, clobbering this template's templated
`CLAUDE.md` (Gate 0 pointer, "Read first" list) with a generic shape it doesn't know about.
`/onboard-existing-codebase` is best understood as an extended, template-aware version of
the same underlying idea: it targets this harness's specific file shapes instead of one
generic `CLAUDE.md`, adds backend/DB/auth stack detection (not just a generic summary),
integrates `domain-boundary-check.sh`, and goes further than `/init` ever does by also
drafting `use-cases.md` (as-is behavior) and `data-model.md`.

### 8. Deliberately not a rulebook

This decision does not try to enumerate every kind of code-vs-docs ambiguity in advance —
that would keep needing relitigating case by case regardless, and would make initial setup
heavier for no real benefit. The one thing that is firm, procedurally: never resolve an
ambiguity by guessing and proceeding — put it on the Needs-confirmation list and ask. That
single guardrail is what prevents an AI from silently deciding "the code is right" (or "the
doc is right") and drafting or implementing on that guess, which is the actual failure mode
to prevent, not incomplete case coverage.

## Rationale

- `ADR-0005` precedent for branching inside Gate 0, generalized from frontend-only to the
  whole stack.
- `ADR-0009` (`review-score`) precedent for "route human effort to what needs it, not
  everything at equal intensity" — confidence-flagged drafting, the single consolidated
  checkpoint, and the blocking/non-blocking list split are that same principle applied to
  drafting, to gate structure, and to findings triage.
- `ADR-0010`'s own "backlog, not blocker" framing is the direct precedent for keeping
  `domain-boundary-check.sh` findings out of the gating list.

### Rejected Alternatives

- **A separate repository/template for existing-codebase adoption**: rejected. Gate 1-4
  mechanics and `.claude/rules/10-60` are identical for both paths; a fork would duplicate
  ~90% of the content and drift on every future template update.
- **Keeping four separate Gate approvals for this path**: rejected as artificial ceremony —
  all four artifacts arrive from one drafting pass, not weeks apart as in greenfield.
- **Folding Backlog findings into the gating Needs-confirmation list**: an earlier draft of
  this decision did this; rejected on review because it would make inherited
  architecture/security debt an unplanned blocker on unrelated work.
- **Wiring the built-in `security-review` skill into onboarding**: rejected — its diff-only
  scope means it would review the onboarding docs diff, not the inherited application code,
  giving a false sense of coverage without doing the job intended.
- **Persisting the Backlog list to a file**: rejected — `domain-boundary-check.sh` already
  regenerates identical findings on every future `/review`; a saved copy would only go
  stale.

## Consequences

### Benefits

- Existing projects gain a documented, generic on-ramp onto this harness instead of an
  implicit, ad hoc one.
- Human review time stays proportional to actual uncertainty: a small, well-understood
  codebase produces a short Needs-confirmation list and a fast sign-off; a large or
  ambiguous one produces a longer list, but never a full re-review of mechanically
  verifiable content.
- Gate 0-3 condition tables (`.claude/rules/00-global.md`, `AGENTS.md`) need only a one-line
  pointer, not a rewrite, so future edits to the procedure stay in one place (`SETUP.md`).

### Drawbacks / Risks

- AI-drafted "as-is" documents can be wrong; mitigated by making human resolution of flagged
  items part of the Gate 0-3 condition itself, not an optional courtesy.
- A codebase that isn't PHP/Laravel-family gets an honest "not a structural fit" flag
  instead of a misleading forced adoption — this is treated as correct behavior, not a gap
  to fix later.
- The Backlog list's non-persistence means a human who ignores it at onboarding time has no
  local record of it until the next `/review` — acceptable, since `/review` already runs
  before every merge per existing process.

## Related
- `meta/adr/ADR-0004-ai-development-policy.md` — the greenfield workflow this path branches from
- `meta/adr/ADR-0005-frontend-stack.md` — the branch-inside-Gate-0 precedent, generalized here
- `meta/adr/ADR-0009-review-escalation-mechanism.md` — the "route effort to what needs it" precedent
- `meta/adr/ADR-0010-domain-boundary-contract.md` — the "backlog, not blocker" precedent and `domain-boundary-check.sh`
- `SETUP.md` — Step 0 and the Existing-Codebase Path
- `.claude/commands/onboard-existing-codebase.md`
- `docs/development/ai-workflow.md` — Role Breakdown
- `.claude/rules/00-global.md`
- `docs/original-docs/README.md`
