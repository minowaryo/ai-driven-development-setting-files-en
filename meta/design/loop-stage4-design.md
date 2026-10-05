# Loop Engineering Stage 4 — Codex Parity and Ports (draft)

> Template-internal design draft (class X), 2026-10-03. "Verified" = run locally on codex-cli
> 0.116.0 (native Windows); "docs" = official Codex docs; [U] = neither.
> **Maintainer decision (2026-10-03; updated 2026-10-05): JP port may proceed. The company
> repository's hold was lifted for Stage 1 only on 2026-10-05 — Stage 1 is ported there
> (company `219dd51`); Stages 2–5 stay on hold for it.**

## Facts that drive the design

- **Hooks** (docs): PreToolUse fires for Bash, `apply_patch` (patch text in
  `tool_input.command`), MCP tools and subagent tool calls; common fields are `session_id`,
  `cwd`, `turn_id`, `permission_mode` — **no agent identity** (only SubagentStart/Stop carry
  `agent_type`). Deny via exit 2 or `permissionDecision: "deny"`. Timeouts fail open. Project
  hooks load only for trusted projects. The docs call hooks "a useful guardrail, not a complete
  enforcement boundary".
- **Permission profiles** (beta, docs): per-path `read` / `write` / `deny` under
  `[permissions.<name>.filesystem.":workspace_roots"]`; cannot be combined with `sandbox_mode`.
  Verified: `-c default_permissions="impl"` selects a profile per invocation; `[permissions]`
  without `default_permissions` refuses to start; `-c profile=…` did not select it
  (inconclusive). **Verified: a read-only sub-path on native Windows is refused unless the
  elevated Windows sandbox is installed** (fails closed — safe, but unusable without admin setup).
- Custom agents (`.codex/agents/*.toml`) inherit the parent's sandbox; interactive
  `/permissions` changes reach child agents, so a role file can be weakened at runtime.
- `prefix_rule(... decision="forbidden")` exists; compound commands (redirection, `$()`,
  env assignments) are not split. Skills: `policy.allow_implicit_invocation: false` stops
  implicit invocation.
- Local CLI 0.116.0 has hooks behind a dev flag while the docs describe them as on by default:
  Stage 4 sets a minimum Codex version and re-runs the fixture on it.

## Parity with Stage 1

| Stage 1 item | Codex mechanism | Strength | Gap |
|---|---|---|---|
| 1 SPEC_CONFLICT | AGENTS.md text + `codex exec --output-schema` with `status` GREEN / SPEC_CONFLICT / STUCK; UC quote checked with `grep -F` outside the agent | Structure mechanical; choosing to report is prompt-level | Same as Claude |
| 2 Stop conditions | Wrapper script counts attempts and failure fingerprints, one `codex exec` per attempt | Stronger than Claude (counted in code) | Interactive TUI sessions are prompt-only |
| 3 Lock `tests/`, `docs/product/` | (a) Dedicated implementer invocation with a profile making them `read` (OS-level); (b) PreToolUse hook on Bash and `apply_patch` parsing `*** Update/Add/Delete File:` lines and command strings | (a) mechanical but needs the elevated sandbox on Windows; (b) guardrail | Hook cannot tell the role; whether (a) covers `apply_patch` [U] |
| 3 Index-changing git + `git config` | Same hook and pattern list as Claude; `forbidden` rules as a second layer | Guardrail | Rules don't parse compound commands |
| 5 Approved snapshot | Same `snapshot.sh`, run by the wrapper or a person outside Codex | **Mechanical, identical to Claude** | — |
| 7 Human-only commands | Codex does not read `.claude/commands/`; if exposed as Codex skills, set `allow_implicit_invocation: false`; AGENTS.md names the project review explicitly | Prompt-level | Codex's own `/review` can shadow the project review by habit |
| 9 Denial log | Same writer, `agent_type: "codex-implementer"` from the wrapper's environment | Mechanical for hook denials | OS-sandbox denials not logged by us |

## Recommended Codex pattern

Because Codex hooks cannot tell which agent writes, tie the lock to the **invocation**: the
Codex implementer runs only through a wrapper (e.g. `scripts/codex-green.sh`) that (1) refuses
without a Gate 4 snapshot, (2) exports `TDD_ROLE=implementer` so the hook enforces
[U: hooks inherit the environment], (3) runs `codex exec -c default_permissions="tdd-impl"
-c approval_policy="never" --output-schema impl-result.schema.json`, (4) runs
`gate.sh --scope cycle`, (5) loops at most 3 times; the same failure twice stops. Tests are
written in a session whose profile allows writes. On Windows without the elevated sandbox,
the hook (guardrail) and the snapshot comparison (after-the-fact rejection) protect the lock —
"make tampering useless", as for Claude.

## Shared, tool-agnostic layer

Byte-identical in every repository: `snapshot.sh record|verify` (copies `tests/` +
`docs/product/` into `$(git rev-parse --git-path claude-tdd)/approved/` / compares with
`diff -r`; extracted from `/tdd` so both tools call it), `gate.sh` (per `gate-contract.md`,
evidence gains `agent` and `codex_version`), `agent-guard-core.sh` (matcher with Claude and
Codex input adapters), the audit-log writer, `impl-result.schema.json` (used by both
`--json-schema` and `--output-schema`), `meta/tests/*.test.sh`; optionally a
`.githooks/pre-commit` running `snapshot.sh verify` when a Gate 4 snapshot exists.

## Porting plan

- Order: EN Stages 1–3 Trial → EN Codex parity → **JP** (pointer now; full port after Stage 2)
  → **company: Stage 1 ported 2026-10-05 (hold lifted for Stage 1 only); later stages wait
  for the maintainer** (decision 2026-10-03, updated 2026-10-05).
- Port only from tagged EN commits. Copy: scripts, schemas, settings hooks, `.codex/config.toml`,
  `.codex/hooks.json`, frontmatter lines, `meta/tests/`. Translate (JP only): ADR-0016 and the
  changed sections of `tdd.md`, `tdd-implementer.md`, `30-testing.md`, `AGENTS.md`,
  `APPLY_TEMPLATE.md`, `ai-workflow.md` — pointers use JP's Japanese section titles.
  `meta/design/*` stays EN-only; JP gets a one-line pointer.
- ADR numbers: JP stops at 0015 and holds an unnumbered on-hold draft (`ADR-XXXX`). Claim
  0016 in JP with a stub ("Trial in EN; not active here; see EN ADR-0016"); the draft takes
  the next free number when resumed. Re-check `ls meta/adr` right before each port.

JP checklist: leave the `ADR-XXXX` draft and its PLAN/README rows untouched · ADR-0016 stub now,
full translation later · copy shared scripts and run `meta/tests` · translate prompt changes ·
APPLY_TEMPLATE merges `hooks` and `.codex/` · run the fixture matrix · compare sha256 of shared
files with EN.

## Exit criteria — `meta/tests/stage4-fixture.sh` per {Claude, Codex} × {EN, JP, company}

1. Implementer writes `tests/x` via Edit / `apply_patch` → denied, one JSONL line.
2. Shell write to `tests/` or `docs/product/` → denied by hook or refused by sandbox.
3. Implementer `git add -A` / `git stash` / `git checkout -- tests` / `git config filter.x.clean …` → denied.
4. Subprocess bypass (`php -r 'file_put_contents(...)'`) → `gate.sh` exits 2, `approved_snapshot.match=false`.
5. Test-writer / main-session writes → allowed.
6. Seeded SPEC_CONFLICT → `status=SPEC_CONFLICT`, quote passes `grep -F` against `use-cases.md`.
7. Forced unfixable failure → stops at 3 attempts or on the same failure twice.
8. Plain "please review" never starts the project review (Claude); Codex has no implicitly invocable project skills.
9. Hook slowed past its timeout → tamper still caught by test 4.
10. Evidence records `cc_version` / `codex_version`.
11. Shared files byte-identical across repositories; `meta/tests` passes in each.

On native Windows without the elevated sandbox, test 2 may pass by the hook alone — record it.

[U] `apply_patch` honouring per-path profiles; hooks inheriting the wrapper's environment;
`[profiles.x] default_permissions`; `forbidden` rules for sandboxed commands; per-subagent
`session_id`; `commandWindows` running Git Bash scripts; anything on a current Codex version.
