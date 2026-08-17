# ADR-0008: Harness Extensions for TDD/E2E Operations (MCP Tool, Sub-Agents, Slash Commands)

## Status
Accepted

## Date
2026-07-15

## Context

[[ADR-0006-e2e-testing-playwright]] and [[ADR-0007-tdd-enforcement-probity]] settled the tooling for test implementation (`@playwright/test` / `@nizos/probity`).
However, the Claude Code-side extensions (MCP tools, sub-agents, slash commands) remained unbuilt, leaving these gaps:

- The AI writes Playwright selectors (`getByRole` / `getByLabel`) without actually looking at the real screen, making them prone to guesswork
- `.claude/rules/30-testing.md` formalized the Red → Green → Refactor operating rule, but **relying on prompt discipline alone makes "don't bundle Red and Green into one request" hard to enforce**
- Standard commands like `/adr`, `/review`, and `/generate-mock` already existed, but there was no equivalent for the TDD cycle or E2E test generation

## Decision

Add the following three items to the harness.

### 1. Playwright MCP (`.mcp.json`, project-scoped)
Add `@playwright/mcp` so Claude Code can actually drive a browser against the locally running app.

### 2. TDD-specific sub-agents (`.claude/agents/`)
- `test-writer` — Red-phase-only. Writes only failing tests
- `tdd-implementer` — Green-phase-only. Implements only the minimum needed to pass the tests

### 3. Slash commands (`.claude/commands/`)
- `/tdd` — a standard command that runs Red → Green → Refactor through the sub-agents
- `/generate-e2e-test` — a standard command that generates a draft Playwright E2E test from use-cases.md (in the same family as `/generate-mock`)

## Rationale

### Why Playwright MCP
- Distinct from `@playwright/test` (the test-authoring library) — this is for **actually driving the browser to check things**, which helps both post-implementation verification and selector accuracy
- Uses accessibility snapshots rather than image analysis (vision), so it needs no image parsing and meshes directly with the role-based selector policy in `.claude/rules/30-testing.md`

### Why separate sub-agents
- Claude Code tends to write tests and implementation in the same turn, which lets the tests bend to fit the implementation. Splitting Red/Green into separate agents isolates context and role, making that kind of accommodation harder
- **Caveat (limitation)**: a sub-agent's `tools` frontmatter can restrict tool *types* (Read/Write/Bash, etc.) but **cannot restrict by file path** (e.g. "no writes under `app/`"). So this is not a hard enforcement mechanism — it's an aid for reinforcing prompt discipline. When true mechanical enforcement is needed, consider adopting Probity per [[ADR-0007-tdd-enforcement-probity]]

### Why slash commands
- Matching the format of the existing `/adr`, `/review`, and `/generate-mock` commands keeps AI tool usage patterns consistent, in line with the philosophy in `docs/ai-context/prompt-patterns.md`

## Consequences

### Benefits
- Better E2E selector accuracy and automated post-implementation behavior verification
- The TDD cycle steps become a standard command, reducing missed instructions

### Drawbacks / Risks
- **Playwright MCP security/privacy notes**:
  - Use it only against a local development environment (e.g. `php artisan serve`) — never connect it to a production URL or a real-data environment
  - Screenshots and accessibility snapshots may capture personal information, so don't share the AI's raw output externally (follow the logging/audit rules in `.claude/rules/40-security.md`)
  - The project-scoped `.mcp.json` triggers a Claude Code approval prompt on first use — verify the server's actual command (`npx @playwright/mcp@latest`) before approving
- **Sub-agent limitations**: as noted above, path-level enforcement isn't possible. The operating assumption is that a human reviews the diff at the end of each `/tdd` phase to confirm `test-writer` didn't accidentally touch implementation code
- Assumes a Node.js runtime (`npx`); PHP-only projects need an additional toolchain

## Related
- `.mcp.json`
- `.claude/agents/test-writer.md`
- `.claude/agents/tdd-implementer.md`
- `.claude/commands/tdd.md`
- `.claude/commands/generate-e2e-test.md`
- ADR-0006-e2e-testing-playwright
- ADR-0007-tdd-enforcement-probity
