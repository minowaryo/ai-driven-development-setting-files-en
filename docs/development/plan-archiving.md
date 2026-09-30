# plan-archiving.md — PLAN.md Archive Procedure

> Read when `PLAN.md` approaches its size limit (see `.claude/rules/60-docs.md`). Not loaded every session.

- **What to archive first**: `PLAN.md` is maintained with new entries prepended to the top, so archive **starting from the bottom (oldest) entries**, and only entries whose Status is "done"-equivalent (e.g., Completed, Green confirmed, Merged, Implemented — i.e., no follow-up work is still pending). Leave in place any entry that is awaiting user approval, in progress, or has a next action noted
- **Procedure**:
  1. Move the target entry (the full `##`-heading unit — Decision / Files touched / Status sections together) verbatim into the archive destination named in `.claude/rules/60-docs.md`. Order the archive newest-first as well (i.e., the entry that most recently left `PLAN.md` goes at the top)
  2. Update the archive file's opening description (the range of dates/entries it covers)
  3. Add (on the first archive) or update the "archived" note at the top of `PLAN.md` (range and date)
  4. Move entry bodies and file paths verbatim — do not summarize or abbreviate them (doing so would make it impossible to trace the history later)
- **Where this rule lives**: don't restate the procedure inside `PLAN.md` itself — `.claude/rules/60-docs.md` (limit and destination) and this file (procedure) are the source of truth. `PLAN.md` starts blank and carries at most the "archived" note (range, date, and a pointer to `.claude/rules/60-docs.md`)
