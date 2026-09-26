# AI-Driven Development Configuration File Template

A repository template for AI-driven development (Claude Code / Codex combined) based on Laravel + MySQL.

## Overview

This repository is a template that includes:
- **Claude Code rule files** (`CLAUDE.md`, `.claude/rules/`, `.claude/commands/`, `.claude/hooks/`)
- **Codex instruction file** (`AGENTS.md`)
- **User-global settings template** (`GLOBAL_CLAUDE.md`) — copy into `~/.claude/CLAUDE.md`; holds environment-wide rules such as commit/push authority
- **One-time project kickoff guide** (`SETUP.md`) — the Gate 0-4 setup steps, read once when starting a new project (also covers adopting this harness onto a project that already has running code — see `SETUP.md`'s Existing-Codebase Path)
- **AI-summarized documents** (`docs/ai-context/`)
- **Design document templates** (`docs/product/`, `docs/architecture/`, `docs/adr/`)
- **Development process documents** (`docs/development/`, `docs/security/`)
- **The template's own meta ADRs** (`meta/adr/`) — records of design decisions for this template/AI development harness itself, managed separately from the project's own decisions (`docs/adr/`)

## 5-Layer Structure

```
AI Rules Layer              → CLAUDE.md, AGENTS.md, .claude/rules/
Human Design Knowledge      → docs/architecture/, docs/product/, docs/adr/
AI Summary Layer            → docs/ai-context/
Primary Sources Layer       → docs/original-docs/ (human input only — AI editing prohibited, referenced in Steps 1-2 only)
Template's Own Layer        → meta/adr/ (outside the project's own decision-making cycle — no editing or renumbering needed)
```

## File Structure

```
.
├── CLAUDE.md                          # Claude Code entry point
├── AGENTS.md                          # Codex entry point
├── SETUP.md                           # One-time project kickoff guide (Gate 0-4 setup steps)
├── GLOBAL_CLAUDE.md                   # Template for ~/.claude/CLAUDE.md (user-global settings — copy into your own environment)
│
├── PLAN.md                            # Development plan (in-progress task management)
├── .mcp.json                          # Project-scoped MCP servers (e.g. Playwright)
├── .claude/
│   ├── rules/
│   │   ├── 00-global.md               # Global policy, development flow, quality gates
│   │   ├── 10-laravel.md              # Laravel-specific rules
│   │   ├── 15-frontend.md             # Frontend-specific rules (content depends on the ADR-0005 selection; default is Vue.js + Inertia.js)
│   │   ├── 20-mysql.md                # MySQL-specific rules
│   │   ├── 30-testing.md              # Test strategy (Feature/Unit, TDD)
│   │   ├── 31-e2e-testing.md          # E2E test strategy (Playwright — read only when running /generate-e2e-test)
│   │   ├── 40-security.md             # Security rules
│   │   ├── 50-review.md               # Review guidelines
│   │   └── 60-docs.md                 # Documentation update rules
│   ├── agents/
│   │   ├── test-writer.md             # TDD Red-phase-only sub-agent
│   │   └── tdd-implementer.md         # TDD Green-phase-only sub-agent
│   ├── commands/
│   │   ├── review.md                  # /review command
│   │   ├── adr.md                     # /adr command
│   │   ├── generate-mock.md           # /generate-mock command
│   │   ├── tdd.md                     # /tdd command (Red → Green → Refactor)
│   │   ├── generate-e2e-test.md       # /generate-e2e-test command
│   │   └── onboard-existing-codebase.md  # /onboard-existing-codebase command (Existing-Codebase Path, Steps 1B-3B)
│   ├── skills/                        # Entry points the model may invoke on its own (see meta/adr/ADR-0012)
│   │   └── regenerate-traceability/
│   │       └── SKILL.md               # /regenerate-traceability — rebuilds the Matrix table in docs/rcid/
│   └── hooks/
│       ├── domain-boundary-check.sh   # Domain Boundary contract check (run in /review Step 0; --audit-all for whole-repo audit)
│       └── review-score.sh            # Scores the branch diff to pick the review level (/review Step 0)
│
├── meta/
│   └── adr/                           # The template/harness's own ADRs (managed separately from the project's ADRs — no editing or renumbering needed)
│       ├── README.md
│       ├── ADR-0001-use-laravel.md
│       ├── ADR-0002-use-mysql.md
│       ├── ADR-0003-auth-strategy.md
│       ├── ADR-0004-ai-development-policy.md
│       ├── ADR-0005-frontend-stack.md
│       ├── ADR-0006-e2e-testing-playwright.md
│       ├── ADR-0007-tdd-enforcement-probity.md
│       ├── ADR-0008-tdd-e2e-harness-tooling.md
│       ├── ADR-0009-review-escalation-mechanism.md
│       ├── ADR-0010-domain-boundary-contract.md
│       └── ADR-0011-existing-codebase-adoption.md
│
└── docs/
    ├── ai-context/                    # AI summary layer (most important)
    │   ├── project-summary.md         # Full project summary
    │   ├── module-map.md              # Directory responsibility map
    │   ├── common-commands.md         # Frequently used commands
    │   ├── glossary.md                # Terminology glossary
    │   ├── do-not-touch.md            # Areas AI must not modify
    │   └── known-pitfalls.md          # Library/framework-specific snags (checked on error, appended once resolved)
    ├── original-docs/                 # Primary source materials (human-provided, AI editing prohibited — reference only)
    │   └── README.md                  # File list and notes
    ├── product/                       # Business requirements and UI design
    │   ├── requirements.md
    │   ├── use-cases.md               # ★ Most critical: final human review checkpoint
    │   ├── acceptance-criteria.md
    │   ├── ui-guidelines.md           # UI design spec and component guidelines
    │   ├── org-permission-philosophy.md  # Business-side philosophy behind roles/permissions
    │   ├── user-guide.md              # End-user facing feature / usage documentation
    │   ├── uat-scenarios.md           # UAT scenarios (optional, non-blocking — outside Gates 0-4)
    │   ├── uat-results/               # UAT results recorded by a human reviewer
    │   │   └── README.md
    │   └── mockups/                   # HTML mockups (created between Gate 1 and Gate 2)
    │       └── README.md              # Screen list and UC mapping
    ├── architecture/                  # System design
    │   ├── overview.md
    │   ├── data-model.md
    │   └── authz-authn.md
    ├── adr/                           # Decision records for the project itself (starts empty right after applying the template — numbering starts at ADR-0001)
    │   └── README.md                  # Notes on its role (how it differs from meta/adr/)
    ├── development/                   # Development process
    │   ├── coding-standards.md
    │   ├── testing-strategy.md
    │   ├── review-checklist.md
    │   └── ai-workflow.md
    ├── security/
    │   └── secrets-handling.md
    ├── credentials/                   # Dev-only credential locations (git-ignored except its README — never commit real secrets)
    │   └── README.md
    └── rcid/
        └── traceability-matrix.md
```

## Prerequisites

- **Claude Code** — this harness targets Claude Code only
- **Git**
- **Bash + standard POSIX tools** (`awk`, `sed`, `grep`, `wc`) — required by the scripts in `.claude/hooks/`, which `/review` runs in Step 0. On Windows, use Git Bash (bundled with Git for Windows) or WSL
- **Node.js / npm** — for the Playwright MCP server in `.mcp.json` and E2E tests (`/generate-e2e-test`)
- **PHP / Composer** — for the target Laravel application itself

## Getting Started

> **Adopting this onto a project that already has running code?** The steps below (and
> `SETUP.md`'s Step 1-4) assume a new project with no existing code. See `SETUP.md`'s
> Existing-Codebase Path instead — it reverse-engineers the same Gate 0-3 inputs from the
> actual codebase rather than having a human author them from scratch. Fastest path: run
> `/onboard-existing-codebase`.

See `SETUP.md` for the detailed step-by-step Gate 0-4 procedure; the summary below is:

1. Copy this repository as a template for a new project
2. Replace placeholders like `[PROJECT_NAME]` with project-specific information
3. Place primary source materials (requirement notes, screen sketches, etc.) in `docs/original-docs/`
4. Fill in the required files in `docs/ai-context/` by referencing `docs/original-docs/` (Gate 0)
5. Define requirements in order: `docs/product/requirements.md` → `docs/product/use-cases.md`, referencing `docs/original-docs/` (between Gates 1 and 2)
6. Generate HTML mockups with `/generate-mock` and have the business side review them
7. Incorporate feedback into `use-cases.md` and get final human approval (Gate 2)
8. Design and approve `docs/architecture/data-model.md` before starting AI code generation (Gate 3)
9. Use the `/tdd` command to proceed through Red (write a failing test) → test case approval (Gate 4) → Green (implement) → Refactor

## AI-Driven Development Pipeline

```
[Gate 0] docs/ai-context/ filled in
      ↓
[Gate 1] requirements.md — reviewer approved
      ↓  AI may draft use-cases.md
use-cases.md created and revised
      ↓  AI may generate mockups (/generate-mock)
Mockup creation → business review → feedback incorporated into use-cases.md
      ↓
[Gate 2] use-cases.md — final approval ★ Code generation unlocked
      ↓  AI may draft data-model.md
[Gate 3] data-model.md — reviewer approved
      ↓
AI test case generation (Red — /tdd command)
      ↓
[Gate 4] test case approval ★ reviewer confirms before implementation (Green) starts
      ↓
AI implementation code generation (Green — Claude Code / Codex)
      ↓
Refactor
      ↓
Human review and merge
```

## References

- [Claude Code Documentation](https://docs.anthropic.com/claude/docs/claude-code)
- [Codex AGENTS.md Guide](https://platform.openai.com/docs/codex)

## Origin

This repository is an English translation of the original Japanese template:

- **Source repository**: `ai-driven-development-setting-files`
- **Branch**: `main`
- **Commit**: `a4ff08b` (docs: reset project-specific docs to template placeholders)
