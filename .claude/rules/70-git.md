# 70-git.md — Git Workflow (core, always loaded)

**Profile: `lite`** — `lite` or `standard`; change this line only when the user asks.

Before creating a branch, committing, pushing, or merging, read `docs/development/git-workflow.md`
(the full rules: profile differences, commit unit, merge, pre-merge check). `/commit`, `/tdd`,
and `prepare-merge` read it themselves.

These hold in both profiles, even when that file has not been read:

- Never start implementing on `main` — get onto a branch first (docs/typo-only changes may go to `main`)
- Commit only after the human approves the proposed commits; push, merge into `main`, or delete remote branches only on explicit instruction
- A merge/push request is not itself that approval: show the plan (`prepare-merge`) and act only on an approval given after it — in `lite` one approval may cover commit → merge → push; any failed step stops the rest
- Never force-push (`--force`, `-f`, `--force-with-lease`) and never rewrite pushed history
- Commit messages: English, `type: imperative summary` (`feat` / `fix` / `refactor` / `style` / `test` / `docs` / `chore`), ≤ 72 characters, body says why
- Merge into `main` only with `git merge --no-ff`, after the tests pass on the merged result
- These rules override plugin Git skills (e.g. Superpowers)

Related ADR: `meta/adr/ADR-0015-git-workflow.md`.
