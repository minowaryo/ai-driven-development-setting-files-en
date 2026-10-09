# Test Viewpoints: Bugs That Escaped Tests, and a Viewpoint Trial (2026-10-08/09)

> Template-internal record (class X). Follows analysis A in `loop-stage2a-results.md`. Question
> from the maintainer: bugs are still found on screen after the tests pass — can the TDD cycle
> catch more of them, without making it heavier (time, tokens, usability)? The main users will
> likely be on Standard seats, so cost per cycle matters. Lab scripts: `C:\workspace\loop-stage2a-lab`
> (`escape_msgs.py`, `uat_dump.py`, `vp-run.sh`, `vp-grade.py`, `seeds/viewpoints*.md`).

## 1. What escaped (ihs-tech-uplift, no model usage)

Sources (read-only): the UAT triage sheets (UAT 2026-08-05), `fix` and display commits, and the
person's messages in 25 session logs. 21 items after merging items with one root cause. Most UAT
items come from code written before Gate 4 / TDD was adopted (2026-07-22), so this shows which
kinds of bug escape tests in this project, not which escaped TDD.

| Viewpoint group | Items | Examples | Caught by |
|---|---|---|---|
| A. Role × action × scope | ≈ 9 | trainer's own sessions missing from the calendar (list query wrong, Policy right); other-section records reachable (4 fixes); SectionHead cannot edit an Admin of own section; page visible to users with no role | Feature tests (TDD) |
| B. Screen mirrors the server | ≈ 5 | Add Pair button narrower than the Policy; no path to the assessment screen; Edit button left on the old rule (Stage 2a t3/t4) | Feature tests on page props, partly; the view side needs Vitest/E2E |
| C. Status and side effects | 2 | completed session still editable; child sessions not closed with the parent | Feature tests (TDD) |
| D. Links and paths in the frontend | 2 | link to a removed route; hard-coded root paths broken under the production sub-path (~200 places) | A deterministic static check, not TDD |
| E. Display mapping and format | 3 | date field blank; legend and N/A colours | Vitest on extracted logic |
| F. Input edges and no-op | 2 | irregular whitespace dropped on import; "no change" raised an error | Feature/Unit tests (TDD) |
| G. Spec gaps and UX choices | 6 | gap definition, minus sign, confirmation before a bulk overwrite, error wording, calendar default | Spec writing, not tests |

A, C and F (≈ 13 of 21) are server-side and TDD-catchable if the tests ask for them.

## 2. Trial: a viewpoint list for test-writer (≈ $5.5)

Three fixes whose parent spec already described the right behaviour (the fix changed code only):
c1 `4afa6dd` (3 bugs: calendar list, completed-session edit, TeamHead-who-is-trainer cancel),
c2 `20720fc` (log reachable through another session's URL), c3 `770217d` (another section's
plan viewable). test-writer (template version) wrote Feature tests for the UCs at the parent,
Red-style from the spec; caught = fails on the parent and passes with the fix's app files only.
Sonnet 5.5 medium, one run per arm. Arms: base; vp (8 viewpoints, one report line each); vp2
(2 always + 4 conditional, report only omissions); vp3 (the list viewpoint only, conditional,
plus a note that web forms answer validation errors with 302).

| Run | Known bugs caught | Tests failing on parent | Still failing after fix | Cost | Time | Report chars |
|---|---|---|---|---|---|---|
| c1 base | 1 / 3 | 8 | 7 | $0.70 | 285 s | 1,988 |
| c1 vp | 2 / 3 | 11 | 8 | $1.04 | 359 s | 5,280 |
| c1 vp2 | 2 / 3 | 16 | 14 | $0.92 | 353 s | 5,635 |
| c1 vp3 | 2 / 3 | 11 | 8 | $1.05 | 365 s | 3,679 |
| c2 base / vp | 1 / 1 each | 2 / 3 | 0 / 0 | $0.46 / $0.48 | 108 / 109 s | 2,357 / 2,803 |
| c3 base / vp | 1 / 1 each | 2 / 2 | 0 / 0 | $0.42 / $0.42 | 103 / 100 s | 2,412 / 2,891 |

Findings:

1. **The list viewpoint is the one that paid**: the calendar bug was caught in all three runs
   that had it and missed by the baseline. No arm caught the role + capability combination
   (TeamHead who is also the trainer), even when that viewpoint was spelled out.
2. **The baseline is already strong** when it writes from the spec for the whole UC (3 of 5
   bugs). The escaped bugs sat next to the change, in the same UC.
3. **Cost follows the number of tests and failures, not the prompt length**: the 4-line vp3 cost
   as much as the 8-viewpoint vp. With one run per arm the c1 cost difference (+32% to +50%
   on the Red step, ≈ +13–20% of a whole cycle) cannot be separated from run-to-run variance.
4. **The 302 note worked**: in vp3 the validation tests asserted session errors correctly, and
   those still failing then pointed at missing validation in the code rather than at test
   mistakes.
5. **Tests still failing after the fix** (c1, all arms): about 4–6 look like real spec/code
   disagreements at the time (SectionHead widening the calendar with another section's filter,
   cancel leaving the schedule entry, cancelled sessions still on the calendar, past dates and
   501-character reasons accepted). Unverified; the current code has since changed the spec. In
   a real Red phase these would become extra failures for the person to judge at Gate 4.

Limits: one run per arm, three cases, all authorization/state; tests were written as a UC
coverage pass, not as the Red phase of a change; cases chosen by the assistant.

## 3. Repeat runs on c1: base vs list viewpoint (2026-10-09, ≈ $3.2)

Two more runs per arm on c1 (vp3 text), so each arm has three:

| Arm | List bug caught | Completed-edit bug caught | Cost per run | Mean | Time (mean) | Report chars (mean) |
|---|---|---|---|---|---|---|
| base | 0 / 3 | 3 / 3 | $0.70, $0.86, $0.78 | $0.78 | 291 s | 3,152 |
| list viewpoint | **3 / 3** | 3 / 3 | $1.05, $0.91, $0.61 | $0.86 | 289 s | 3,586 |

The list viewpoint catches the bug every time and the baseline never does; mean cost +10%
(inside the run-to-run spread — the ranges overlap), time unchanged, report +14%. Neither arm
caught the role + capability bug in any run.

## Proposal (not decided)

- Add only the list viewpoint (vp3 text) to `test-writer`, applied when a UC in scope shows a
  list, calendar or index; no other viewpoints for now.
- Keep D (frontend paths) for a deterministic check, G for spec writing, and spec/code
  disagreements for a separate pass, so that the per-cycle cost stays flat for Standard users.
- Measure the cost on real cycles after adoption instead of more lab runs.
