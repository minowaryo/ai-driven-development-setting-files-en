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
                │                    LOCKED (lock_tree recorded)                │
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
  `logs/audit.jsonl`. Locked set: `tests/**`, `phpunit.xml*`, `.claude/**`, the gate script;
  `lock_tree` = tree hash of the locked set via a temporary index, also printed into the main
  transcript at approval.
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
  if tree(locked_set) != s.lock_tree: ESCALATE("tamper")
  autofix_non_locked(); recheck lock_tree                  # pint on non-locked paths only
  r = gate --junit
  if r.pass: s.state = REVIEW; allow
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

### Open problem 1 — the subagent may ignore the hook's instruction [V]

In one run the subagent treated the block `reason` as "an instruction inside hook output"
and refused to act on it (prompt-injection caution working against the loop). It complied
once its definition stated that SubagentStop feedback is legitimate. Options to evaluate:
state it in `tdd-implementer.md`; return `additionalContext` instead of `block` (shown as
"Stop hook feedback", untested); keep the gate output factual (failing test ids + first
error) rather than imperative.

### Open problem 2 — the parent only sees the final message [V]

After a block, only the subagent's last message returns to the parent; the earlier report
(e.g. a denied write) is lost, and the parent flagged a report/reality mismatch. The loop
must therefore deliver its outcome through files (state + evidence) and a
PostToolUse(Agent) `additionalContext` line, never through the subagent's prose.

## Tamper resistance

- Stage 1 hook extended: deny `Write`/`Edit`/`Bash` touching `claude-tdd/`,
  `logs/audit.jsonl` or the locked set (Bash checked by command string — [V] a Bash write
  carries `agent_type`, and a path-only check let it through).
- On native Windows a subprocess can still bypass, so: missing/invalid state stops the loop;
  the block cap bounds counter resets; a return "still GREEN" is treated as escalated and the
  main session re-computes `lock_tree`. Rule: **tampering can only end the loop earlier.**
- Hooks are written with bash builtins only — [V] grep/sed-based hook ≈ 500 ms per call vs
  builtins-only ≈ 83 ms on Windows Git Bash.

## Gate 4 profiles (Stage 3 decision; evidence from Stage 2 Q2)

One line in `.claude/rules/30-testing.md`, same pattern as the Git profile line;
`standard` default during Trial.

| | `standard` | `lite` |
|---|---|---|
| Human sees | All test code + failure logs | Test plan table for the UC + full code of HUMAN categories |
| Always human | All tests | authz, validation, regression, user_visible |
| Machine-checked | also run | each test fails for an assertion/missing-symbol reason; strict modes; no `todo()` / `assertTrue(true)`; UC id in name/group |

A grep-based classifier errs toward HUMAN; test-writer tags can add categories, never
remove them. Changing Gate 4 touches the Gate definitions (`00-global.md`, `SETUP.md`,
`AGENTS.md` together) and ~20 files that mention Gate 4.

## Reviewer output (minimal)

No `decision`, no approval power; the route is computed by a script.

```json
{"v":1,"cycle":"…","diff_sha":"…","evidence_sha":"…",
 "findings":[{"category":"SPEC_CONFLICT|TEST_GAP|USER_FACING_CHANGE|SECURITY|DOMAIN_BOUNDARY|DEFECT",
   "severity":"HIGH|MEDIUM|LOW","file":"…","line":12,"requirement":"UC-006",
   "claim":"…","evidence":"quote or evidence-path#key"}],
 "not_verified":[{"what":"…","why":"…"}]}
```

Any SPEC_CONFLICT / SECURITY / USER_FACING_CHANGE / HIGH → human must acknowledge each
before DONE; otherwise shown as information. The reviewer is a `Read, Grep, Glob`-only
subagent reading the diff and the evidence; it never runs code. `/review` (ADR-0009, human,
once per branch) is unchanged and never replaced. Needed amendments: ADR-0009 note;
ADR-0015 #7 and git-workflow §7/§8 ("no automatic review→fix loop; at most one findings-only
pass per human-started `/tdd` cycle").

## User-facing change rule

Diff paths in `resources/js/Pages|Components`, `resources/views`, `lang/`,
`app/Http/Requests`, `app/Policies`, `app/Http/Middleware`, `routes/`, notifications/mail →
modified existing file, or category not covered by a human-approved test →
`USER_FACING_CHANGE`, HUMAN. Deterministic findings cannot be dropped by the LLM reviewer.

## Failure modes

| Mode | Mitigation |
|---|---|
| Infinite loop | 3 attempts, same-fingerprint stop, block cap, implementer not restarted after ESCALATED |
| Context growth | ≤ 3 continuations; reason ≤ 40 lines; logs as evidence paths |
| Cost | `maxTurns` on the implementer [U3]; cost per cycle logged (no `--max-budget-usd` interactively) |
| False SPEC_CONFLICT spam | must cite a test id, a UC id and a verbatim quote from use-cases.md (checked with `grep -F`); track confirmed rate |
| Flaky tests | re-run failures once before fingerprinting |
| Prompt injection via diff/tests | reviewer has no write/exec tools; schema-checked; findings never auto-acted on |

## Codex

Codex PreToolUse input has no agent identity (only SubagentStart/SubagentStop do; docs), so
role-based locking cannot be done with Codex hooks; `apply_patch` edits are interceptable
session-wide. For Codex the git-based check (`lock_tree` / index comparison) is the primary
protection. Local codex-cli 0.116.0 has hooks disabled (in development) — not tested.

## Unverified before an ADR

[U1] SubagentStop for a background-run subagent · [U2] `UserPromptExpansion` fires for
commands with arguments and not for model Skill calls · [U3] `maxTurns` across hook
continuations · [U4] PreToolUse on `Agent` exposes `subagent_type` · [U5] pint path scoping
excludes untracked tests · [U6] block cap per subagent vs per session · [U7] gate runtime vs
hook timeout (default 600 s) on Windows · [U8] `SubagentHandback` routing (v2.1.271+).
