# ADR-0016: Loop Engineering Roadmap, and Stage 1 — Mechanical TDD Enforcement (Trial)

## Status
Trial — approved 2026-10-03; Stage 1 simplified and re-approved 2026-10-05 (see "Who may
change what" and item 5). Promote to Accepted after the
Stage 2 experiment, or roll back per item.

## Date
2026-10-03

## Context

A design memo (`meta/design/loop_engineering_design_memo.txt`, Japanese) proposes evolving
this harness from "AI writes code inside human gates" into "Loop Engineering": an
Orchestrator + Coder + Reviewer that iterate implement → verify → review on their own,
bounded by deterministic gates, locked acceptance tests, a read-only evidence-based
reviewer, permission tiers and stop conditions.

The memo was checked with eight research/red-team passes and three tool-adoption passes
(2026-10-01 – 10-03). The findings that drive this ADR:

- **The risk is real.** On spec/test-conflict tasks, frontier models cheat in roughly half
  of the runs, mostly by editing the tests, even when told not to. Making the tests
  read-only stops this, and giving the model an explicit "flag the conflict and stop"
  option cut one model's cheating from 54% to 9% (ImpossibleBench, arXiv 2510.20270).
- **This harness relies on prompts for exactly that point.** `tdd-implementer` has the same
  tools as `test-writer` (`.claude/agents/*.md`); "do not edit `tests/`" is an instruction
  only. Gate 4 (human approval of the Red tests) is the only safeguard, and in practice it
  is often a formality.
- **The memo's full architecture does not fit a small team yet.** A planner/generator/
  evaluator harness costs about 22× a solo agent (Anthropic, "Harness design for
  long-running apps"); teams running loops at scale (Stripe, Spotify, Cognition) keep the
  orchestration in code, keep a single writer, and judge pass/fail with deterministic
  checks. Native Windows has no Claude Code OS sandbox, so in-process blocks can be
  bypassed through subprocesses; a check is only reliable if it can reject a tampered
  result after the fact.
- **No existing tool covers the core.** Probity (`ADR-0007`) cannot tell which agent is
  writing and its `enforceTdd()` does not support subagents or Pest syntax; hookify cannot
  key on the agent either; `/goal` is judged by a small model reading the transcript; none
  of the built-in loops can pause for a human. The surrounding pieces (Pest/PHPUnit strict
  modes, JSON/JUnit output of each tool, `--json-schema`, Stop hooks, budgets, worktrees)
  are already available.
- **Verified on Claude Code 2.1.278 (2026-10-03):** a PreToolUse hook registered in
  `.claude/settings.json` receives `"agent_type":"tdd-implementer"` for writes made by that
  subagent and no `agent_type` for main-session writes. The same hook declared in the
  subagent's frontmatter did **not** run under `claude -p`. `tool_input.file_path` arrives
  as an absolute Windows path.

## Decision

### Goal

AI may iterate implement → verify → review, while TDD discipline and human decisions stay
intact. Humans keep: use-case approval, approval of the tests that matter (authorization,
validation, regression, user-visible behavior), and merge decisions. Machines check that
tests were not tampered with, that the gates pass, and that a repeated failure stops the
loop. **TDD itself (Red → Green → Refactor) is not negotiable at any stage.**

### Principles

1. TDD does not change; only who verifies its discipline changes.
2. Checking goes to machines; deciding stays with humans.
3. Make tampering useless (detected and rejected), rather than trying to make it impossible.
4. Advance a stage only on measured results (each stage has exit criteria).
5. Use built-in / existing tools first; build only the small parts nothing else covers.

### Stages

| Stage | Scope | Exit criteria |
|---|---|---|
| 1 — this ADR | Mechanical TDD discipline inside the template (below) | Hook and its tests pass; blocked attempts are logged |
| 2 | Deterministic `gate.sh` + evidence JSON; read-only reviewer that reads the evidence; experiment in two parts — 2a unattended checks (seeded conflicts, shadow replays, reviewer seeds), then 2b a 2-week human A/B on a real Laravel project only if 2a is promising | Zero undetected test/spec weakening; no rise in escaped defects |
| 3 | Bounded Green loop (Stop hook running the gate); structured review result; Gate 4 `lite`/`standard` profiles | Human time per task −30% or more; zero undetected weakening; cost within budget |
| 4 | JP/company ports; Codex parity; traceability AC/Evidence columns | Same behavior in all three repos and under Codex |
| 5 (conditional) | Autonomous loop run from outside the agent (sandboxed, budgeted); a separate repository only if needed | Started only if Stage 3 succeeds and a real gap remains |

#### Deterministic tools on the change side too (Stages 2–3)

This applies the general division of labor in `docs/development/ai-workflow.md`
("Deterministic Tools First") to the loop; the broader improvement map is
`meta/design/template-improvement-directions.md`. Up to Stage 1, deterministic tools only
*judge* results. Large-scale migration reports show
they should also *make* changes, with the LLM handling only what they cannot: Google
(arXiv 2504.09691 — 39 migrations, 74.45% of code changes generated by the LLM after
automated change-location discovery, ~50% less total time, every change human-reviewed)
and Slack (Enzyme → React Testing Library: LLM-only 40–60% success, AST codemods alone 45%,
the hybrid 80% — yet only 22% of migration time saved). Applied here:

1. **Machine-fixable failures never reach the LLM.** When the gate fails, auto-fixers run
   first (`pint`; optionally Rector); only the remaining failures go back to the
   implementer. Fewer loop iterations, lower cost, and no "while fixing style" side edits.
2. **Machines find the locations, the LLM changes them.** Deterministic finders
   (`domain-boundary-check.sh --audit-all`, Larastan, Rector dry-run) produce the work
   list; the LLM fixes one item at a time; the gate confirms. Scope and completion are
   both decided mechanically.
3. **Include migration-type tasks in the Stage 2 experiment.** Behavior-preserving work
   (deprecated-API replacement, raising the Larastan level, Domain Boundary backlog) is
   where loops pay off in every reported case. The existing tests are the oracle and can
   all be locked — no new tests, so the least room for tampering. This is the Refactor
   phase of TDD (green before, green after), so the TDD discipline is unchanged.

The Slack/Google time savings (22% / ~50%) with humans still reviewing every change are a
reminder that review stays the bottleneck: advance only on measured results.

Stages 2–5 each get their own ADR (or an amendment to this one) before work starts. Gate
definitions (`00-global.md` / `SETUP.md` / `AGENTS.md`) do not change before Stage 3.

### Who may change what (Stage 1)

Stage 1 has one job: **the implementer cannot move the goal it is asked to reach.** The lock
applies to `tdd-implementer` only, during Green; everyone else keeps working as today.

| Who | `tests/` | Spec (`docs/product/`) | Application code |
|---|---|---|---|
| A person | Any time | Any time (through the change-request flow) | Any time |
| Main session (talking with a person) | On the person's instruction | Drafts / fixes with the person's approval (Gates 1–2, change requests) | Yes (e.g. Refactor) |
| `test-writer` (Red) | Writes them — its job | Reads only | No |
| **`tdd-implementer` (Green)** | **Locked** | **Locked** | Writes it — its job |

A legitimate change to tests or spec needs no special command: a person decides → restart
from Red → Gate 4 approval, which takes a fresh snapshot (item 5). *(Simplified 2026-10-05:
an earlier review proposal for `/tdd relock` / `/tdd abandon` commands, a lock lifetime and a
locked-paths config file was dropped as too much to operate; none of it is needed once the
lock only binds the implementer.)*

### Stage 1 items

1. **SPEC_CONFLICT** — `tdd-implementer` stops and reports when the approved tests and the
   spec contradict each other or cannot both be satisfied, instead of working around them.
2. **Stop conditions** — at most 3 Green attempts per cycle; the same failure twice in a
   row escalates to the human (`/tdd`).
3. **Test lock hook** — a PreToolUse hook in `.claude/settings.json` denies `Write`/`Edit`
   under `tests/` (and Bash commands that write there) when `agent_type` is
   `tdd-implementer`, and appends each denial to a JSONL log. Path separators are
   normalized before matching. The main session and `test-writer` are unaffected.
   Verified hands-on (2.1.278, `claude -p`): the deny works both as exit 2 + stderr and as
   JSON `permissionDecision: "deny"`; main-session writes pass; a `Bash` call from the
   subagent also carries `agent_type`, and a check on `file_path` alone let
   `echo x > tests/a.txt` through — so the hook must also inspect the Bash `command`
   string. Written with bash builtins only (no `grep`/`sed` subprocesses): ≈ 83 ms per call
   vs ≈ 500 ms on Windows Git Bash, and it runs on every tool call.
   The mechanism is OS-independent (a Claude Code hook + a bash script; Git Bash on
   Windows, already a prerequisite). It is designed to hold on the weakest platform —
   native Windows, which has no OS sandbox — and can be strengthened with the sandbox on
   macOS / Linux / WSL2.
   The same hook also denies, for `tdd-implementer`, Bash commands that change the index
   or the working tree through git (`git add`, `commit`, `stash`, `checkout`, `restore`,
   `reset`, `rm`, `mv`, `apply`, `update-index`) and `git config`; `tdd-implementer.md`
   drops its "`git add` is fine" allowance. The implementer has no need to stage or to
   configure git. *(Amended 2026-10-03; `git config` added 2026-10-05.)*
   The locked paths are `tests/` **and `docs/product/`** (use cases, acceptance criteria,
   requirements): an implementer that could edit the spec could "finish" by rewriting it
   (memo §6, goal hacking), and the SPEC_CONFLICT report is checked against verbatim quotes
   from `use-cases.md`, which only works while the spec cannot move. *(Amended 2026-10-03.)*
   **A hook that times out fails open**: verified 2026-10-03 (2.1.278, Windows) — on timeout
   the hook's deny is discarded and the tool call proceeds, and a child process that keeps
   stdout open holds the call for its full run regardless of the timeout. The lock hook
   therefore must stay fast (bash builtins only, no external commands) and must never leave
   a child process running. *(Amended 2026-10-03.)*
4. **Hook tests** — `meta/tests/` (template-internal, like `review-score.test.sh`).
5. **Green evidence (approved snapshot)** — when Gate 4 is approved, `/tdd` (main session)
   copies `tests/` and `docs/product/` into `$(git rev-parse --git-path claude-tdd)/approved/`
   (inside `.git/`, never committed). After Green it compares the current files with that
   copy (`diff -r`); if anything was modified, deleted or added, it shows the person the
   diff and the cycle does not continue until the person decides. This catches writes the
   hook cannot see (e.g. through a subprocess). A new Gate 4 approval replaces the copy.
   Why a plain copy: the baseline must not depend on anything the implementer can move.
   `HEAD` fails (the `lite` Git profile commits only after Green, so new Red files are
   untracked); the real index fails (`git add -A` after tampering — reproduced 2026-10-03);
   and a git tree hash via a temporary index also fails — it was **reproduced on 2026-10-05
   that a clean filter (`git config filter.x.clean …` + `.gitattributes`) makes tampered
   files hash to the approved value**. Comparing files directly does not go through git
   filters, and it gives the person a readable diff instead of a hash. *(Rewritten
   2026-10-05; supersedes the 2026-10-03 tree-hash version.)*
6. **Record corrections** — `ADR-0007` (Probity: no subagent/agent-type support, Pest
   syntax not recognized, ~834 MB of dependencies, its own config unprotected) and
   `ADR-0014` (Laravel Boost now has an MCP-only install path) get dated update notes.
7. **Commands are model-invocable** — Claude Code treats `.claude/commands/*.md` as skills
   the model may invoke on its own unless the file sets `disable-model-invocation: true`
   (code.claude.com/docs/en/skills). This contradicts `ADR-0009` (`/review` is always
   started by a human), Gate 4's pause in `/tdd`, and the commit-approval rule behind
   `/commit`; it also breaks `ADR-0012`'s premise that a command "only ever runs when
   typed". Add `disable-model-invocation: true` to every template command (all of them
   fall on the "wrong moment is the failure mode" side of `ADR-0012`) and add a dated
   correction note to `ADR-0012`. The template's `/review` keeps its name: renaming it
   would send a human who types `/review` out of habit to the bundled generic review,
   skipping review-score and the Domain Boundary check. Verified 2026-10-03 (2.1.278,
   `claude -p`, 3/3 runs): the project `/review` wins over the bundled alias, and a plain
   "please review" request made the model invoke the project `review` command on its own
   (confirming the problem). This precedence is **not documented** (the docs only cover a
   project skill named `code-review`), so it is recorded as a platform fact to re-check on
   every Claude Code upgrade; the interactive TUI was not tested. Also add
   `"skillOverrides": {"code-review": "user-invocable-only"}` to `.claude/settings.json`
   (verified: the model then never picked the bundled review, and a human typing
   `/code-review` still ran it). Verified 2026-10-03 (2.1.278): `disable-model-invocation:
   true` on a `.claude/commands/*.md` file blocks model invocation (0/2) while typing the
   command still works; fallback if a later version changes this: `skillOverrides` entries
   such as `"review": "user-invocable-only"`. Note: in Git Bash, `claude -p "/review"` is
   mangled by MSYS path conversion — test from PowerShell.
   Callers that currently start another command must stop doing so, because the flag also
   stops the model from starting it on a human's behalf: `/tdd` step 6 ("run
   `/generate-e2e-test`") and `prepare-merge` step 1 ("run `/commit` steps 1-5") change to
   "read `.claude/commands/<name>.md` and follow its steps" — the flag blocks invocation, not
   reading the file. *(Amended 2026-10-03.)*
8. **Hook reaches adopted projects** — `APPLY_TEMPLATE.md` class C currently merges only
   the `permissions` entries of `.claude/settings.json` into a target that already has one;
   extend it to merge the `hooks` entries too, or the test lock silently disappears on the
   Existing-Codebase Path.
9. **Denial log** — `logs/audit.jsonl` at the project root (JSONL, one line per denial:
   time, event, `session_id`, `agent_type`, tool, normalized path — never file contents),
   git-ignored. `session_id` lets Stage 2 join denials to tasks. The path follows the
   AI-work audit-log convention in `GLOBAL_CLAUDE.md` (`logs/audit.jsonl`); each line carries
   an `event` type (e.g. `agent_guard_denial`), and the docs state in one line that this is
   the record of AI agent activity, distinct from the application's own `audit` log channel
   (`storage/logs/audit.log`, `.claude/rules/40-security.md`). *(Amended 2026-10-03.)*
10. **Version check** — platform facts above were verified with the CLI on PATH (2.1.278),
   while VS Code extension sessions ran 2.1.283–2.1.284 in the same week. Re-run the
   verification fixture on the version actually used before relying on the hook, and record
   the version next to each platform fact.

Deliberately **not** in Stage 1: the structured review result schema (no consumer yet),
hashes of any kind (item 5 uses a plain copy), lock-management commands or a lock
lifetime, a locked-paths config file, changes to Gate 4, any orchestrator, installed plugins.

### Where things live

- This template (EN) carries Stages 1–3 as Trial. JP receives a pointer first and the full
  port after the Stage 2 experiment (Stage 4). The company repository receives nothing —
  not even a pointer — until the maintainer lifts its hold *(amended 2026-10-03)*.
- No separate repository before Stage 5.
- The design memo stays in `meta/design/` (template-internal; not copied into projects).

### Rollout tracking

Approved 2026-10-03; all items implemented 2026-10-05 on `feat/loop-stage1` (hook tests, snapshot tests and an end-to-end `claude -p` run on 2.1.288 pass).

| Item | Status | Notes |
|---|---|---|
| 1 SPEC_CONFLICT | Trial | Prompt-level; backed by the ImpossibleBench result |
| 2 Stop conditions | Trial | Watch for premature escalation on legitimate retries |
| 3 Test lock hook | Trial | First registered lifecycle hook in this template; locks `tests/` + `docs/product/` for the implementer only; also denies index-changing git commands and `git config`; watch false positives |
| 4 Hook tests | Trial | — |
| 5 Green evidence | Trial | Approved snapshot copy + `diff -r` (rewritten 2026-10-05: index- and tree-hash-based checks were both shown forgeable) |
| 6 ADR-0007 / ADR-0014 notes | Trial | Record-only |
| 7 `disable-model-invocation` on commands + `skillOverrides` for `code-review` | Trial | Project `/review` wins today (undocumented — re-check on upgrade) |
| 8 APPLY_TEMPLATE hook merge | Trial | — |
| 9 Denial log | Trial | Includes `session_id` |
| 10 Version check | Trial | Re-verified 2026-10-05 on 2.1.288 (VS Code extension): all denials, the allowed app write and the log line behave as on 2.1.278 |

Drafts for later stages (not decided): `meta/design/gate-contract.md`,
`loop-stage2a-seeds.md`, `loop-reviewer-design.md`, `loop-stage4-design.md`,
`loop-stage5-design.md`, and `meta/design/loop-stage2-experiment-protocol.md`
and `meta/design/loop-stage3-loop-design.md`.

### Dependencies

Each stage states what it adds to the tech stack; a new runtime is a reason to prefer another
option.

| Stage | New dependency | Note |
|---|---|---|
| 1 | **None** | Bash + POSIX tools (`cp`, `diff`) + Git — already prerequisites (`README.md` "Prerequisites"). The lock hook itself uses bash builtins only (speed, and a timed-out hook fails open — item 3); no `jq`, Node or PHP |
| 2 | None required: `php artisan test` (Pest), `pint --test` and PHPStan Level 6+ are already required (`docs/development/ai-workflow.md` "Quality Gates", `docs/development/coding-standards.md`), and `composer audit` by `.claude/rules/40-security.md`. Larastan (PHPStan's Laravel extension) is **not** yet required anywhere — a Composer dev package if a project adopts it | Optional only: Larastan, Rector (+ Laravel rules), Laravel Boost (Composer dev packages); PCOV or Xdebug (PHP extension) for mutation testing (`pest --mutate`); Probity (Node 22, ~834 MB) |
| 3 | None (Claude Code built-ins: Stop hooks, `--json-schema`, `--max-budget-usd`) | — |
| 4 | Codex configuration only (hooks / permission profiles) | Optional: PR-Agent for the company GitLab (Python/Docker, separate LLM API key) |
| 5 | WSL2 or a devcontainer (for the OS sandbox) | Decided in its own ADR |

## Rationale

The cheapest change with real effect is to turn the one prompt-only rule that matters most
for TDD — "the implementer does not touch the tests" — into a check that cannot be
silently ignored, and to give the implementer a legitimate way out (SPEC_CONFLICT) so that
it has less reason to cheat. Both work with the current human-gated flow, so nothing in the
Gate definitions has to change, and both produce data (denials logged) that the later
stages need to justify themselves.

### Rejected Alternatives

- **Adopt the memo's full architecture now** (four loops, fourteen schemas, Spec/Test/
  Permission agents, control plane): cost and failure modes are not justified for a small
  team before a measured baseline exists.
- **Build a custom orchestrator in a separate repository now**: built-ins (Stop hooks,
  `--max-budget-usd`, `--json-schema`, Workflows) already cover most of it, enforcement must
  live in the project's own `.claude/` anyway, and a fourth repository adds porting cost.
- **Use Probity as the Stage 1 core** (`ADR-0007`): cannot distinguish `tdd-implementer`
  from `test-writer`; `enforceTdd()` misjudges subagent flows. Kept as an optional
  auxiliary layer.
- **Session-wide `permissions.deny` on `Edit(tests/**)`**: would also block `test-writer`.
- **Hook in the subagent's frontmatter**: did not run under `claude -p` in testing.
- **Relax Gate 4 now**: changes a Gate definition across 20+ files and three repositories
  before any data shows it is safe; deferred to Stage 3.
- **Do nothing**: leaves TDD's core guarantee — the goal is fixed before the
  implementation — resting on a prompt.

## Consequences

### Benefits
- "Do not edit `tests/`" becomes enforced for the implementer, with an audit trail.
- Denial counts show, for the first time, whether Gate 4 was actually protecting anything.
- No change to the human workflow or to the Gate definitions.

### Drawbacks / Risks
- First registered lifecycle hook in the template (`ADR-0010` deliberately used a
  script invoked from `/review` instead); hooks must keep working in Git Bash on Windows.
- The hook is bypassable through subprocesses on native Windows; the post-Green
  `git diff` check is the backstop, and a fully autonomous loop (Stage 5) needs checks run
  from outside the agent.
- With `disable-model-invocation: true`, a plain-language request ("review this",
  "commit this") no longer starts the command; the human types the command, which is the
  intended behavior. The underlying rules (`docs/development/review-guidelines.md`,
  `docs/development/git-workflow.md`) still apply to plain requests.
- Codex users keep prompt-level protection until Stage 4 (Codex hooks / permission
  profiles); the `git diff` check applies to both.
- JP keeps an on-hold draft ADR that takes the next free number when resumed; this ADR's
  number must be reconciled when porting.

## Related
- `meta/design/loop_engineering_design_memo.txt`
- `ADR-0004` (human/AI split), `ADR-0007` (Probity), `ADR-0009` (review escalation),
  `ADR-0010` (Domain Boundary check), `ADR-0013` (Trial pattern), `ADR-0014` (deferrals),
  `ADR-0015` (Git workflow)
- `.claude/agents/tdd-implementer.md`, `.claude/commands/tdd.md`, `.claude/rules/30-testing.md`
