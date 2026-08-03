# CLAUDE.md

## Project

- **Project name**: [PROJECT_NAME]
- **Stack**: [e.g. Laravel + MySQL]
- **Type**: [e.g. Monolith web application / API / etc.]
- **Main domains**: [e.g. Inventory management / Order processing / etc.]
- **Repository**: [GitLab/GitHub URL]

---

## ⚠️ Required Steps Before Starting the Project (Gate 0)

After cloning this repository, complete the following steps in order before touching any code.
AI cannot provide accurate assistance until these files are filled in.

### Step 1 — Select the frontend stack → fill in ai-context (do this first)

**1a. Frontend stack selection**

- Review the selection criteria and comparison table in `docs/adr/ADR-0005-frontend-stack.md` and decide this project's frontend stack
- Record the selection with the `/adr` command as `docs/adr/ADR-XXXX-frontend-stack-selection.md` (if you choose anything other than the default recommendation — Vue 3 + Inertia.js + Pinia — or are torn between candidates, document the reasoning and the rejected options)

**1b. Reflect the confirmed selection into the rule file**

- Rewrite `.claude/rules/15-frontend.md` to match the selected stack (if you selected Vue 3 + Inertia.js + Pinia, the default content can be used as-is)
- Rewrite the Frontend section of `docs/ai-context/module-map.md` to match the actual directory layout (do not leave it as the placeholder example)

**1c. Fill in ai-context**

> Before creating these files, place primary source materials (requirement notes, screen sketches, etc.) in `docs/original-docs/` and reference them.
> After Step 1 is complete, do not use `docs/original-docs/` as the default reference.
> Transcribe the 1a selection result into the Frontend row of `project-summary.md`.

| File | Content | Priority |
|---|---|---|
| `docs/ai-context/project-summary.md` | Full project overview, purpose, and tech stack | Required |
| `docs/ai-context/glossary.md` | Project-specific terms and abbreviations | Required |
| `docs/ai-context/module-map.md` | Directory structure and module responsibilities | Required |
| `docs/ai-context/do-not-touch.md` | Areas and files AI must not modify | Required |
| `docs/ai-context/common-commands.md` | Frequently used commands (migrate / test / lint, etc.) | Recommended |
| `docs/ai-context/prompt-patterns.md` | Standard prompt templates | Optional |

### Step 2 — Create requirements documents

```
docs/product/requirements.md        ← Created by business team / BA
    ↓ Gate 1: reviewer approval
docs/product/use-cases.md           ← Created by business team / BA (AI may draft)
    ↓
docs/product/mockups/               ← AI may draft (/generate-mock command)
    Business review → incorporate feedback into use-cases.md
    ↓ Gate 2: final reviewer approval ★ Code generation prohibited until this gate is passed
docs/product/acceptance-criteria.md ← AI may draft
```

> **Mockup timing principle**: Mockups should be created between Gate 1 and Gate 2.
> The purpose is to align requirements understanding with the business side — Gate 3 (data model approval) does not need to be waited for.
> Incorporate mockup feedback into use-cases.md before Gate 2 approval.

### Step 3 — Architecture design

```
docs/architecture/data-model.md  ← Created by developers (AI may draft)
docs/architecture/overview.md    ← Created by developers
docs/adr/ADR-xxxx-[title].md     ← Created each time a technology decision is made
    ↓ Gate 3: reviewer approval
```

### Step 4 — Code generation and implementation (only after Gates 2 and 3 are passed)

Implementation proceeds via the `/tdd` command using **TDD (Red → Green → Refactor)**.

```
Red → [Gate 4: test case approval ★ implementation (Green) prohibited until passed] → Green → Refactor → /review
```

> Unlike Gates 0-3 (passed once per project), Gate 4 is repeated per feature/UC every time the TDD cycle runs.
> See `.claude/rules/30-testing.md` for the phase-by-phase steps, sub-agent setup, and when to run each skill.

---

## Read first (every session)

- `docs/ai-context/project-summary.md`
- `docs/ai-context/glossary.md`
- `docs/ai-context/module-map.md`
- `docs/ai-context/common-commands.md`

## Read when relevant (task-based)

| Task type | Read this |
|---|---|
| Creating / updating requirements.md or use-cases.md | `docs/original-docs/` (primary sources) + `docs/product/requirements.md` |
| Requirements / UC reference | `docs/product/requirements.md` + `docs/product/use-cases.md` |
| Code implementation (feature development) | `docs/product/use-cases.md` + `docs/architecture/data-model.md` + `docs/product/mockups/` |
| UI implementation / mock-based development | `docs/product/ui-guidelines.md` + `docs/product/mockups/` |
| Frontend component changes | `.claude/rules/15-frontend.md` (implementation rules for the selected frontend stack — see `docs/adr/ADR-0005-frontend-stack.md`) |
| Auth / authorization changes | `docs/architecture/authz-authn.md` |
| DB schema changes | `docs/architecture/data-model.md` + `docs/adr/` |
| Architecture / core design changes | `docs/adr/` |
| Adding / modifying tests | `docs/development/testing-strategy.md` + `docs/product/use-cases.md` + `docs/architecture/data-model.md` |
| Security-related changes | `docs/security/secrets-handling.md` |
| Release / deployment | `docs/operations/deployment.md` |
| Change request (CR) | `docs/rcid/traceability-matrix.md` |

## Global rules

- **Workflow**: Proceed in the order: Explore → Plan → Implement → Test
- Always read `docs/ai-context/` at the start of a session
- **Do not generate code until Gate 2 (use-cases.md approval) is complete**
- **Do not start implementation (Green phase) until Gate 4 (test case approval) is complete** (`.claude/rules/30-testing.md`)
- `docs/original-docs/` is read-only (editing, deleting, and creating files prohibited)
- Review documentation before touching code
- Always check `docs/adr/` before making large-scale changes
- Authorization must always go through Policy / Gate (bypassing is prohibited)
- Do not make DB schema changes without a migration plan
- Prefer small diffs (multiple small commits over one large commit)
- When design intent changes, update documentation too

## Detailed rules

See `.claude/rules/` for detailed rules:

- `.claude/rules/00-global.md` - Global policy, development flow, quality gates
- `.claude/rules/10-laravel.md` - Laravel-specific rules
- `.claude/rules/15-frontend.md` - Frontend-specific rules (content is rewritten per project based on the selection in `docs/adr/ADR-0005-frontend-stack.md`; default content is Vue.js + Inertia.js)
- `.claude/rules/20-mysql.md` - MySQL-specific rules
- `.claude/rules/30-testing.md` - Test strategy
- `.claude/rules/40-security.md` - Security
- `.claude/rules/50-review.md` - Review guidelines
- `.claude/rules/60-docs.md` - Documentation update rules
