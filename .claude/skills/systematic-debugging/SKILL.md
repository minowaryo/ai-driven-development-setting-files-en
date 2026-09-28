---
name: systematic-debugging
description: A debugging discipline for an unclear bug, an unexpected test failure, or a fix attempt that didn't work — reproduce and localize the cause before changing code, and treat repeated failures as a signal to question the design rather than try another patch. Use when investigating a non-trivial bug or when a previous fix attempt in this session didn't resolve it. Check docs/ai-context/known-pitfalls.md first for a known issue before applying this. Status: Trial (see meta/adr/ADR-0013) — an in-house rewrite, not an installed plugin.
---

# Systematic Debugging

A non-trivial bug rewards investigation before editing. This skill is a discipline for
that investigation, not a checklist to apply to every one-line typo — for an obvious,
localized fix, just make it.

## Before touching implementation code

1. **Reproduce it first.** Have a minimal failing reproduction — a failing test, or an
   exact command/input that triggers the symptom — before changing anything. A fix you
   can't watch fail first is a guess, not a fix.
2. **Read the whole error.** The full stack trace / log output, not just the symptom
   line. Guessing the cause from the symptom alone skips information that's already in
   front of you.
3. **Check `docs/ai-context/known-pitfalls.md` first.** If this is a known
   library/framework snag, the fix is already recorded — don't re-derive it.
4. **Localize before fixing.** Narrow the failure to the smallest unit that reproduces
   it (a function, a query, a component) before editing anything outside that unit.

## When a fix attempt doesn't work

- **After 1 failed attempt**: re-read the error again — did the fix address what the
  error actually said, or what you assumed it said?
- **After 2 failed attempts**: stop guessing at fixes. Write down what you now know is
  *not* the cause, and re-examine the assumption the first two attempts shared.
- **After 3 failed attempts**: treat it as a design question, not a bug. The failing
  test or the current approach may be encoding a wrong assumption — reconsider the
  approach itself rather than writing a 4th patch.

## Do not mask the symptom

Loosening a test assertion, adding a `try`/`catch` that swallows the error, or
suppressing a warning are not fixes — they hide the failure from view without
resolving it, and contradict the "no error handling for scenarios that can't happen"
principle this repo already applies to production code.

## Once the cause is found

Follow `.claude/rules/30-testing.md`'s TDD cycle: write the regression test first,
confirm it fails for the reason you just diagnosed (not some other reason), then
implement the fix.

## Related
- `docs/ai-context/known-pitfalls.md` — check first, append once resolved
- `.claude/rules/30-testing.md` — regression-test-first rule for bug fixes
- `.claude/skills/verification-before-completion/SKILL.md` — don't declare the bug
  fixed without actually re-running the reproduction
