# Non-stop After Approval — Goal Definition

> Template-internal design note (class X). Written 2026-10-09 from the maintainer's decision of
> 2026-10-08 (`PLAN.md`, ADR-0017 follow-up). Nothing here changes a Gate or a command yet; each
> gap below goes through the normal flow (design → approval → branch). [U] = not verified.

## Goal

After a person approves, the work runs **without stopping** through implementation, checks,
review, in-spec fixes and a completion report. It stops **only** where a machine-checked
guardrail says a person must decide. The person's time goes to judgments, not to go-aheads
(analysis A: 9 of 10 Green cycles needed one implementer call; most messages after Green were
"proceed" or a command a person had to start).

Not the goal: an automatic retry loop, auto-merge, production operations, or removing Gate 4.

## The non-stop stretch

| | Today | Target (this stage) | Later, on numbers |
|---|---|---|---|
| Starts at | each step needs a go-ahead | **Gate 4 approval** | spec approval (Gate 2), once a machine check is shown to replace Gate 4 |
| Runs through | Green; person starts `/verify`, `run`, `/review` | Green → goal check → full suite → review → in-spec fixes (one round) → screenshots → completion report | same |
| Ends at | many small approvals | **one approval** of the completion report, covering commit → merge → push (`lite`) | same; merge stays human |

People still decide: the spec (Gates 0–3), the tests (Gate 4), and the final report.

## Stop conditions

The stretch stops and asks a person when any of these fires. "Machine" means a script decides;
"prompt" means only an instruction does — the gaps to close first.

| # | Condition | Detected by | Today |
|---|---|---|---|
| S1 | The goal moved: `tests/` or `docs/product/` changed after approval | `tdd-snapshot.sh verify` exit 2 | Machine |
| S2 | Application code compares against a value only the tests contain | `fixture-literal-check.sh` exit 2 | Machine |
| S3 | A check could not run (no snapshot, tool error) | exit 3 of any check | Machine |
| S4 | The implementer reports `SPEC_CONFLICT` | its report; `/tdd` Step 3 | Prompt |
| S5 | Attempt limit: a third implementer run, 3 Green attempts, or the same failure twice | `agent-guard.sh` (runs); `/tdd` Step 3 (attempts) | Machine for runs (2026-10-13); prompt for attempts |
| S6 | Cycle-review finding that needs a judgment (security, suspect instruction, spec conflict or user-facing change at MEDIUM+, or any HIGH) | `cycle-reviewer` findings, routed by `/tdd` Step 7 | Prompt — the main session applies the route from written rules (2026-10-13, ADR-0019) |
| S7 | A user-facing behaviour change the approved spec does not cover | `tdd-snapshot.sh mark-green` / `verify-green`; the cycle review's `USER_FACING_CHANGE` as a second signal | Machine for permission, destructive, security, secret, outside-effect, dependency and integrity changes after Green (2026-10-12); other user-facing changes are listed for the final review. Was prompt only and failed once (2026-09-10) |
| S8 | A sensitive path changed (migration, auth, config, security) | `review-score.sh` sensitive paths | Machine, but only at merge |
| S9 | Budget: the implementer's writes and commands for the stretch exceeded (stand-in for time and tokens) | `agent-guard.sh` | Machine (2026-10-13) |

Not a stop: reviewer findings that are inside the approved spec and change nothing a user sees
(a missing test for specified behaviour, an N+1, a Domain Boundary slip). The AI fixes them in
**one** round, re-runs the checks, and lists them in the report; anything left goes to the person.

## What the person sees at the end

One completion report, judgment items first, kept short (target: no longer than today's Gate 4
report):

1. **Needs your decision** — anything that stopped the stretch, and reviewer findings not fixed.
2. **Screens changed** — one line naming the new and changed screens (git only); new screens
   are captured per role and the screenshot folder is linked (saved, **not read back by the
   model**); changed ones on request. Only when a screen changed; screenshots only where
   Playwright is set up (`e2e-screenshot-report.md`).
3. **Checks** — test counts, goal check, fixture check, and the blocked-attempt lines from
   `logs/audit.jsonl` as printed.
4. **Fixed without asking** — one line each.
5. **Also check** — residual hints (a rule repeated elsewhere and left unchanged).
6. **Proposed commits and merge plan** — one approval runs them.

## Cost and usability budget

Main users will likely be on Standard seats. The stretch adds **no model call except the
reviewer** (≈ $0.3 per review with spec slicing, `reviewer-input-and-residuals.md`);
deterministic checks cost 0 tokens; screenshots are not read by the model. Target per cycle:
no more than about +20% against today's cycle with a manual `/review`, and fewer messages for
the person.

## Gaps, in order

1. **S7 by machine** — a deterministic trigger for user-facing change outside the spec, with the
   reviewer's user-facing category as a second signal — built 2026-10-12
   (`s7-user-facing-stop.md`, ADR-0019 item 2).
2. **Reviewer into the template** — run inside the stretch as a finder only — built 2026-10-13
   as the `cycle-reviewer` sub-agent, not a script (`cycle-reviewer.md`, ADR-0019 item 3); its
   route is applied by the main session from written rules.
3. **Screenshots** of changed screens, linked from the report — designed and built 2026-10-12 in
   `prepare-merge` (`e2e-screenshot-report.md`).
4. **Chaining `/tdd` Steps 4–8** into the stretch, with S5 and S9 limits — built 2026-10-13
   (`stretch-chaining-limits.md`).
5. **Guardrail regression suite** — re-run the Stage 2a seeds when the model or Claude Code
   changes (`loop-stage2a-results.md`) — built 2026-10-15 (`guardrail-regression-suite.md`).
6. **Pilot** on a real project, measured against analysis A (messages per cycle, cost, escapes).

## Related

ADR-0016 (Stage 1), ADR-0017 (Stage 2a and follow-up), `loop-reviewer-design.md`,
`reviewer-input-and-residuals.md`, `fixture-literal-check.md`, `rule-enforcement-inventory.md`,
`meta/history/loop-stage2a-results.md`, `meta/history/test-viewpoints-results.md`.
