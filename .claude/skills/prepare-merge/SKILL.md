---
name: prepare-merge
description: Prepare and (only on explicit instruction) perform the merge of a finished feature branch into main — runs the pre-merge check, enforces the /review requirement for its tier, drafts the merge commit message, and merges with --no-ff after running tests on the merged result. Use when a branch is done or the user asks to merge, finish, or integrate a branch (e.g. "merge this", "finish this branch", "マージして", "ブランチを取り込む", "作業完了したのでmainに入れて"). Supersedes Superpowers' finishing-a-development-branch in this project. Status: Trial (see meta/adr/ADR-0015).
---

# Prepare Merge

Rules: `.claude/rules/70-git.md` §5 Merge and §6 Pre-Merge Check. This file is only the procedure.

## Steps

1. **Preconditions** — on a feature branch (not `main`), working tree clean. If there are
   uncommitted changes, stop and suggest `/commit`.
2. **Pre-merge check** — run:

   ```bash
   bash "${CLAUDE_PLUGIN_ROOT:-.claude}/hooks/review-score.sh"
   ```

   Read the `MERGE_CHECK=` line and the score. If the script exits non-zero or prints no
   `MERGE_CHECK=` line, treat the tier as `required` and show the error. If it reports
   that the base branch was not found, tell the user to set `REVIEW_SCORE_BASE_BRANCH`.
3. **Tier gate** (§6):
   - `light` → continue
   - `recommended` → suggest `/review`; continue if the user skips it (`Review: skipped`)
   - `required` → `/review` must already have been run on this branch. If it has not,
     stop and ask the human to run `/review` (it is human-invoked — ADR-0009)
4. **Draft the merge message** in the §5 shape — git's default subject
   (`Merge branch '<branch>'`), a one- or two-sentence why (UC-ID if any; optional for
   `light`), and the trailers `Merge-Check:` (tier, score, sensitive paths),
   `Review:` (`normal` / `enhanced` / `skipped`), `Tests:` (filled in step 5).
5. **Show the plan and wait** — the message and the exact commands below (`<base>` is the
   project's base branch, `main` unless `REVIEW_SCORE_BASE_BRANCH` says otherwise).
   Only an approval given **after** this plan is shown counts as the instruction to merge
   (a plain はい / OK / 進めて is enough); the request that triggered this skill does not.

   ```bash
   git checkout <base>
   git fetch && git merge --ff-only origin/<base>   # skip if there is no remote
   git merge --no-ff --no-commit <branch>
   <test command>                                   # e.g. php artisan test
   git commit -F - <<'EOF'                          # only if the tests passed
   <merge message>
   EOF
   ```

6. **Merge on instruction** — run the sequence. Stop and report, without reconciling on
   your own, if: the `--ff-only` update fails (local `<base>` has diverged from the
   remote — never `git pull` with rebase, which would flatten earlier merge commits);
   the tests fail (`git merge --abort`, fix on the branch, start over); or there is a
   conflict (show it; do not resolve it without the user).
7. **After the merge** — `git branch -d <branch>`. Push `main` and delete the remote
   branch only on explicit instruction (§4 Authority).
