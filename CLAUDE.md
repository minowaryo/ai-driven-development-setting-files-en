# CLAUDE.md

## Project

- **Project name**: [PROJECT_NAME]
- **Stack**: [e.g. Laravel + MySQL]
- **Type**: [e.g. Monolith web application / API / etc.]
- **Main domains**: [e.g. Inventory management / Order processing / etc.]
- **Repository**: [GitLab/GitHub URL]

---

## ⚠️ Required Steps Before Starting the Project (Gate 0)

After cloning this repository, complete the one-time setup steps in **`SETUP.md`** before touching any code.
AI cannot provide accurate assistance until the files it lists are filled in. `SETUP.md` is read once
at project kickoff — it is not part of the steady-state per-session reading list below.

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
| Frontend component changes | `.claude/rules/15-frontend.md` (implementation rules for the selected frontend stack — see `meta/adr/ADR-0005-frontend-stack.md`) |
| Auth / authorization changes | `docs/architecture/authz-authn.md` + `docs/product/org-permission-philosophy.md` (business-side permission philosophy) |
| DB schema changes | `docs/architecture/data-model.md` + `docs/adr/` |
| Architecture / core design changes | `docs/adr/` |
| Adding / modifying tests | `docs/development/testing-strategy.md` + `docs/product/use-cases.md` + `docs/architecture/data-model.md` |
| Security-related changes | `docs/security/secrets-handling.md` |
| Creating credentials / API keys, etc. | `docs/credentials/` (follow the handling rules in `.claude/rules/40-security.md`) |
| Release / deployment | `docs/operations/deployment.md` |
| Change request (CR) | `docs/rcid/traceability-matrix.md` |
| User-facing feature / usage change | `docs/product/user-guide.md` |
| Performing UAT (acceptance testing, optional) | `docs/product/uat-scenarios.md` + `docs/product/uat-results/` (see the UAT section in `.claude/rules/00-global.md`; non-blocking) |
| Hit an error or library-specific snag | `docs/ai-context/known-pitfalls.md` (check first for a known issue, and append once resolved) |

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
- `.claude/rules/15-frontend.md` - Frontend-specific rules (content is rewritten per project based on the selection in `meta/adr/ADR-0005-frontend-stack.md`; default content is Vue.js + Inertia.js)
- `.claude/rules/20-mysql.md` - MySQL-specific rules
- `.claude/rules/30-testing.md` - Test strategy (Feature/Unit, TDD)
- `.claude/rules/31-e2e-testing.md` - E2E test strategy (Playwright; only read when running `/generate-e2e-test`)
- `.claude/rules/40-security.md` - Security
- `.claude/rules/50-review.md` - Review guidelines
- `.claude/rules/60-docs.md` - Documentation update rules
