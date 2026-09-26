# ADR-0012: Skills vs. commands, and the standalone-export convention

## Status
Accepted

## Date
2026-09-26

## Context

Every AI entry point this harness ships lived in `.claude/commands/` (`/adr`, `/review`,
`/tdd`, `/generate-mock`, `/generate-e2e-test`, `/onboard-existing-codebase`). Claude Code
now also supports `.claude/skills/<name>/SKILL.md`, and the two are invoked identically as
`/<name>`. The one real difference: a skill carries a `description` in frontmatter, which
lets the model invoke it on its own when the situation matches. A command only ever runs
when a human types it.

Two questions kept recurring and had no recorded answer:

1. When a new entry point is added, which of the two should it be?
2. How do we hand a single entry point to someone outside this repo without creating a
   second copy that drifts from the original?

Question 2 has a wrinkle specific to this harness. The in-repo version of an entry point
references Gate numbers, `meta/adr/` paths, and `.claude/rules/` files that mean nothing
outside the template, so a shareable version has to have those stripped. It also has to add
back what the in-repo version never needed to state — when the entry point applies, when it
does not, and why it exists — because in this repo those come from neighboring rule files
that the recipient will not have. The export is therefore a different file in both
directions, not a copy.

## Decision

**Criterion for new entry points:**

- **Forgetting to run it is the failure mode → make it a skill.** Put it in
  `.claude/skills/<name>/SKILL.md` with a `description` narrow enough to fire only in the
  situation it names.
- **Running it at the wrong moment is the failure mode → make it a command.** Leave it in
  `.claude/commands/<name>.md` with no `description`, so invocation stays a deliberate human
  act.

**The six existing entry points stay in `.claude/commands/`.** They all fall on the command
side of the criterion, and migrating them would churn every cross-reference in `SETUP.md`,
`README.md`, `.claude/rules/`, and `docs/ai-context/common-commands.md` for no functional
gain.

First application of the criterion: `/regenerate-traceability` ships as a skill. A
traceability matrix fails by going quietly stale, never by being rebuilt at an awkward
moment.

**Standalone exports are build output, not tracked files.** An entry point extracted for
sharing outside this repo is written to `dist/skills/<name>/SKILL.md`, which is
`.gitignore`d. The in-repo version stays the single source of truth; the export is
regenerated from it when someone wants to share it.

## Rationale

The criterion is phrased around failure modes rather than around "is it important" because
importance does not discriminate — `/review` and `/regenerate-traceability` are both
important, and they need opposite treatment. `ADR-0009` already established that `/review`'s
*invocation* is deliberately not automated (its Option A): the review level adapts
automatically, but the decision to review at all stays with the human. Giving `/review` a
`description` would quietly reverse that decision. The same logic protects `/tdd`
(auto-firing it would jump Gate 4's approval pause), `/generate-mock` (only valid between
Gates 1 and 2), and `/onboard-existing-codebase` (a once-per-project act).

`/generate-e2e-test` is a near-miss worth naming: it is already invoked automatically by
`/tdd` Step 6 when applicable, so a `description` would add a second, uncoordinated trigger
path rather than a missing one.

### Rejected Alternatives

- **Migrate all six commands to skills for consistency.** Uniformity is the only benefit,
  and it costs a cross-reference sweep across six files plus the risk that a `description`
  on `/review` or `/tdd` silently undoes a gate. Consistency that erodes a gate is not worth
  having.
- **Track the standalone export in the repo (e.g. commit `dist/`).** Two committed copies of
  the same instructions drift, and the drift is invisible — nothing fails when they
  disagree, so nobody notices until someone shares the stale one. Keeping the export
  untracked means it cannot be edited-in-place and quietly re-committed.
- **Share the in-repo file directly, unmodified.** The recipient gets dangling references to
  Gate numbers and `meta/adr/` paths that do not exist in their project. Stripping is not
  optional, so the export genuinely is a different file.

## Consequences

### Benefits

- Adding an entry point no longer reopens the skill-vs-command question
- The gates that `ADR-0009` and `.claude/rules/00-global.md` protect cannot be bypassed by
  an entry point acquiring an autonomous trigger
- A single entry point can be shared without the repo growing a second copy of it

### Drawbacks / Risks

- `dist/` goes stale silently when its source changes, because nothing regenerates it
  automatically. Accepted: exporting is a share-time action, not a per-commit one, so the
  right time to regenerate is the moment someone asks for the file
- The criterion needs judgment at the margin. An entry point whose failure mode is genuinely
  both (forgotten *and* mistimed) has no mechanical answer — write it as a command and
  mention it from a rule file, so the reminder exists without the autonomous trigger

## Related

- `meta/adr/ADR-0009-review-escalation-mechanism.md` — the Option A decision that `/review`'s
  invocation stays manual
- `.claude/rules/00-global.md` — the Gate 0-4 definitions the command-side entry points guard
- `docs/ai-context/common-commands.md` — the per-entry-point "who triggers it" table
