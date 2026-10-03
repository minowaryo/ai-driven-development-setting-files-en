# Loop Engineering Stage 5 — Runner Outside the Agent (draft)

> Template-internal design draft (class X), 2026-10-03. Design only. Stage 5 is conditional
> (ADR-0016) and needs its own ADR before any work. [D] = stated in the official docs (fetched
> 2026-10-03); [U] = not verified hands-on.

## 1. What Stage 5 adds, and when

| Gap | Why Stages 1–3 cannot close it |
|---|---|
| Unattended runs (backlog, migration-type work lists such as B9) | The Stage 3 loop lives inside a human-started interactive `/tdd` |
| A gate the agent cannot reach | The SubagentStop gate runs inside the agent's process tree; on native Windows a subprocess can bypass it, and a timed-out hook fails open |
| Hard cost cap | `--max-budget-usd` is print-mode only [D] |
| Guaranteed end of an attempt | A subagent hitting `maxTurns` returns without SubagentStop; a separate `claude -p` per attempt ends on its own limits |
| Real secrets / shared working tree | Stage 3 runs in the developer's checkout with the real `.env` |
| Context growth | Stage 3 continuations grow one context; Stage 5 starts each attempt fresh |

**Start only if all hold**: Stage 3 met its exit criteria over ≥ 10 cycles on a real project;
≥ 20 queued tasks whose tests can be fully locked; Stage 2a shadow replays showed tests
unchanged in 100% of runs and gate pass ≥ 50%; an agreed monthly budget; its own ADR.

**Not needed if**: Stage 3 cycles are short enough that a person stays anyway; the backlog is
small; or a built-in covers the gap (e.g. Workflows that can run shell and pause for a person,
or cloud / self-hosted environments that work with GitLab and keep push credentials outside the
agent [U]).

## 2. Runtime — recommendation: a dedicated WSL2 distro + Claude Code's Bash sandbox

| | (a) WSL2 + Bash sandbox | (b) Devcontainer (reference, default-deny firewall) | (c) GitLab CI job with `claude -p` | (d) Agent SDK program |
|---|---|---|---|---|
| Isolation | OS sandbox (bubblewrap) for Bash and children [D]; file tools/hooks only by permission rules [D]; harden with `wsl.conf` `[automount] enabled=false`, `[interop] enabled=false` (no `/mnt/c`, no `git.exe`) [D] | Whole process in the container; outbound denied by default [D] | One container per job; depends on the runner executor | None of its own; needs (a)–(c) |
| Secrets | Only the API key, scrubbed from subprocesses | Credentials in `~/.claude` can reach allowed hosts (docs warning) [D] | Masked variables and `CI_JOB_TOKEN` visible to every process in the job | As its host |
| Cost / effort | No infra; low–medium | Docker licence at larger companies [U]; medium | Runner minutes; company data policy; medium | New runtime (D8); high |
| Pause points | Runner exits ESCALATED; a person re-runs | Same | Manual jobs are built-in pauses | Build yourself |

(a) adds no runtime and puts the OS sandbox where it works. The runner is a host-independent
bash script, so (c) can become the team setup later with the same script as **two jobs**: an
agent job with no write token producing a Git bundle + evidence as artifacts, and a manual
`publish` job holding the token. Move to (b) if file tools and hooks must also sit inside an OS
boundary (the docs call the Bash sandbox alone insufficient for fully unattended runs in bypass
or auto mode [D]; this design uses `dontAsk`, not bypass).

## 3. Runner

Two Linux users: `loop` owns state, the approval record and DB admin credentials; `agent` runs
`claude -p` and the gate's test execution. The publisher runs on the Windows host (or in the
manual CI job), holds the push credential, and never executes repository code.

```
run(task):                                   # approval.json written by the human's /tdd approve
  A  = read approval.json                    # approved_ref, lock_tree, locked_paths, expected_ids, budget
  S  = /home/loop/runs/$RUN_ID               # state outside the workspace; agent can't read/write it
  WS = clone --single-branch A.approved_ref from a local mirror; remove origin   # not a worktree
  create DB loop_$RUN_ID + its own user; WS/.env from .env.loop.template         # never the real .env
  copy vendor/ from cache; render S/settings.json with absolute paths
  fp_prev=""; cost=0; t0=now
  for n in 1..3:
    as agent: claude -p "$(task_prompt; cat S/feedback.txt)" --agent tdd-implementer \
      --settings S/settings.json --model $PINNED --permission-mode dontAsk \
      --max-turns 40 --max-budget-usd $PER_ATTEMPT --output-format json --json-schema impl.json > S/a$n.json
    cost += total_cost_usd
    tamper = tree_hash(WS, A.locked_paths) != A.lock_tree      # detect before restoring
    restore A.locked_paths from A.approved_ref; restore vendor/ and .env
    if tamper: escalate("lock_violation")                       # never retried
    if structured_output.status == SPEC_CONFLICT: escalate(cites_ok ? "spec_conflict" : "spec_conflict_uncited")
    rc = as agent, network off: gate.sh --scope cycle --evidence S/e$n.json
    if rc == 2: escalate("lock_violation"); if rc == 3: escalate("tool_error")   # 3 is not an attempt
    if rc == 0 and junit_ids == A.expected_ids and failed == skipped == 0: goto PASS
    fp = sha1(sorted failing ids + first error line)
    if fp == fp_prev or cost >= A.budget or now-t0 > 60m or denials >= 3: escalate(reason)
    fp_prev = fp; write a factual summary (≤ 40 lines) to S/feedback.txt
  escalate("max_attempts")
PASS:
  reviewer: claude -p --tools "Read,Grep,Glob" --json-schema finder.json → ReviewResult v2 → route
  runner commits the diff (locked paths excluded) as loop-bot on loop/<task>-<RUN_ID>
  git bundle → outbox/$RUN_ID; state = READY_FOR_PUBLISH
publish (host or manual CI job): verify bundle head; push; glab mr create --draft (evidence summary)
```

`escalate()` writes `escalation.json` + a ≤ 20-line note, sets ESCALATED and exits. Human pause
points: Gate 4 approval (before), ESCALATED, publish, the draft MR review. Nothing auto-merges.

**Residual risk**: the gate executes the agent's code, which could forge JUnit output from
inside the test process (e.g. a shutdown function). Mitigations — the special-casing scan
(Stage 2a), restoring `phpunit.xml` and bootstrap files, sealed spec-true oracle tests, human
MR review — reduce it; they do not remove it.

## 4. Permission tiers (memo §15) and secrets

| Tier | Operations | Where | Mechanism |
|---|---|---|---|
| GREEN | Read/Grep/Glob; pest, `php artisan test`, pint, phpstan; `git diff/status/log` | Agent | `permissions.allow`; Bash sandboxed, no network |
| YELLOW (policy) | Edit/Write in `app/ routes/ database/ resources/ lang/` | Agent → gate + reviewer | `allow Edit(...)`; user-facing paths route to USER_FACING_CHANGE |
| YELLOW (runner only) | Composer changes, network | Runner, after a person agrees | `deny Bash(composer *)`, `allowedDomains: []`; a dependency change escalates |
| RED | Push, MR, merge, real `.env`/credentials, production DB, deploy | Publisher or a person | Absent from the distro; `deny Read(./.env*)`; per-run disposable DB |

The runtime policy is passed with `--settings`, because a repository's `.claude/settings*.json`
cannot loosen the sandbox or turn filesystem isolation off, `credentials` entries in project
settings are ignored, and `mask` entries are honoured only from user/managed settings or
`--settings` [D]. Sketch:

```json
{"permissions":{"defaultMode":"dontAsk",
  "allow":["Read","Grep","Glob","Edit(./app/**)","Edit(./routes/**)","Edit(./database/**)",
           "Bash(vendor/bin/pest *)","Bash(php artisan test *)","Bash(vendor/bin/pint *)"],
  "deny":["Edit(./tests/**)","Write(./tests/**)","Edit(./docs/product/**)","Edit(./phpunit.xml*)",
          "Read(./.env*)","Read(./docs/credentials/**)","Bash(git add *)","Bash(git commit *)",
          "Bash(git push *)","Bash(composer *)","WebFetch","WebSearch"]},
 "sandbox":{"enabled":true,"failIfUnavailable":true,"allowUnsandboxedCommands":false,
  "autoAllowBashIfSandboxed":false,
  "filesystem":{"denyWrite":["<WS>/tests","<WS>/docs/product","<WS>/phpunit.xml","<WS>/.git"],
                "denyRead":["/home/loop"]},
  "network":{"allowedDomains":[]},
  "credentials":{"envVars":[{"name":"ANTHROPIC_API_KEY","mode":"deny"}]}}}
```

[U] path-prefix meaning of `./` in rules; `agent_type` reaching hooks under `--agent`;
`dontAsk` with `autoAllowBashIfSandboxed: false`; **whether sandboxed commands can reach MySQL**
(Unix socket / local TCP) — check first, fall back to SQLite where the project allows.

Secrets: per-run `.env.loop` (fresh `APP_KEY`, DB user limited to `loop_$RUN_ID`, mail/queue
`array`/`sync`, no third-party keys); API key from a dedicated Console workspace with its own
spend limit [U], scrubbed from subprocesses (`credentials.envVars` deny,
`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` [D]). Credential masking (`mask` + `injectHosts`, needs
`network.tlsTerminate` [D]) is unnecessary in v1 — the agent needs no outbound credential.

## 5. Where it lives

| Criterion | Opt-in folder in the template | Separate repository |
|---|---|---|
| Code | Bash ≤ ~300 lines, no new runtime | Own runtime (SDK), tests, CI, releases |
| Users | Maintainer + opt-in projects | Several company projects, or GitLab CI templates via `include:` |
| Versioning / porting | Moves with the rules; copied to three repos | Independent; one place, pinned |

Start as an opt-in folder copied only on request; move to a separate repository as soon as any
right-hand criterion holds. **Always in the project's `.claude/`**: hooks, agent definitions,
`gate.sh`, the locked-path list, the UC-group convention — they must work without the runner
(Stages 1–3), and the sandbox's protected paths cover `.claude/` [D]. Runner side:
orchestration, settings template, publisher.

Minimum interface (each format carries `v`): the `gate.sh` CLI, exit codes and evidence JSON
(`gate-contract.md`); `approval.json` v1 (approved_ref, lock_tree, locked_paths, expected_ids,
UC, approver, ts — needs a commit of the Red tests: the `standard` profile's Red commit, or a
bundle snapshot at approval, since under `lite` Red tests are untracked until Green);
`state.json` v1 (PREPARED / ATTEMPT(n) / REVIEW / READY_FOR_PUBLISH / ESCALATED / PUBLISHED);
`escalation.json` v1 (max_attempts / same_failure / lock_violation / tool_error / spec_conflict /
budget / timeout / denials / review_unavailable); ReviewResult v2; the audit JSONL envelope.

## 6. Ready for parallel runs (not built now)

Key everything on `RUN_ID` from day one: own clone (not a worktree — it shares the object
store), DB and user, ports from an allocated range (`APP_PORT`, `VITE_PORT`), state directory,
branch `loop/<task>-<RUN_ID>`; one run per task (lock file) plus a total budget cap; per-run
logs merged afterwards; the `standard` Git profile (documented for parallel work, and its Red
commit gives the runner its approved ref).

Docs facts that shaped this: repository settings cannot turn filesystem isolation off; the
sandbox wraps shell commands only (file tools and hooks run outside it); `claude -p` without
`--bare` runs project hooks without a trust prompt (keeps the Stage 1 hook active); the
sandbox protects `.claude/` settings/hooks/agents and `.git` config/hooks; Anthropic's GitLab
CI example exposes the API key and `CI_JOB_TOKEN` to the agent's process (hence two jobs).

Sources: code.claude.com/docs/en — sandboxing, sandbox-environments, devcontainer,
cli-reference, headless, gitlab-ci-cd, agent-sdk/secure-deployment; learn.microsoft.com/windows/wsl/wsl-config.
