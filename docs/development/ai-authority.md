# ai-authority.md — What the AI May Do, and Who Decides

> The single register of the AI's authority in this harness: what it does on its own, what
> it proposes for a person to approve, what only a person does, and where a machine stops it.
> The procedures stay in the files linked from each row; this file says **who decides**.
> Read it before changing any of those rules. Related ADR: `meta/adr/ADR-0004-ai-development-policy.md`.

## Principles — the Division of Roles

This division is the standing definition for this harness and for its future changes.

| A person decides and is responsible for | The AI does, inside those decisions | A machine enforces |
|---|---|---|
| **What to build** — requirements, use cases, data model (Gates 1-3) and any change users would notice | Drafts the documents; implements to the approved tests; refactors | — |
| **What to test** — the test content (cases, expected results): Gate 4 for Feature / Unit tests, the draft review for E2E tests, UAT results | Writes the test code and runs the tests; reports the results | Approved tests and spec cannot be changed by the implementer; a change after approval stops the cycle |
| **Structure and policy** — ADRs, libraries, do-not-touch areas, loosening authorization | Proposes; drafts an ADR when asked | — |
| **What leaves this machine** — commits, merges, pushes, shared environments, production | Proposes the commits and the merge plan; works freely on the local machine | Force push is denied; push asks |
| **The AI's authority itself** — this register | Follows it; proposes changes | — |

A change to the harness is in scope when it keeps these lines: it may make the AI's own work
(generating, running, checking) better or stricter. A change that lets the AI decide something in
the first column widens its authority — see "Changing This Register".

## Levels

| Level | Meaning |
|---|---|
| **Act, then report** | The AI does it without asking and reports the result |
| **Propose → approve** | The AI prepares it and acts only after a person approves what it showed |
| **Person only** | Only a person does or decides it; the AI may suggest or draft when asked |
| **Machine stop** | A hook or script stops the AI; a person decides how to go on |

## Register

Git rows assume the `lite` profile (`.claude/rules/70-git.md`); `standard` differences are noted.

| Area | Action | Level | Source |
|---|---|---|---|
| Specs | Draft requirements, use cases, data model, mockups | Propose → approve (Gates 1-3) | `.claude/rules/00-global.md` |
| Specs | Approve a Gate (0-4) | Person only | `.claude/rules/00-global.md` |
| Specs | Edit `docs/original-docs/` (except its `README.md`) | Never | `.claude/rules/00-global.md` |
| Specs | Interview a person about ambiguous requirement points (`grill-me`, Trial) | Act, then report — the person answers and decides | `.claude/skills/grill-me/SKILL.md` |
| Specs | Create an ADR | Person only (the AI drafts with `/adr` when asked) | `docs/development/ai-workflow.md` |
| TDD | Write the Red tests (`test-writer`) | Propose → approve: **a person approves the test content at Gate 4 and owns it** | `.claude/rules/30-testing.md` |
| TDD | Implement to Green (`tdd-implementer`) | Act, then report — after Gate 4 only | `.claude/commands/tdd.md` |
| TDD | Edit `tests/`, `docs/product/` or git during Green | Machine stop (`agent-guard.sh`) | `docs/development/tdd-guard.md` |
| TDD | A third implementer run, or past 60 writes / commands per approval | Machine stop (`agent-guard.sh`) | `docs/development/tdd-guard.md` |
| TDD | Tests or spec changed after approval; code matching a test-only value | Machine stop (`tdd-snapshot.sh verify`, `fixture-literal-check.sh`) | `docs/development/tdd-guard.md` |
| TDD | After Green, a change touching permissions, destructive operations, security, secrets, outside effects, dependencies or integrity | Machine stop (`tdd-snapshot.sh verify-green`) | `docs/development/tdd-guard.md` |
| TDD | Tests and spec contradict; attempt limit reached | The AI stops and reports (`SPEC_CONFLICT`); a person decides | `.claude/agents/tdd-implementer.md` |
| TDD | Branch, `HEAD` or files other than the new tests changed between Step 0 and Gate 4 approval (e.g. another session in the same folder) | The AI stops before saving the snapshot; a person decides | `.claude/commands/tdd.md` |
| TDD | Start, stop or restart a system service (database, queue worker, web server) from `test-writer` / `tdd-implementer` | Never — the agent stops and reports the down service; a person fixes the environment | `.claude/agents/test-writer.md`, `.claude/agents/tdd-implementer.md` |
| TDD | Go from Gate 4 approval to the Step 8 completion report without waiting between steps | Act, then report — stops wherever a row here says stop | `.claude/commands/tdd.md`, ADR-0019 |
| TDD | Review the cycle after Green (`cycle-reviewer`, read-only) | Act, then report (skipped for small changes) | `.claude/agents/cycle-reviewer.md` |
| TDD | Fix the cycle review's DEFECT / Domain Boundary findings in application code, once | Act, then report ("Fixed without asking"); never `tests/` or `docs/product/`; test gaps are only reported | `.claude/commands/tdd.md` |
| TDD | Cycle-review finding on security, a suspect instruction, a spec conflict or user-facing change (MEDIUM+), or any HIGH | The AI stops; a person decides | `.claude/commands/tdd.md` |
| TDD | Refactor | Act, then report | `.claude/commands/tdd.md` |
| E2E | Write an E2E test | Act, then report — `/tdd` Step 6 follows `/generate-e2e-test` for a UC critical flow with UI changes; a person may also start the command (see Known Gaps) | `.claude/commands/tdd.md`, `.claude/commands/generate-e2e-test.md` |
| E2E | Capture screenshots of new screens for the merge plan (capture only, no assertions) | Act, then report | `.claude/skills/prepare-merge/SKILL.md` |
| Behavior | Any change users would notice (fields, screens, validation, permissions, wording, defaults) — even a bug fix or one the spec asks for | Propose → approve | `.claude/rules/00-global.md` |
| Authorization | Add a Policy or method for a new feature | Act, then report (through Policy / Gate only) | `docs/ai-context/do-not-touch.md` |
| Authorization | Loosen, remove or change existing Policy rules; other do-not-touch areas | Person only (ADR + review) | `docs/ai-context/do-not-touch.md` |
| Dependencies | Adopt or retire a library | Person only (ADR) | `.claude/rules/60-docs.md` |
| Local work | Read, search, build, test, lint, check against mocks or a local app, update the task's docs | Act, then report (see Known Gaps) | `.claude/rules/00-global.md` |
| Shared environments | Anything on a test or production server, a shared DB or an external service | Propose → approve | `.claude/rules/00-global.md` |
| Secrets | Real values in prompts, chat, commits | Never | `.claude/rules/40-security.md` |
| Review | Start `/review`, `/code-review`, the `run` skill, or any `.claude/commands/` command | Person only (the AI suggests) | `meta/adr/ADR-0009-review-escalation-mechanism.md`, ADR-0016 |
| Review | Decide whether a merge needs `/review` | The pre-merge check decides; on a sensitive path the AI asks once (`standard`: mandatory on the `required` tier) | `docs/development/git-workflow.md` §6 |
| Review | Author self-check and Domain Boundary check before a merge | Act, then report | `docs/development/git-workflow.md` §6 |
| Git | Create a branch | Act, then report (`standard`: Propose → approve) | `docs/development/git-workflow.md` §0 |
| Git | Commit; merge into `main` | Propose → approve | `docs/development/git-workflow.md` §4 |
| Git | Push | Propose → approve (explicit instruction; `ask` in `.claude/settings.json`) | `docs/development/git-workflow.md` §4 |
| Git | Commit → merge → push on one approval | Propose → approve, once (`standard`: each step separately) | `docs/development/git-workflow.md` §4 |
| Git | Force push; rewrite pushed history | Never (`deny` in `.claude/settings.json`) | `.claude/rules/70-git.md` |
| Git | Switch the Git profile | Person only (the AI edits the line when asked) | `docs/development/git-workflow.md` §0 |
| Adoption | Copy the harness into an existing repo (`APPLY_TEMPLATE.md` Phases 0-3) | Act, then report — stops on a failed pre-check, a collision or a failed verification; never commits | `APPLY_TEMPLATE.md` |
| Adoption | Document an existing codebase (`/onboard-existing-codebase`) | Propose → approve: the AI drafts and triages; a person resolves "Needs confirmation" and signs off Gates 0-3 once | `meta/adr/ADR-0011-existing-codebase-adoption.md` |

## Changing This Register

- **Widening** the AI's authority — a row moving toward "Act, then report", a removed stop, or
  a relaxed check — needs the maintainer's explicit approval, a row in the change log below and a
  dated note in ADR-0004, before the rule files change.
- **Narrowing** it — a new stop or approval — needs a row in the change log.
- Change the rule file in the same commit as this register; when they disagree, fix the
  disagreement before anything else.

## Known Gaps Against the Principles

Recorded 2026-10-22 when this register was created; each needs a decision before it is closed.

| Gap | Where | Note |
|---|---|---|
| E2E test content is decided and written by the AI, with no person approving it (`/tdd` Step 6, `/generate-e2e-test`) | `.claude/commands/tdd.md`, `.claude/commands/generate-e2e-test.md` | Kept for now by maintainer decision (2026-10-22). The company repo already changed this: `/tdd` only suggests the command and the person reviews the draft |
| "Work That Needs No Approval" does not exclude specs under `docs/product/` and ADRs, which a person decides | `.claude/rules/00-global.md` | The company repo excludes them |
| In Codex sessions (`AGENTS.md`) the "Machine stop" rows are only partly enforced: the `agent-guard.sh` hook does not run (lock, git limits, run and call limits are prompt-level), and there is no cycle review; the snapshot, fixture-literal and `verify-green` checks run because `AGENTS.md` "TDD cycle" tells the session to run them | `AGENTS.md`, `docs/development/tdd-guard.md`, ADR-0016 Stage 4 | 2026-10-22: maintainer chose the `AGENTS.md`-only step; the wrapper that would make the lock mechanical (`meta/design/loop-stage4-design.md`) is not built |

## Change Log

The register starts on 2026-10-22 with the state above; earlier decisions are in the ADRs named in
the Source column and their dated notes.

| Date | Change | Direction | Decided in |
|---|---|---|---|
| 2026-10-22 | Register created (ported from the company repo) | — | ADR-0004 note |
| 2026-10-22 | Codex sessions follow `/tdd`'s steps via `AGENTS.md` "TDD cycle" (stop at Gate 4, run the snapshot checks); no rows change | Narrowing (Codex only) | ADR-0016 Stage 4 note |
| 2026-10-24 | `/tdd` stops before saving the snapshot when the working tree changed since Step 0; the TDD sub-agents never start or stop system services (both from `ihs-tech-uplift` Batch U) | Narrowing | Working-tree stop: ADR-0016 item 5 note (2026-10-24); service rule: this row (no ADR) |
