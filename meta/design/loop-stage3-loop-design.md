# Loop Engineering Stage 3 — Bounded Green Loop Design (draft)

> Template-internal design draft (class X). Becomes an ADR only if Stage 2 says "go".
> Drafted 2026-10-03. Items marked [U#] are not yet verified hands-on; [V] = verified
> hands-on on Claude Code 2.1.278 (Windows 11, Git Bash, `claude -p`) on 2026-10-03.

## Shape

Inside a human-started `/tdd`, the Green phase loops until the deterministic gate passes,
bounded; a read-only reviewer then reports findings; humans decide every exit.

```
 human types /tdd UC-x
IDLE ─────────► RED ──red-check ok──► AWAIT_GATE4 ◄──────────────────────────┐
                ▲  (test-writer)        │ human types `/tdd approve`           │
                │                       ▼                                       │
                │                    LOCKED (snapshot taken)                    │
                │                       ▼                                       │
                │          ┌─block─ GREEN(n) ──stop──► VERIFY [SubagentStop: gate]
                │          │ fail, n<3, new fingerprint    │                    │
                │          └───────────────────────────────┤                    │
                │                                 pass │    │ n=3 | same failure | tamper | SPEC_CONFLICT
                │                                      ▼    ▼                    │
                │                                 REVIEW  ESCALATED ─────────────┤
                │                          (read-only reviewer)                  │
                │                                      ▼                         │
                └──── human: TEST_GAP ──────── AWAIT_HUMAN ◄─────────────────────┘
                      human: +N attempts → GREEN · spec issue → leave cycle (UC edit)
                      human: accept → REFACTOR (gate stays green) → DONE → /commit
```

- Dropped from memo §19: PLANNING (covered by UC + Gate 2), APPROVED / PR_READY (no AI
  approval; `prepare-merge` covers merge prep), separate SECURITY/HUMAN states (flags on
  AWAIT_HUMAN), Spec Agent.
- Human-only transitions: AWAIT_GATE4 → LOCKED, every exit from AWAIT_HUMAN / ESCALATED,
  DONE → commit/merge.
- State: `$(git rev-parse --git-path claude-tdd)/state.json` — inside `.git/`, per
  worktree, never committed; written only by hook scripts; each transition also appended to
  `logs/audit.jsonl`. Locked set (Stage 1): `tests/` + `docs/product/`, for `tdd-implementer`
  only; Stage 3+ candidates: `phpunit.xml*`, `.env.testing`, `.claude/**`, the gate script.
  The approved state is the Stage 1 snapshot copy in `$(git rev-parse --git-path
  claude-tdd)/approved/` (ADR-0016 item 5); `state.json` records only the approval time.
- Approval is provably human if `/tdd` has `disable-model-invocation: true` and the
  approval is recorded by a `UserPromptExpansion` hook [U2]; without an approval record a
  PreToolUse(Agent) hook refuses to start `tdd-implementer` [U4].

## Loop mechanism

| Option | Deterministic | Context | Verdict |
|---|---|---|---|
| **SubagentStop on `tdd-implementer` runs the gate, blocks with a failure summary** | yes | one subagent context | **chosen** |
| `/tdd` prompt re-invokes the subagent | no (model counts) | parent grows | rejected |
| Stop hook in the main session | yes | main grows; fires at the Gate 4 pause too | rejected |
| `claude -p` per attempt | yes, budgeted | fresh each time | Stage 5 |

```
SubagentStop(tdd-implementer):
  s = load_state() or ESCALATE("state_missing")          # fail closed
  if s.state != GREEN: allow
  if spec_conflict_valid(msg): ESCALATE("spec_conflict")
  rc = gate.sh --scope cycle      # auto-fixers on non-locked paths, snapshot diff -r, checks
  if rc == 2: ESCALATE("lock_violation")                  # never retried
  if rc == 3: ESCALATE("tool_error")                      # environment; not counted as an attempt
  if rc == 0: s.state = REVIEW; allow
  fp = sha1(sorted(failing_ids) + normalize(first_error_line))
  s.attempt += 1
  if s.attempt >= 3 or fp == s.last_fp: ESCALATE("max_attempts" | "same_failure")
  s.last_fp = fp; block(reason = summary ≤ 40 lines + evidence path)
```

Verified facts behind it:
- [V] SubagentStop fires for `tdd-implementer` with `agent_type`, `agent_id`,
  `stop_hook_active`, `agent_transcript_path`, `last_assistant_message`; `matcher` filters
  on `agent_type` (docs).
- [V] `decision:"block"` makes the subagent continue; the second call has
  `stop_hook_active: true`.
- [V] Main-session Stop block works the same way.
- Docs: `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` (default 8, `0` disables) caps consecutive
  continuations for Stop and SubagentStop — not exercised hands-on.

### Problem 1 — the subagent may ignore the hook's message → resolved [V]

The subagent can treat a block `reason` as "an instruction injected by a hook" and refuse it.
Compliance measured on 2026-10-03 (2.1.278, 28 runs, model `claude-sonnet-5`):

| Variant | Complied |
|---|---|
| Imperative reason, nothing in the agent definition | **0/3** (all refused as injected instructions) |
| Imperative reason + trust sentence in the definition | 2/2 |
| **Factual reason + trust sentence** | **3/3** |
| Factual reason, no trust sentence | 4/5 (3/3 foreground, 1/2 background) |
| `additionalContext` instead of block, factual | 3/3 (the subagent read the evidence file itself) |

**Decision for the design**: the gate's message is factual — failing test ids, expected vs.
got, evidence path — never imperative; `tdd-implementer.md` states that feedback from the
gate hook is part of its task. Keep `decision: "block"` (documented continuation semantics);
`additionalContext` is a working alternative without the "hook error" label. A block reaches
the subagent as a user turn "Stop hook feedback: <reason>".

### Problem 2 — the parent only sees the final message → resolved [V]

A **PostToolUse hook on the `Agent` tool** (the tool is named `Agent`, not `Task`) adds
`additionalContext` that the parent session sees (12/12 foreground runs). The subagent's own
report reaches the parent marked as model output ("[Subagent hand-back] … NOT a message from
the user"), so the loop's outcome is reported from the state/evidence files through this hook,
never through the subagent's prose. The injected line must be truthful and self-explaining
("gate rejected attempt 1 (expected 5, got 4); corrected; evidence claude-gate/<ts1>.json, claude-gate/<ts2>.json"):
when a test injection claimed GREEN while the file disagreed, the parent flagged it as a
suspected injection; without the explanation it doubted the subagent. For **background**
subagents PostToolUse(Agent) fires at launch (`async_launched`), not at completion — use
foreground runs for the loop, or read the state files.

### Verified hook facts (2026-10-03, CLI 2.1.278)

| # | Fact | Result |
|---|---|---|
| U1 | SubagentStop fires and can block for a background subagent | Confirmed |
| U2 | `UserPromptExpansion` fires for a typed project command with arguments (`command_name`, `command_args`, `command_source`) and not when the model calls the Skill tool | Confirmed — it is the reliable "a human typed it" signal. Note: a typed command can *also* produce a Skill tool call, so PreToolUse(Skill) alone does not prove model invocation |
| — | `disable-model-invocation: true` on a `.claude/commands/*.md` file blocks model invocation; typing it still works | Confirmed (0/2 model invocations) |
| U3 | Subagent `maxTurns` counts across SubagentStop continuations | Confirmed. **A subagent that hits `maxTurns` returns without SubagentStop firing again** — the gate never sees the final state, so the main session treats that return as ESCALATED |
| U4 | PreToolUse on `Agent` exposes `tool_input.subagent_type` and can deny the start | Confirmed |
| U6 | Block cap is per subagent | Confirmed; inferred it counts only consecutive blocks *without tool calls* — not a total. Keep our own attempt counter + `maxTurns` |
| U7 | Hook-level `timeout` is honoured | Partial: on timeout the hook's decision is **discarded and the tool proceeds (fails open)**, and wall-clock is not bounded when a child process holds stdout. Keep gate hooks free of lingering child processes; re-check on 2.1.285+ (changelog mentions a related fix) |
| U5 | pint path scoping excludes untracked tests | Not tested |
| U8 | `SubagentHandback` routing | Not tested (auto mode only) |

Environment caveats of the test: the user's global CLAUDE.md and a user-level SessionStart
hook were active; the VS Code extension runs 2.1.283–284, so re-verify there (ADR-0016 item 10).

## Tamper resistance

- Stage 1 hook extended: deny `Write`/`Edit`/`Bash` touching `claude-tdd/`,
  `logs/audit.jsonl` or the locked set (Bash checked by command string — [V] a Bash write
  carries `agent_type`, and a path-only check let it through).
- On native Windows a subprocess can still bypass, so: missing/invalid state stops the loop;
  `maxTurns` bounds counter resets; a return "still GREEN" is treated as escalated and the
  main session re-runs the snapshot comparison. Rule: **tampering can only end the loop earlier.**
- A hook that times out fails open (ADR-0016 item 3, U7): the Stage 1 lock hook and the gate
  hook must stay fast and leave no child process holding stdout; a return without a gate
  verdict is treated as ESCALATED.
- Hooks are written with bash builtins only — [V] grep/sed-based hook ≈ 500 ms per call vs
  builtins-only ≈ 83 ms on Windows Git Bash.

## Gate 4 profiles (deferred until Stage 2 data)

Deferred until Stage 2 (Q2) data; likely low value, because the always-human categories below
cover most tests. Sketch kept for reference: one line in `.claude/rules/30-testing.md`, same
pattern as the Git profile line; `standard` default.

| | `standard` | `lite` |
|---|---|---|
| Human sees | All test code + failure logs | Test plan table for the UC + full code of HUMAN categories |
| Always human | All tests | authz, validation, regression, user_visible |
| Machine-checked | also run | each test fails for an assertion/missing-symbol reason; strict modes; no `todo()` / `assertTrue(true)`; UC id in name/group |

Changing Gate 4 touches the Gate definitions (`00-global.md`, `SETUP.md`, `AGENTS.md`
together) and ~20 files that mention Gate 4.

## Reviewer output

The single schema is **ReviewResult v2** in `loop-reviewer-design.md` (minimal config R0); no
`decision`, no approval power; `route` is computed by a script. Every HUMAN_BLOCKING finding
needs a person's acknowledgement before DONE; the rest is shown as information. The reviewer is a `Read, Grep, Glob`-only
subagent reading the diff and the evidence; it never runs code. `/review` (ADR-0009, human,
once per branch) is unchanged and never replaced. Needed amendments: ADR-0009 note;
ADR-0015 #7 and git-workflow §7/§8 ("no automatic review→fix loop; at most one findings-only
pass per human-started `/tdd` cycle").

## User-facing change rule

Diff paths in `resources/js/Pages|Components`, `resources/views`, `lang/`,
`app/Http/Requests`, `app/Policies`, `app/Http/Middleware`, `routes/`, notifications/mail,
with a change not covered by a human-approved test → `USER_FACING_CHANGE`, HUMAN. Deterministic findings cannot be dropped by the LLM reviewer.

## Failure modes

| Mode | Mitigation |
|---|---|
| Infinite loop | 3 attempts + `maxTurns`; same failure twice stops (ADR-0016 item 2); implementer not restarted after ESCALATED |
| Context growth | ≤ 3 continuations; reason ≤ 40 lines; logs as evidence paths |
| Cost | `maxTurns` on the implementer [U3]; cost per cycle logged (no `--max-budget-usd` interactively) |
| False SPEC_CONFLICT spam | must cite a test id, a UC id and a verbatim quote from use-cases.md (checked with `grep -F`); track confirmed rate |
| Flaky tests | re-run failures once before fingerprinting |
| Prompt injection via diff/tests | reviewer has no write/exec tools; schema-checked; findings never auto-acted on |

## Codex

Codex PreToolUse input has no agent identity (only SubagentStart/SubagentStop do; docs), so
role-based locking cannot be done with Codex hooks; `apply_patch` edits are interceptable
session-wide. For Codex the approved-snapshot comparison (`diff -r`, tool-agnostic) is the primary
protection. Local codex-cli 0.116.0 has hooks disabled (in development) — not tested.

## Unverified before an ADR

Updated 2026-10-03: U1–U4, U6 confirmed and U7 partially (see "Verified hook facts"); U5 and
U8 remain. Original list, kept for reference:

[U1] SubagentStop for a background-run subagent · [U2] `UserPromptExpansion` fires for
commands with arguments and not for model Skill calls · [U3] `maxTurns` across hook
continuations · [U4] PreToolUse on `Agent` exposes `subagent_type` · [U5] pint path scoping
excludes untracked tests · [U6] block cap per subagent vs per session · [U7] gate runtime vs
hook timeout (default 600 s) on Windows · [U8] `SubagentHandback` routing (v2.1.271+).
