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

## Common Patterns
- Audit logs are recorded in JSONL format at `logs/audit.jsonl`
