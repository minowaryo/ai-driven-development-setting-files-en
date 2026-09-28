---
name: verification-before-completion
description: Before saying a task, fix, or feature is "done," "fixed," or "working," actually run the relevant command/test in this turn and check its output rather than asserting success from reading code alone. Use whenever about to report completion of anything — a Green phase, a bug fix, a refactor, a doc update, an onboarding/audit task. Generalizes the post-Green run-skill recommendation in .claude/rules/30-testing.md to every completion claim. Status: Trial (see meta/adr/ADR-0013).
---

# Verification Before Completion

"Tests pass" is necessary, not sufficient — mocking gaps or coverage gaps can make a
test suite green while the actual feature is broken. This applies beyond TDD: any
claim of completion should be backed by something you actually observed in this turn,
not inferred from reading the code.

## Rules

- **Never claim "done," "fixed," or "working" without running something.** If you
  changed code, run the relevant test or command in this turn and look at the output
  before reporting success.
- **Green is necessary, not sufficient.** After a TDD Green phase, recommend the `run`
  skill per `.claude/rules/30-testing.md` — passing tests don't by themselves prove
  the feature behaves correctly end to end.
- **Frontend changes**: don't claim a UI change works from reading the `.vue`/`.tsx`
  source. Build it (`.claude/rules/15-frontend.md`'s Vite reminder) and actually view
  it running before reporting it complete.
- **Bug fixes**: show both states — the regression test failing before the fix, and
  passing after — not just the final passing state.
- **If you can't verify it in this session** (no way to run the app, no test harness
  available, a manual/visual check that requires a human), say so explicitly instead
  of asserting success. This is already the rule for UI testing in this environment;
  this skill generalizes it to every kind of completion claim.
- **Applies to non-code deliverables too.** Don't claim a doc "matches the code"
  without having actually read the current code in this turn to confirm it.

## Related
- `.claude/rules/30-testing.md` — "Running skills after the Green phase completes"
- `.claude/skills/systematic-debugging/SKILL.md` — the debugging counterpart to this
  skill's "don't assume, check" principle
