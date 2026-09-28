# ADR-0013: Adopting Selected Skill Concepts from Third-Party Sources (Trial)

## Status
Trial — see "Rollout tracking" below. Promote to Accepted once the batch has been used
for a while with no reported issues, or roll back per-item if one adds unwanted friction.

## Date
2026-09-28

## Context

A user-provided comparison evaluated the "Superpowers" Claude Code plugin
(`obra/superpowers`) against this harness's own Gate-based workflow. Verification
(GitHub issues #1480, #1456, #2377) confirmed Superpowers' SessionStart hook
force-injects roughly 1,300 tokens wrapped in `<EXTREMELY_IMPORTANT>` tags on every
session, and its TDD skill does not mechanically enforce a Red → approve → Green
boundary (issues #384, #2372) — both risk fighting this repo's own CLAUDE.md rules and
Gate 4's human-approval requirement (see `ADR-0014` for the decision not to install
Superpowers itself).

That evaluation surfaced four ideas genuinely missing from this harness that are worth
capturing without installing anything:

1. No skill embodies a debugging discipline for unclear bugs beyond
   `docs/ai-context/known-pitfalls.md` (which only covers *known* issues).
2. "Tests pass" is only checked against evidence narrowly — the post-Green `run` skill
   recommendation in `.claude/rules/30-testing.md` — with no general habit of verifying
   any "done" claim.
3. `.claude/rules/30-testing.md` states the Red → Green → Refactor cycle but says
   little about what makes an individual test *good* versus vacuous.
4. Drafting `docs/product/requirements.md` before Gate 1 has no structured technique —
   a separate `mattpocock/skills` repo's `grill-me`/`grilling` skill (interview-style,
   one question at a time) was found to address exactly this gap.

## Decision

Adopt in-house, rewritten versions of these four ideas — as new `.claude/skills/`
entries or edits to existing rule files, never as an installed third-party plugin —
all four in one pass, explicitly marked **Trial**:

1. New skill `.claude/skills/systematic-debugging/SKILL.md`
2. New skill `.claude/skills/verification-before-completion/SKILL.md`
3. New "Test Quality Heuristics" subsection added to `.claude/rules/30-testing.md`
4. New skill `.claude/skills/grill-me/SKILL.md` (adapted from and crediting
   `mattpocock/skills`)

Classification: items 1, 2, and 4 are self-invocable skills per the `ADR-0012`
criterion — forgetting to apply the discipline is the failure mode, not running them
at the wrong moment. Item 3 is a rule-file edit, not an entry point.

### Rollout tracking

| Item | Status | Notes |
|---|---|---|
| `systematic-debugging` | Trial | Watch for over-processing trivial fixes |
| `verification-before-completion` | Trial | Lowest expected friction — self-check only |
| Test Quality Heuristics (`30-testing.md`) | Trial | Plain text addition, no new entry point |
| `grill-me` | Trial | Highest friction risk — the only item that changes the *interaction pattern* with a human (one-question-at-a-time), rather than only tightening the AI's own internal discipline |

Update this table (and the Status line above) once the batch has been used enough to
judge; if any single item causes real friction, roll it back individually rather than
reverting the whole batch.

## Rationale

Writing these in-house avoids Superpowers' verified session-injection and
non-enforcement risks (`ADR-0014`) while still closing four real gaps. All four are
small, text-only additions — no new dependency, no plugin marketplace, no scripts.

### Rejected Alternatives
- **Install the Superpowers plugin and cherry-pick nothing**: rejected — see
  `ADR-0014`; the session-injection and TDD non-enforcement risks apply to the whole
  plugin, not just the parts we'd want.
- **Stage the four items one at a time with an observation period between each**:
  considered, but judged unnecessary overhead for changes of this size — three of the
  four (`systematic-debugging`, `verification-before-completion`, the test-quality
  bullets) only tighten the AI's own internal discipline and don't change how a human
  interacts with the workflow; only `grill-me` carries meaningfully different risk,
  and it's called out explicitly in the rollout table above instead of gating the
  whole batch on it.

## Consequences

### Benefits
- Closes a real gap: no existing skill addressed general debugging discipline or
  generalized completion-verification.
- `grill-me` gives Gate 1 requirements-drafting a repeatable technique instead of an
  unstructured conversation.
- Zero new dependencies or install steps — plain markdown, reviewed and owned in this
  repo.

### Drawbacks / Risks
- `grill-me` could make requirements drafting feel slower/naggier if used
  indiscriminately — its SKILL.md scopes it to genuinely ambiguous points, not every
  requirement.
- `systematic-debugging` could over-formalize trivial fixes if applied to a one-line
  typo — its SKILL.md narrows the trigger to unclear/non-trivial bugs.
- All four remain "Trial," so cross-references from `CLAUDE.md`, `README.md`, and
  `common-commands.md` are marked as such until promoted.

## Related
- ADR-0012-skills-vs-commands
- ADR-0014 (Superpowers wholesale rejection and other deferred third-party tools)
- `.claude/rules/30-testing.md`
- `.claude/rules/00-global.md`
