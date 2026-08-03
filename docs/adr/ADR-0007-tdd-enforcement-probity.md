# ADR-0007: TDD Enforcement Tool Selection (Probity)

## Status
Accepted

## Date
2026-07-15

## Context

`.claude/rules/30-testing.md` only stated that "bug fixes should write a regression test first (TDD)"; it didn't define how to operate the Red → Green → Refactor cycle for ordinary feature development.
AI coding agents (Claude Code) are known to tend toward "write the implementation first, then bolt on tests afterward," and explicit prompt instructions alone don't reliably prevent this. Relying on humans to instruct TDD in every prompt carries review overhead and the risk of missed instructions.

Options considered:

1. **Guidelines only** (formalize the Red-Green-Refactor steps in `.claude/rules/30-testing.md` and provide prompt patterns)
2. **[nizos/tdd-guard](https://github.com/nizos/tdd-guard)** — a TDD-enforcement hook built specifically for Claude Code
3. **[nizos/probity](https://github.com/nizos/probity)** — the successor to tdd-guard; a general-purpose guardrail tool supporting Claude Code / Codex / GitHub Copilot CLI

tdd-guard's own README explicitly states that "new projects should start with Probity," and tdd-guard has entered a compatibility-maintenance phase for existing users.

## Decision

**Adopt Probity (`@nizos/probity`) as an optional enforcement layer, used alongside the guideline formalized in `.claude/rules/30-testing.md`.**

- Enforcement level: not gated. Whether to add the `enforceTdd()` rule to `probity.config.ts` is left as an optional, per-project decision (in line with [[ADR-0004-ai-development-policy]]'s "no full AI automation, human review required" policy, we prioritize a human operating agreement first)
- Supported agents: works for both Claude Code and Codex (via `AGENTS.md`) under the same rule set
- Install command: `npm install -D @nizos/probity`

## Rationale

### Why Probity
- It is a "policy engine" that inspects file writes and shell command execution, and blocks the agent with an explanation and remedy when a rule is violated — this fits well with other rules already in this repo (the quality gates in 00-global.md, the review perspectives in 50-review.md), beyond just TDD enforcement, e.g. checking that tests pass before `git commit`
- Test-runner agnostic (tdd-guard needed a reporter configuration per test runner — Vitest/Jest/pytest — while Probity reads session history, making setup lighter)
- Matches this repo's `AGENTS.md` operation, which assumes both Claude Code and Codex are used together (tdd-guard is Claude Code-only)

### Alternatives rejected
- **Guidelines only**: formalizing the steps alone doesn't prevent "write the implementation first, bolt on tests after" behavior. That said, the guideline itself is maintained independently of this ADR so that projects without an enforcement tool still keep a baseline discipline (`.claude/rules/30-testing.md`)
- **tdd-guard**: its maintainers recommend migrating to the successor Probity, so adopting it fresh is discouraged

## Consequences

### Benefits
- Mechanically detects implementation without tests, strengthening the effectiveness of the absolute prohibition on "implementation without tests" in `.claude/rules/00-global.md`
- The same rule set can be shared across Claude Code and Codex

### Drawbacks / Risks
- False positives (legitimate no-test changes, e.g. pure documentation changes) may block the agent's work. The rule needs to exclude target paths (`docs/`, `*.md`, etc.)
- Adds setup and rule-maintenance overhead
- Assumes a Node.js runtime (PHP-only projects need an additional toolchain)

### Operating rule
- Whether to adopt it is a per-project decision; if adopted, create `probity.config.ts` referencing this ADR
- Even when not adopted, the Red-Green-Refactor guideline in `.claude/rules/30-testing.md` applies across all projects

## Related
- `.claude/rules/30-testing.md`
- `docs/development/ai-workflow.md`
- `docs/ai-context/common-commands.md`
- ADR-0004-ai-development-policy
