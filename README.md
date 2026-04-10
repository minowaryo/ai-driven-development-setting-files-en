# AI-Driven Development Configuration File Template

A repository template for AI-driven development (Claude Code / Codex combined) based on Laravel + MySQL.

## Overview

This repository is a template that includes:
- **Claude Code rule files** (`CLAUDE.md`, `.claude/rules/`, `.claude/commands/`)
- **Codex instruction file** (`AGENTS.md`)
- **AI-summarized documents** (`docs/ai-context/`)
- **Design document templates** (`docs/product/`, `docs/architecture/`, `docs/adr/`)
- **Development process documents** (`docs/development/`, `docs/security/`)

## 4-Layer Structure

```
AI Rules Layer              → CLAUDE.md, AGENTS.md, .claude/rules/
Human Design Knowledge      → docs/architecture/, docs/product/, docs/adr/
AI Summary Layer            → docs/ai-context/
Primary Sources Layer       → docs/original-docs/ (human input only — AI editing prohibited, referenced in Steps 1-2 only)
```

## File Structure

```
.
├── CLAUDE.md                          # Claude Code entry point
├── AGENTS.md                          # Codex entry point
│
├── PLAN.md                            # Development plan (in-progress task management)
├── .claude/
│   ├── rules/
│   │   ├── 00-global.md               # Global policy, development flow, quality gates
│   │   ├── 10-laravel.md              # Laravel-specific rules
│   │   ├── 20-mysql.md                # MySQL-specific rules
│   │   ├── 30-testing.md              # Test strategy
│   │   ├── 40-security.md             # Security rules
│   │   ├── 50-review.md               # Review guidelines
│   │   └── 60-docs.md                 # Documentation update rules
│   └── commands/
│       ├── review.md                  # /review command
│       ├── adr.md                     # /adr command
│       └── generate-mock.md           # /generate-mock command
│
└── docs/
    ├── ai-context/                    # AI summary layer (most important)
    │   ├── project-summary.md         # Full project summary
    │   ├── module-map.md              # Directory responsibility map
    │   ├── common-commands.md         # Frequently used commands
    │   ├── glossary.md                # Terminology glossary
    │   ├── do-not-touch.md            # Areas AI must not modify
    │   └── prompt-patterns.md         # Standard prompt templates
    ├── original-docs/                 # Primary source materials (human-provided, AI editing prohibited — reference only)
    │   └── README.md                  # File list and notes
    ├── product/                       # Business requirements and UI design
    │   ├── requirements.md
    │   ├── use-cases.md               # ★ Most critical: final human review checkpoint
    │   ├── acceptance-criteria.md
    │   ├── ui-guidelines.md           # UI design spec and component guidelines
    │   └── mockups/                   # HTML mockups (created between Gate 1 and Gate 2)
    │       └── README.md              # Screen list and UC mapping
    ├── architecture/                  # System design
    │   ├── overview.md
    │   ├── data-model.md
    │   └── authz-authn.md
    ├── adr/                           # Architecture Decision Records
    │   ├── ADR-0001-use-laravel.md
    │   ├── ADR-0002-use-mysql.md
    │   ├── ADR-0003-auth-strategy.md
    │   └── ADR-0004-ai-development-policy.md
    ├── development/                   # Development process
    │   ├── coding-standards.md
    │   ├── testing-strategy.md
    │   ├── review-checklist.md
    │   └── ai-workflow.md
    ├── security/
    │   └── secrets-handling.md
    └── rcid/
        └── traceability-matrix.md
```

## Getting Started

1. Copy this repository as a template for a new project
2. Replace placeholders like `[PROJECT_NAME]` with project-specific information
3. Place primary source materials (requirement notes, screen sketches, etc.) in `docs/original-docs/`
4. Fill in the required files in `docs/ai-context/` by referencing `docs/original-docs/` (Gate 0)
5. Define requirements in order: `docs/product/requirements.md` → `docs/product/use-cases.md`, referencing `docs/original-docs/` (between Gates 1 and 2)
6. Generate HTML mockups with `/generate-mock` and have the business side review them
7. Incorporate feedback into `use-cases.md` and get final human approval (Gate 2)
8. Design and approve `docs/architecture/data-model.md` before starting AI code generation (Gate 3)

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
AI code generation (Claude Code / Codex)
      ↓
AI test generation
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
- **Commit**: `104c26e` (feat: add original-docs as read-only source material directory)
