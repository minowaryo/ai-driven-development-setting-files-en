---
name: prepare-merge
description: Prepare and (only on explicit instruction) perform the merge of a finished feature branch into main — runs the pre-merge check, enforces the /review requirement for its tier, drafts the merge commit message, and merges with --no-ff after running tests on the merged result. Use when a branch is done or the user asks to merge, finish, or integrate a branch (e.g. "merge this", "finish this branch", "マージして", "ブランチを取り込む", "作業完了したのでmainに入れて"). Supersedes Superpowers' finishing-a-development-branch in this project. Status: Trial (see meta/adr/ADR-0015).
---

# Prepare Merge

Read `docs/development/git-workflow.md` first — §0 Profile, §5 Merge, §6 Pre-Merge Check hold
the rules; this file is only the procedure. The active profile is the `Profile:` line in
`.claude/rules/70-git.md`.

## Steps

1. **Preconditions** — on a feature branch (not `main`), working tree clean. If there are
   uncommitted changes: in `lite`, when the user asked for commit → merge (→ push) in one
   go, run `/commit` steps 1-5 and include its table in the step 5 plan; otherwise stop
   and suggest `/commit`. Then run the author self-check ("Pre-Review Self-Check" in
   `docs/development/review-guidelines.md`) and list any unmet item in the step 5 plan.
2. **Pre-merge check** — run:

   ```bash
   bash "${CLAUDE_PLUGIN_ROOT:-.claude}/hooks/review-score.sh"
   ```

   Read the `MERGE_CHECK=` line and the score. If the script exits non-zero or prints no
   `MERGE_CHECK=` line, treat the tier as `required` and show the error. If it reports
   that the base branch was not found, tell the user to set `REVIEW_SCORE_BASE_BRANCH`.
3. **Tier gate** (§6) — `/review` "has run" only if it ran in this session after the
   branch's last commit, or the user confirms it did; never infer it.
   - `standard`:
     - `light` → continue
     - `recommended` → suggest `/review`; continue if the user skips it (`Review: skipped`)
     - `required` → if `/review` has not run, stop and tell the human in plain words why it is
       needed (a large change, or a sensitive area) and ask them to run it (it is
       human-invoked — ADR-0009)
   - `lite`: continue without mentioning the tier or score — except when a
     sensitive path matched **or the script failed** (step 2): then ask once, in plain words
     (e.g. "this touches a DB migration — run `/review` first?"), and follow the answer
     (`Review: skipped` if declined)
4. **Draft the merge message** in the §5 shape — git's default subject
   (`Merge branch '<branch>'`), a one- or two-sentence why (UC-ID if any; optional for
   `light`), and the trailers `Merge-Check:` (tier, score, sensitive paths),
   `Review:` (`normal` / `enhanced` / `skipped`), `Tests:` (filled in step 6).
   The tier and score go only into the `Merge-Check:` trailer; never show them to the user
   (`docs/development/git-workflow.md` §6, "Talking to the user").
5. **Show the plan and wait** — the message and the exact commands below (`<base>` is the
   project's base branch, `main` unless `REVIEW_SCORE_BASE_BRANCH` says otherwise).
   Only an approval given **after** this plan is shown counts as the instruction to merge
   (a plain はい / OK / 進めて is enough); the request that triggered this skill does not.
   In a `lite` combined run (§4), the one plan also lists the commits to create and —
   only if the user asked for it — the final `git push origin <base>`, and must show the
   changed files and the test command; one approval then covers the whole sequence.

   ```bash
   git checkout <base>
   git fetch && git merge --ff-only origin/<base>   # skip if there is no remote
   git merge --no-ff --no-commit <branch>
   <test command>                                   # e.g. php artisan test
   git commit -F - <<'EOF'                          # only if the tests passed
   <merge message>
   EOF
   git branch -d <branch>
   ```

6. **Merge on instruction** — run the sequence. Stop and report, without reconciling on
   your own, if: the `--ff-only` update fails (local `<base>` has diverged from the
   remote — never `git pull` with rebase, which would flatten earlier merge commits);
   the tests fail (`git merge --abort`, fix on the branch, start over); or there is a
   conflict (show it; do not resolve it without the user).
   In a `lite` combined run, a failure at any point stops the rest — the approval does
   not carry past a failed step.
7. **After the merge** — the local branch is deleted as listed. Push `<base>` and delete the
   remote branch only on explicit instruction (§4 Authority); a `lite` combined-run approval
   counts as that instruction for the push it listed.
