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
| `cycle-reviewer` (after Green) | Reads only | Reads only | Reads only — it reports findings, `/tdd` decides |

The record of the cycle — `logs/audit.jsonl` and the approved snapshot in `.git/claude-tdd/` —
is also blocked for `tdd-implementer`: the party being checked must not be able to edit the
evidence about itself.

Nothing is locked for you or for the main session. There is no lock to switch on or off.

## What runs, and what you see

| When | What happens | What you see |
|---|---|---|
| Every tool call | `.claude/hooks/agent-guard.sh` checks calls made by `tdd-implementer` and blocks writes to `tests/`, `docs/product/`, `logs/audit.jsonl` or the snapshot, and git commands that stage, commit, switch or configure | Nothing at the time. Each blocked attempt is written to `logs/audit.jsonl` |
| Right after you approve at Gate 4 | `/tdd` copies `tests/` and `docs/product/` into `.git/claude-tdd/approved/` and notes the size of `logs/audit.jsonl` | One line: "Saved the approved snapshot …" |
| Right after Green | `/tdd` compares the files with that copy, and reads the log lines written since approval | Usually "unchanged" and "no blocked attempts". If something changed, the diff is shown and `/tdd` stops for your decision. Blocked attempts are shown as the raw log lines — from the log, not from the implementer's report, which may leave them out |
| Right after Green, after that comparison | `/tdd` runs `.claude/hooks/fixture-literal-check.sh`: does application code compare against a value that only the approved tests contain (for example `if ($product->sku === 'SKU-A')`)? | Nothing when clean. If found, the lines are shown as `FIXTURE_LITERAL file:line 'value'` and `/tdd` stops for your decision |
| When both checks pass | `/tdd` copies the application files into `.git/claude-tdd/green/` (`tdd-snapshot.sh mark-green`) | One line: "Saved the application files after Green …" |
| After the Green confirmation | `/tdd` asks the `cycle-reviewer` sub-agent to review the change (skipped for small changes; ADR-0019) | Findings that need a judgment (spec conflict, security, user-facing change, suspect instruction, any HIGH) stop `/tdd` for your decision; small DEFECT / Domain Boundary findings are fixed once and reported; test gaps are reported |
| After Refactor, or after any fix made after Green (e.g. a review finding) | `/tdd` compares with that copy (`verify-green`). Changes that touch permissions (Policies, routes, middleware, `authorize`, `Gate::`, role checks), destructive operations (migrations, `delete(`, `truncate(`), security (`v-html`, raw SQL, mass assignment, hidden attributes, auth/session config), secrets (`.env`, key assignments), outside effects (mail, HTTP, notifications, schedules, jobs), dependencies (`composer` / `npm` files) or integrity (a removed transaction or lock) | `STOP …` lines and `/tdd` stops for your decision. Other changed screens, wording, validation and controllers are `LISTED` in the final summary for you to look at; nothing else is asked |
| The tests and the spec contradict each other | The implementer stops and reports `SPEC_CONFLICT` (test name + a quote from the use case) | A report instead of a forced green; you decide which side is wrong |
| The implementer is stuck | It stops after 3 attempts, or when the same failure appears twice | A report of what it tried |
| The implementer keeps going | `agent-guard.sh` counts, per Gate 4 approval: implementer runs (a third start is refused) and the implementer's file writes and commands (refused after 60). A new approval starts both counts again; outside a `/tdd` cycle nothing is counted (ADR-0019) | `/tdd` stops with a report of what is done and what is left; the refusal is in the blocked-attempt lines |

## How to change a test or the spec legitimately

1. Decide what is wrong (the test, the spec, or both). Edit it yourself or ask the main session.
2. Restart the cycle from Red (`/tdd` again for the same use case).
3. Approve at Gate 4 — this saves a fresh snapshot, so the new version is the goal from now on.

That is all; there is no separate unlock or relock step.

## When `/tdd` shows a snapshot difference

The diff shows exactly what changed in `tests/` or `docs/product/` after your approval. If
`verify` says the log is shorter than at approval, someone rewrote `logs/audit.jsonl` during
the cycle; treat the cycle's record as unreliable and look at the diff of `app/` yourself.

- **You did not intend it** → discard it (e.g. restore the file from the diff) and continue.
- **It is a change you want** → restart from Red and approve again (above).

You can run the checks yourself at any time:

```bash
bash .claude/hooks/tdd-snapshot.sh verify   # compare with the approved snapshot
bash .claude/hooks/tdd-snapshot.sh record   # save a new snapshot (what Gate 4 approval does)
bash .claude/hooks/tdd-snapshot.sh mark-green    # record the application files after Green
bash .claude/hooks/tdd-snapshot.sh verify-green  # what changed after Green, and what needs a stop
```

## The log

`logs/audit.jsonl` (git-ignored) records AI agent activity, one JSON line per event — for
this guard, `"event":"agent_guard_denial"` with the session, the tool and the blocked path or
command, never file contents. Blocked attempts are a signal in their own right: an
implementer that tried to edit a test was trying to move the goal, even though it could not.
It is **not** the application's audit log (`storage/logs/audit.log`,
`.claude/rules/40-security.md`), which records what users of the application do.

## Limits

- The hook is a guardrail, not a wall: on native Windows there is no OS sandbox, so a
  subprocess can still write. The snapshot check after Green catches such writes to
  `tests/` and `docs/product/`, and a log that got shorter; a subprocess that rewrites both
  a test and its snapshot copy, or deletes only the newest log lines, is not caught. Only
  running the agent outside its own workspace's reach closes that (ADR-0016, Stage 5).
- A command that mentions a locked path and also looks like a write is denied by reading the
  command text, so a command can be denied by mistake — for example a script that rewrites an
  app file and, in the same command, runs a test file. The PHP forms `$obj->prop` and `=>` are
  not counted as redirects; if a command is still denied wrongly, split it into two (write,
  then run the tests). The reverse gap — a write written to look like `$v->tests/x` — is left
  to the snapshot check.
- The fixture-literal check reads quoted strings only, in added application lines that compare (`===`, `==`, `!=`, `case`, `match`, `in_array(`, `where(`). It does not see numbers, a value split across a concatenation, or one hidden behind a constant — the reviewer or a person reading the diff covers those (`meta/design/fixture-literal-check.md`).
- The check after Green reads paths and added / removed lines, so a permission or destructive change written without those words (a hand-rolled role comparison under another name, a mass update) is only `LISTED` or not seen; the reviewer and your final look cover it (`meta/design/s7-user-facing-stop.md`). Role checks are recognised by their common names (`isAdmin`, `hasRole`, …) and by the project's own `is…()` / `has…()` methods whose body mentions a role — found automatically, nothing to configure. Files git ignores are skipped.
- The run and call limits (2 and 60, about twice what real cycles used) stand in for time and
  tokens, which a hook cannot see; the cycle reviewer has no counter
  (`meta/design/stretch-chaining-limits.md`).
- The hook depends on what Claude Code tells it about each call. If an update changes that, the
  hook lets everything through without a sign. `verify` therefore warns when it counted no
  implementer call since approval ("WARNING: agent-guard.sh counted no …"): either the
  implementer did not run, or the hook no longer sees it — tell the template maintainer, who can
  re-check the hook on that version (`meta/design/guardrail-regression-suite.md`).
- A hook that crashes or times out lets the call through. The hook is kept fast (bash
  builtins only) for this reason, and the snapshot check is the backstop.
- Under Codex, `AGENTS.md` ("TDD cycle") has the session follow `/tdd`'s steps, so the
  snapshot, fixture-literal and `verify-green` checks run — but only because the prompt says so.
  The hook does not run: Codex hooks cannot tell which agent is writing (re-checked on the
  codex-cli 0.163 docs, 2026-10-22). The lock, the git limits and the run and call limits are
  prompt-level there, and there is no cycle reviewer (ADR-0016, Stage 4).
