# Global Claude Code Memory

## Language & Style Settings
- Respond in English
- Code comments in English, explanations in English
- Commit messages in English

## Git Operation Rules
- Use SSH connections (`git@github.com:...`)

## Document Management Rules (Required)

Any design or decisions made in Plan mode must be recorded and updated in the following files.
Before starting implementation, read all these files to understand their contents.

| File | Purpose | Content |
|---------|------|---------|
| `PLAN.md` | Development plan | Phase plan, implementation targets, completion criteria, PoC success criteria |
| `BACKGROUND.md` | System background | Introduction background, issues, policy, positioning |

### Rule Details

1. **When exiting Plan mode**: Always reflect the decided plan, specifications, and background in the relevant files
2. **When starting a task**: Read all files before writing any code
3. **When specifications change**: Update the relevant files at the same time as implementation (keep documentation and implementation in sync)
4. **If a file does not exist**: Create it when the first Plan mode session completes

### Docs Update & Review Step Before Implementation (Required)

**Before starting on implementation code**, always carry out the following steps in order.

**Step 1: Update docs** (before implementation)

Check whether the following `docs/ai-context/` files have drifted from the agreed plan, and update them if anything is missing.

| File to check | What to check |
|---|---|
| `docs/ai-context/project-summary.md` | Does the tech stack, focus, and repository structure match the plan? |
| `docs/ai-context/module-map.md` | Are the roles of newly planned directories/files documented? |
| `docs/ai-context/glossary.md` | Have new terms, abbreviations, or status definitions been added? |
| `docs/ai-context/common-commands.md` | Are the run commands for new components documented? |
| `docs/architecture/overview.md` | Does the architecture diagram / component list match the plan? |
| `PLAN.md` | Do the phases, checklist, and completion criteria reflect the latest plan? |
| `BACKGROUND.md` | Does the background / rationale for technology choices match the implementation decisions? |

**Step 2: User review** (always do this after the docs update, before implementation)

Once the docs update is complete, ask the user to confirm before starting implementation:
"The docs have been updated. Once you've reviewed them, I'll start implementation if there are no issues."

**Step 3: Implementation** (only after review approval)

### Commit & Push Rules

- **Only commit or push when the user explicitly instructs it via a command**
- The AI must not commit or push autonomously (an explicit instruction such as "go ahead and push" is required)
- Write commit messages in English

### File Naming Convention

When creating planning files in the global scope (e.g. outside a project directory), follow this naming convention:

```
{project_name}_{task_name}.md
```

**Examples:**
- `mcp_trial_v2_auth_design.md`
- `my_app_db_migration_plan.md`

**Rules:**
- Write the project name and task name in snake_case (lowercase + underscores)
- Use an English word for the task name that concisely describes the work
- If `PLAN.md` / `BACKGROUND.md` can be placed inside a project root, use the conventional file names as usual (this naming convention is for the global scope only)

## Common Patterns
- Audit logs are recorded in JSONL format at `logs/audit.jsonl`
