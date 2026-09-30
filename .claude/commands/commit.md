# /commit — Commit Proposal Command

Propose how to split the current changes into commits, and commit them after one human
approval. Read `docs/development/git-workflow.md` first (the rules; the active profile is in
`.claude/rules/70-git.md`); this file is only the procedure.

## Steps

1. **Branch check** — run `git status` and `git branch --show-current`. If on `main` and
   the changes go beyond docs/typo-only, get onto a branch first (§0 Profile, §1 Branches):
   `lite` picks a name and says so; `standard` proposes a name and stops until it is
   approved. Then `git checkout -b <name>` (uncommitted changes carry over).
2. **Read the whole diff** — staged, unstaged, and untracked (`git diff`, `git diff --cached`,
   `git ls-files --others --exclude-standard`).
3. **Group into commits** by §2 Commit Unit: behavior change / refactor / formatting apart;
   a migration alone; tests and docs with the code they belong to (in `lite`, one `/tdd`
   cycle may be one commit — §0). Order the groups so
   every commit stays green (e.g. a migration before the code that uses it).
4. **Draft one message per group** by §3 Commit Messages. Flag any group over ~400
   changed lines as a split candidate (≈ score 30 in §6).
5. **Tests** — they must have passed on the full working tree in this session (e.g. the
   `/tdd` Green run). If not, run them once now and report the result.
6. **Ask for one approval** with a single table. In a `lite` combined run (commit → merge →
   push in one go, §4), do not ask here: hand the table to `prepare-merge` step 5, whose one
   plan approval covers the commits too, then continue with step 7 after that approval.

   | # | Files | Lines | Message |
   |---|---|---|---|

   The user may edit messages, merge or drop groups, or move files. Do not commit anything
   before the approval.
7. **Commit** — for each group in order: `git add <files>` then `git commit` with the
   approved message and the `Co-Authored-By:` trailer. Never push, amend, or rebase (§4 Authority).
8. **Report** the short SHAs and subjects. If the branch looks done, suggest `prepare-merge`.

## Constraints

- Only files in the current diff are committed; never `git add -A` blindly past files the
  user did not see in the table
- A commit request made in plain words ("commit this") follows the same steps
- If two kinds of change (e.g. behavior + refactor, or behavior + Pint formatting) are
  mixed inside one file, say so and propose them as one commit, or let the human split
  them with `git add -p`. Never hand-craft partial patches (`git apply --cached`)
