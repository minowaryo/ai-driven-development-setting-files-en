# Reviewer Input Narrowing and Residual Hints (design draft)

> Template-internal design note (class X). Drafted 2026-10-08 as prerequisite 3 of the ADR-0017
> outcome. Extends `loop-reviewer-design.md` (config R0). [U] = not verified. Nothing here is
> built into the template yet: the reviewer itself lives only in the Stage 2a lab until Stage 3
> decides to adopt it.

## Problem

Stage 2a check ③ (4 real-project replays) showed two things about the R0 reviewer:

1. **Cost**: ≈ $0.65 per review versus ≈ $0.09 in the lab, because the whole use-case document
   (≈ 95 KB, 57 UCs) was in every prompt.
2. **Blind spot**: in 2 of 4 tasks the implementation passed every approved test but left a
   *repeat* of the changed rule untouched — the controller line that decides whether the Edit
   button is shown (t3), the view that should read the new per-row flag (t4). A reviewer that
   sees only the diff cannot report a line that should have changed and did not.

## 1. Narrow the spec to the cycle's use cases

Pass only the `### UC-…` sections whose ids occur in the cycle's tests (the Red tests are
uncommitted during `/tdd`, so they are the changed test files). If no id is found, fall back to
the whole document and say so in the evidence (fail towards more context, not less).

| Task | Prompt before | After | Spec sections |
|---|---|---|---|
| t1 | 99 KB | 6 KB | 1 of 57 |
| t2 | 96 KB | 7 KB | 1 of 57 |
| t3 | 99 KB | 7 KB | 2 of 57 |
| t4 | 104 KB | 15 KB | 4 of 57 |

Expected cost ≈ $0.15–0.25 per review (not measured yet). Risk: a rule that lives in a UC the
tests do not name is invisible; the id convention (`->group('UC-NNN')`, backlog B11) makes the
mapping explicit once adopted.

## 2. Residual hints (deterministic, outside the diff)

Two scripted lookups produce an `<also_check>` block in the reviewer's input and the same lines
for the person. They state facts, never instructions, and never block.

| Hint | Rule | Found in |
|---|---|---|
| Repeated rule | A changed `app/Policies/<Model>Policy.php`; another file under `app/` or `resources/` (not a Policy, not changed) contains a role predicate (`isAdmin(`, `isSectionHead(`, `isTeamHead(`, `->role`, `can_trainer`) on a line that names the model | t3 (`canEdit` in the controller) |
| Unread addition | A controller line added in the diff sets `->can_*` / `->*_can` and nothing under `resources/` reads that name | t4 (`can_edit` set, never read) |

On the other two replays (t1, t2) neither hint fires.

**Honest limits**: both rules were written after seeing the two residuals, from four data
points, so they are fitted to them; they say nothing about other kinds of left-over repeats
(validation mirrored in JavaScript, copy in documentation, a second policy, a label). The
repeated-rule hint overlaps the Domain Boundary rule against inline role checks in controllers
and would fire on any project that already breaks it — that is acceptable for a hint (it shows
the person where the rule is repeated) but it must not turn into a gate. Treat the pair as a
first iteration to be re-measured on the next real project.

## Validation plan

Re-run the reviewer on t1–t4 with both changes (≈ $1 of usage) and compare with the first
run: cost per review; whether the two residuals are now reported; whether new noise appears on
t1/t2. Success: cost ≤ 40% of before, both residuals reported, no new findings on t1/t2 that a
person labels invalid.

## Where it would live

A small script in `.claude/hooks/` (spec slicing + the two hints, bash/awk like the other
checks, with its one test) when Stage 3 adopts the reviewer. Until then the lab's `rv.py`
carries the prototype.
