# Chaining the Stretch, with Attempt and Budget Limits (design draft)

> Template-internal design note (class X). Drafted 2026-10-13 as gap 4 of `nonstop-goal.md`
> (stop conditions S5 and S9). Decision: ADR-0019. Limits come from existing data and are
> tuned in the pilot. [U] = not verified.

## Problem

1. **Chaining** — after Gate 4, `/tdd` still tends to pause between steps ("present the results")
   and Step 5 asks the person to start the `run` skill. The stretch should go from Gate 4
   approval to one completion report without waiting, stopping only on a stop condition.
2. **S5 attempt limit** and **S9 budget** live only in prompts (`tdd-implementer.md`, `/tdd`
   Step 3). A runaway implementer — retrying, or being re-invoked — is not stopped by a machine.

## Data (ihs-tech-uplift session logs, 10 implementer runs, read-only)

| Measure | Observed |
|---|---|
| Implementer runs per cycle | 1 in 9 cycles, 2 in 1 |
| Tool calls per implementer run (all tools) | 9–34 |
| Test runs per implementer run | 2–7 |
| Minutes per run | not usable (includes the person's idle time) |

## Proposal

### Chaining (`/tdd` wording only)

- One rule in the command: **from Gate 4 approval to the Step 8 report, do not wait for the user
  between steps; stop only where a step says "stop"** (S1–S7, S5, S9 below).
- Step 5 no longer pauses: the suggestion to try the app with the `run` skill moves into the
  Step 8 report (it is person-started by design).
- Step 8 is the completion report from `nonstop-goal.md`: judgment items first, then changed
  screens (the screenshots `prepare-merge` captures), checks, fixed without asking, also check,
  and — in `lite` — the proposed commit and merge plan, so one approval runs the rest.

### Limits (machine, in `agent-guard.sh`; nothing to configure)

| Limit | Counted | Limit | Reset | On reaching it |
|---|---|---|---|---|
| S5 — implementer runs | each `Agent` call with `subagent_type: tdd-implementer` by the main session | **2** per Gate 4 approval (observed max 2) | `tdd-snapshot.sh record` (Gate 4) | the 3rd call is denied: "the implementer has run twice since Gate 4 approval — show its reports to the user and wait"; another approval (record) allows two more |
| S9 — implementer budget | each Write / Edit / Bash / PowerShell call the implementer makes | **60** per Gate 4 approval (≈ 2× the observed all-tool maximum of 34) | same | further calls are denied: "budget for this cycle reached — stop and report what is done and what is left" |

- The counters are two small files next to the approved snapshot (`.git/claude-tdd/approved/`),
  which is already locked for the implementer; they exist only inside a `/tdd` cycle, so nothing
  is counted outside one.
- Builtins only (`read`, `printf` redirection) — no subprocess on the allow path, as now.
- Each denial is written to `logs/audit.jsonl` like the other denials, so `verify` shows it.
- Settings: the `PreToolUse` matcher gains `Agent|Task`. Verified on Claude Code 2.1.288
  (2026-10-13, `claude -p`): the hook receives `"tool_name":"Agent"` with
  `"subagent_type":"tdd-implementer"` in `tool_input` and no `agent_type` (the main session).
  [U] in the VS Code extension's newer versions — re-checked by the regression suite (gap 5).

## Not covered

- Time is not limited: wall-clock time in the logs mixes in the person's idle time, and a
  hook cannot see token counts. Tool calls stand in for both.
- The cycle reviewer is one pass with read-only tools; it has no counter.
- "The same failure twice" stays in the implementer's prompt.

## Cost

0 tokens; the counter adds two builtin reads and one write to calls the hook already sees
(≈ +1 ms). Usability: no new step or setting; the limits are about twice what real cycles used.

## Built (2026-10-13)

- `agent-guard.sh`: counters `.implementer-runs` / `.implementer-calls` in the approved-snapshot
  directory, found from the payload's `cwd` by walking up to `.git` (a worktree's `.git` file is
  followed). `Task` is counted like `Agent` (older name). The S5 denial is logged with
  `"agent_type":"main"` — the caller — and rule `implementer_runs`; S9 with rule `budget`.
  `tdd-snapshot.sh` is unchanged: `record` already replaces the whole directory.
- Tests: 19 cases added to `meta/tests/agent-guard.test.sh` (83 total; 5 fail on the previous
  script — the deny cases). Hook time on Windows Git Bash: no difference from before (A/B, 40 calls).
- End to end (lab, pinned Claude Code 2.1.288, Haiku 4.5, `claude -p`, ≈ $0.12 for both runs):
  three starts asked for → two ran, the third was refused with the S5 message and logged
  (`"agent_type":"main"`); with the call count seeded at 58, the implementer's third command
  was refused with the S9 message and `tdd-snapshot.sh verify` printed the denial line.
- `/tdd`: the chaining rule above Step 0; Step 4 continues (in `standard`, the Red + Green commit
  is the one planned pause); Step 5 does not pause; Step 8 is the six-part completion report.
