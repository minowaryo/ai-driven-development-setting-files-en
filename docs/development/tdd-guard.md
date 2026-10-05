# tdd-guard.md — What is locked during `/tdd`, and how to change it

> Read when a write was blocked, when `/tdd` reports a snapshot difference, or when you want
> to know what the guard does. Decision record: `meta/adr/ADR-0016-loop-engineering-stage1.md`.

## The one rule

**The implementer cannot move the goal it is asked to reach.** In a `/tdd` cycle, the goal is
the tests and the spec a person approved at Gate 4. The `tdd-implementer` sub-agent (Green)
may change application code to meet that goal, but not the goal itself.

## Who may change what

| Who | `tests/` | Spec (`docs/product/`) | Application code |
|---|---|---|---|
| You | Any time | Any time (change requests as usual) | Any time |
| The main session (the AI you talk to) | On your instruction | Drafts / fixes with your approval | Yes |
| `test-writer` (Red) | Writes them | Reads only | No |
| **`tdd-implementer` (Green)** | **Blocked** | **Blocked** | Writes it |

Nothing is locked for you or for the main session. There is no lock to switch on or off.

## What runs, and what you see

| When | What happens | What you see |
|---|---|---|
| Every tool call | `.claude/hooks/agent-guard.sh` checks calls made by `tdd-implementer` and blocks writes to `tests/` or `docs/product/` and git commands that stage, commit, switch or configure | Usually nothing. A blocked attempt appears in the implementer's report and in `logs/audit.jsonl` |
| Right after you approve at Gate 4 | `/tdd` copies `tests/` and `docs/product/` into `.git/claude-tdd/approved/` | One line: "Saved the approved snapshot …" |
| Right after Green | `/tdd` compares the files with that copy | Usually "unchanged". If something changed, the diff is shown and `/tdd` stops for your decision |
| The tests and the spec contradict each other | The implementer stops and reports `SPEC_CONFLICT` (test name + a quote from the use case) | A report instead of a forced green; you decide which side is wrong |
| The implementer is stuck | It stops after 3 attempts, or when the same failure appears twice | A report of what it tried |

## How to change a test or the spec legitimately

1. Decide what is wrong (the test, the spec, or both). Edit it yourself or ask the main session.
2. Restart the cycle from Red (`/tdd` again for the same use case).
3. Approve at Gate 4 — this saves a fresh snapshot, so the new version is the goal from now on.

That is all; there is no separate unlock or relock step.

## When `/tdd` shows a snapshot difference

The diff shows exactly what changed in `tests/` or `docs/product/` after your approval.

- **You did not intend it** → discard it (e.g. restore the file from the diff) and continue.
- **It is a change you want** → restart from Red and approve again (above).

You can run the checks yourself at any time:

```bash
bash .claude/hooks/tdd-snapshot.sh verify   # compare with the approved snapshot
bash .claude/hooks/tdd-snapshot.sh record   # save a new snapshot (what Gate 4 approval does)
```

## The log

`logs/audit.jsonl` (git-ignored) records AI agent activity, one JSON line per event — for
this guard, `"event":"agent_guard_denial"` with the session, the tool and the blocked path or
command, never file contents. It is **not** the application's audit log (`storage/logs/audit.log`,
`.claude/rules/40-security.md`), which records what users of the application do.

## Limits

- The hook is a guardrail, not a wall: on native Windows there is no OS sandbox, so a
  subprocess can still write. The snapshot check after Green catches such writes.
- A hook that crashes or times out lets the call through. The hook is kept fast (bash
  builtins only) for this reason, and the snapshot check is the backstop.
- Codex users get the snapshot check (run by `/tdd`'s steps in AGENTS.md workflows) but not
  the hook yet — Codex hooks cannot tell which agent is writing (ADR-0016, Stage 4).
