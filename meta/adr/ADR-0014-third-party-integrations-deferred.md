# ADR-0014: Third-Party Integrations Considered and Deferred (Laravel Boost, cc-sdd, hookify) — Not Adopted; Superpowers Under Evaluation

## Status
Accepted (per the "Variant for Recording a Deferral" convention in
`.claude/commands/adr.md` — what's approved is the decision not to adopt each item
now, not the adoption of any of them). Superpowers is the exception: reopened as
**under evaluation**, with use left to each developer (see the 2026-10-26 note).

> Updated 2026-10-26: **Superpowers** — the verdict changes from "Rejected" to
> **"Under evaluation — individual opt-in"**. The comparison against this harness is not
> finished, and the plugin is already installed in some developer environments
> (`ADR-0015`). The template still does not install, enable, or depend on it; whether to
> use it is each developer's own choice.

> Updated 2026-10-05 (ADR-0016 research): **Laravel Boost** — the reason for deferral has
> partly gone. Since v2.10 (2026-09-23) `php artisan boost:install --mcp --no-interaction`
> installs only the MCP configuration, and its guideline writer now replaces only its own
> `<laravel-boost-guidelines>` block instead of overwriting `CLAUDE.md`. It still writes
> `boost.json` / `.mcp.json`, and a new "Project Rules" feature lets the agent write
> `.ai/rules/*` itself (switch off with `BOOST_RULES_ENABLED=false`, as it conflicts with
> docs-first). Verdict stays "deferred, not rejected"; if a project adopts it, use the
> MCP-only path with rules disabled. **hookify** — still deferred: it cannot key on the
> hook's `agent_type`, so it could not implement ADR-0016's implementer-only lock.

## Date
2026-09-28

## Context

The same evaluation pass as `ADR-0013` (a user-provided Superpowers comparison,
broadened to other third-party Claude Code tooling) turned up four more tools. Each
was investigated and verified, and none is being adopted in this pass. Recording the
evaluation here so it isn't silently re-litigated later, per the deferral-recording
convention in `.claude/commands/adr.md`.

## Decision

| Tool | Verdict | Revisit when... |
|---|---|---|
| **Laravel Boost** (`laravel/boost`) | Deferred, not rejected | A project actually wants live DB-schema/query/browser-log MCP tools and version-pinned Laravel/Inertia/Pest doc search. If adopted, register **only** the MCP server manually (`claude mcp add -s local -t stdio laravel-boost php artisan boost:mcp`) — never run `php artisan boost:install`'s guideline-file generation against a live copy of this template, since it overwrites `CLAUDE.md`/`AGENTS.md`/`.mcp.json`/`boost.json` |
| **cc-sdd** (`gotalab/cc-sdd`) | Rejected | Only if this harness's own Gate 0-3 pipeline is ever restructured and a Kiro-style spec format becomes useful for cross-tool portability (Codex/Cursor/Gemini CLI/etc.) — no such need identified now |
| **hookify** (official Anthropic plugin) | Deferred / watch | A future, separately-scoped trial shows a cheap warn-level real Claude Code hook adds defense-in-depth value alongside `domain-boundary-check.sh` — this would *extend* `ADR-0010`'s script-invoked approach, not reverse it |
| **Superpowers** (`obra/superpowers`, wholesale plugin) | Under evaluation — individual opt-in (was Rejected until 2026-10-26) | When the comparison concludes: decide whether the template recommends it, keeps it optional, or rejects it. Inputs: whether its SessionStart force-injection (issues #1480, #1456, #2377) and non-enforced TDD (issues #384, #2372) actually conflict with CLAUDE.md / Gate 4 in day-to-day use |

## Rationale

- **Laravel Boost**: genuinely useful MCP tools (DB schema/query, browser logs, doc
  search), but `boost:install` generating/overwriting `CLAUDE.md`/`AGENTS.md` is
  exactly the kind of silent clobber this template's docs-first design exists to
  prevent. No documented "MCP-only" install flag exists yet, only a manual-
  registration workaround — worth documenting for later rather than wiring into
  `SETUP.md` now.
- **cc-sdd**: structurally, its requirements → design → tasks phase-gate model is
  close to a re-implementation of this harness's own Gate 0-3. Adopting it would mean
  maintaining two overlapping gate systems for no clear gain.
- **hookify**: official and low-risk, but `ADR-0010` already made a deliberate,
  reasoned choice (script invoked by `/review`, not a registered lifecycle hook) —
  reversing or extending that deserves its own focused evaluation, not a rider on
  this one.
- **Superpowers**: the two GitHub-issue-backed risks above are still real, so the
  template does not adopt it. But the original "Rejected" was decided from the issue
  reports, not from use alongside this harness; it is now under evaluation instead.
  Some of its ideas were already captured in-house under `ADR-0013`, independent of
  this verdict.

### Rejected Alternatives
- **Install Superpowers and rely on this repo's CLAUDE.md taking precedence** (per
  Superpowers' own stated design intent): rejected *as a template default* — the
  verified GitHub issues show this precedence isn't reliable in practice.
- **Keep Superpowers "Rejected" and forbid it**: not chosen — the template cannot
  control user-level plugins, the plugin is already in use in some environments, and
  the comparison is not finished.
- **Adopt Laravel Boost's full `boost:install` flow and just re-apply the template's
  CLAUDE.md afterward**: rejected as fragile — `boost:update` regenerates the same
  files, so the overwrite would recur on every update, not just once.

## Consequences

### Benefits
- Closes the loop on all four tools raised in the original comparison — none can be
  silently re-litigated without checking this ADR first.
- Laravel Boost and hookify stay open as documented options rather than being
  dismissed outright, since both have genuine merit if their risk is contained later.

### Drawbacks / Risks
- None of the four's benefits are captured now — if a project urgently wants Laravel
  Boost's live DB introspection, it must write its own project-level ADR to adopt
  just the MCP server first.

## Related
- ADR-0013 (the ideas from Superpowers that *were* adopted in-house)
- ADR-0015 (Git rules override plugin Git skills, including Superpowers')
- ADR-0007 (the precedent for recording an evaluated-but-optional/deferred tool)
- ADR-0010 (the deliberate script-invoked hook design hookify would need to reckon
  with)
