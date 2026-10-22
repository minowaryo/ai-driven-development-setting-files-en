# Codex Parity — Handoff for a New Session

> Template-internal handoff note (class X), written 2026-10-22 at the maintainer's request:
> "Codex support is done in the EN repo; prepare a note so another session can do it."
> Start by reading this file, then `meta/design/loop-stage4-design.md`.

## Goal

A Codex session (`AGENTS.md`) follows the same division of roles and stops as a Claude Code
session. The division is fixed (`docs/development/ai-authority.md`, "Principles"): a person
decides what to build and the **test content** (Gate 4); the AI writes and runs the test code and
the implementation. Codex work may make the AI's own work better or stricter; anything that lets
the AI decide something in the person's column needs the maintainer's explicit approval.

Scope: EN repo only. JP and company follow later, by separate decision.

## Where things stand (2026-10-22)

- Codex reads `AGENTS.md`: task table, Gates, rules, prohibitions. It does not read
  `.claude/commands/`, `.claude/agents/` or `.claude/settings.json`.
- Machine stops that **do** apply to Codex: the snapshot checks that `/tdd` runs
  (`tdd-snapshot.sh verify`, `fixture-literal-check.sh`) — but only if the Codex session runs
  those steps; nothing makes it.
- Machine stops that **do not** apply: `agent-guard.sh` (tests / spec lock, git lock, S5 / S9
  limits) — Codex hooks cannot tell which agent is writing (ADR-0016, Stage 4; `tdd-guard.md`
  "Limits"). Recorded as a Known Gap in `docs/development/ai-authority.md`.
- Design draft: `meta/design/loop-stage4-design.md` (2026-10-03, verified on codex-cli 0.116.0,
  native Windows). Its recommended pattern: run the Codex implementer only through a wrapper
  (`scripts/codex-green.sh`) that refuses without a Gate 4 snapshot, exports `TDD_ROLE`, runs
  `codex exec` with a read-only profile for `tests/` and `docs/product/`, and loops at most 3 times.
- Installed CLI on this machine on 2026-10-22: `codex-cli 0.116.0` (same as the draft).

## What changed since the draft (not yet in it or in `AGENTS.md`)

| Change | Claude side | Codex side (after 2026-10-22) |
|---|---|---|
| Non-stop `/tdd` to one Step 8 completion report (ADR-0019) | `.claude/commands/tdd.md` | `AGENTS.md` "TDD cycle" follows `tdd.md` Steps 0-8 |
| S7 — stop on risky changes after Green (`mark-green` / `verify-green`) | `tdd.md` Steps 4 and 7 | Runs (the session runs the script) |
| Cycle review (`cycle-reviewer` sub-agent, findings-only) | `.claude/agents/cycle-reviewer.md` | None; the report asks for `/review` before merging |
| S5 / S9 run and call limits | `agent-guard.sh` | Prompt-level: 3 attempts / same failure twice |
| Test-run budget and phase reports (ADR-0020) | `30-testing.md` | Applies as written |
| Changed screens in the merge plan | `prepare-merge` skill | Read and followed from `tdd.md` Step 8 |
| AI authority register | `docs/development/ai-authority.md` | `AGENTS.md` task table points to it (2026-10-22) |

## Outcome (2026-10-22)

- Codex docs re-read for codex-cli 0.163.0: PreToolUse still has no agent identity; see the
  note at the top of `loop-stage4-design.md`. The local CLI (0.116.0) was not upgraded and no
  fixture was re-run — the text-only step needs neither.
- Maintainer chose option (a): `AGENTS.md` "TDD cycle". Updated: `tdd-guard.md` "Limits",
  `ai-authority.md` Known Gaps + change log, ADR-0016 Stage 4 note.
- Not done: the wrapper (option (b)), JP and company ports.

## Suggested first steps

1. Check the current Codex CLI release and its hooks / permission-profile docs (the draft notes
   hooks were behind a dev flag in 0.116.0). Re-run the draft's fixture on the version chosen;
   set a minimum version.
2. Decide with the maintainer how far to go: (a) `AGENTS.md` text only — describe the `/tdd`
   flow, S7 and the reports, with prompt-level protection; or (b) the wrapper pattern from the
   draft, which makes the lock and limits mechanical for Codex.
3. Whatever is built, keep the Known Gaps row in `ai-authority.md` true, and update
   `tdd-guard.md` "Limits" and ADR-0016 Stage 4.

## Working constraints (maintainer)

- Main users are on Standard seats: count tokens and keep the AI's work simple to use.
- Ask for `/usage` before running model batches; stop at about 50 % of the weekly limit.
- No new `meta/tests/` files without saying why and asking; one test per hook script.
- Commit only after the maintainer approves the proposed commits; never on `main`.
- Replies to the maintainer in Japanese; files and commits in English.
