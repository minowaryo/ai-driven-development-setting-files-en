# project-summary.md — Project Overview

> This is the first file AI reads. Keep it concise enough to grasp the big picture in 3–5 minutes.
> For details, refer to the individual `docs/` files.

## Project Overview

| Item | Details |
|---|---|
| Project name | [PROJECT_NAME] |
| Purpose | [What it is built for] |
| Target users | [Who will use it] |
| Phase | [MVP / Beta / Production] |

## Technology Stack

| Layer | Technology |
|---|---|
| Backend | Laravel [version] |
| DB | MySQL [version] |
| Frontend | [e.g. Blade / Vue / React] |
| Auth | [e.g. Laravel Sanctum] |
| Queue | [e.g. Laravel Horizon + Redis] |
| Storage | [e.g. S3] |

## Main Domains

| Domain | Description | Main Models |
|---|---|---|
| users | User management and authentication | User, Role |
| [domain2] | [description] | [Model] |
| [domain3] | [description] | [Model] |

## Directory Structure (Overview)

```
app/
  Http/Controllers/   - Controllers (keep thin)
  Services/           - Business logic
  Actions/            - Single-responsibility action classes
  Models/             - Eloquent models
  Policies/           - Authorization policies
docs/                 - All design documents
.claude/              - Claude Code rules and commands
```

For details, see `docs/ai-context/module-map.md`.

## Current Focus

[Describe the features and fixes being worked on in the current sprint]

## Reading Order (Guide for AI)

1. This file (get the big picture)
2. `docs/ai-context/module-map.md` (understand the structure)
3. Detailed documents relevant to the task (refer to the mapping table in CLAUDE.md)
