# git-troubleshooting.md — When Git Gets Stuck

> For people working with this harness. Not loaded by the AI every session; `docs/development/git-workflow.md` points here.

You do not need to fix Git by hand — ask the AI to explain and propose, then decide. It
never force-pushes or rewrites pushed history (`docs/development/git-workflow.md` §4).

| Situation | Ask the AI |
|---|---|
| Not sure which branch you are on or what is uncommitted | "Explain the current git state (branch, uncommitted changes, unpushed commits)" |
| `git merge --ff-only` failed during a merge | "Local main has diverged from origin — explain why and propose how to reconcile" |
| Merge conflict | "Explain this conflict and propose a resolution; do not resolve it until I approve" |
| Tests failed on the merged result | "Abort the merge and show which tests failed" (then fix on the branch) |
| Committed something by mistake (not pushed yet) | "Undo my last commit but keep the changes" (`git reset --soft HEAD~1`) |
| Committed something by mistake (already pushed) | "Revert that commit" — a new commit that undoes it; pushed history is never rewritten |
| A feature merged into main must be undone | "Revert the merge commit of `<branch>`" (`git revert -m 1 <merge>`) |
| Old branches pile up | "List local branches already merged into main and delete them" |

