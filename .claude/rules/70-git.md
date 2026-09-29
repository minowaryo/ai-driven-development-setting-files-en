# 70-git.md — Git Workflow

> Related ADR: `meta/adr/ADR-0015-git-workflow.md` (evidence, rejected options).
> This file is the only place Git rules are stated; other files point here.
> Procedures live in `/commit` (`.claude/commands/commit.md`) and the `prepare-merge` skill.

## §1 Branches

- `main` always works. Work on a short-lived branch cut from `main`; no `develop` / release branches
- A branch is required for any change to code, tests, migrations, or config. Only docs/typo-only changes may be committed directly to `main`
- Name: `<type>/<issue-no>-<slug>` (issue number optional; `type` as in §3), e.g. `feat/123-order-export`, `fix/login-timeout`
- Lifetime: aim for ≤ 2 working days, 5 at most — past that, split by UC or layer
- The base branch is the project's default branch (`main` unless `REVIEW_SCORE_BASE_BRANCH` says otherwise)
- AI does not start implementation on `main`: it proposes a branch name and waits for consent

## §2 Commit Unit

| Criterion | Rule |
|---|---|
| One sentence | The change can be described in one sentence without "and" |
| Always green | Tests pass at every commit (keeps `git bisect` / `git revert` usable) |
| Three kinds apart | Behavior change, refactor, and formatting (Pint output) are separate commits |
| Tests with code | A test is committed together with the logic it verifies |

- `/tdd`: Red is never committed alone; Red + Green is one commit; Refactor is a separate commit
- A migration is its own commit
- Docs describing a code change go in the same commit; a docs-only change is its own `docs:` commit
- Every commit request — `/commit` or plain words — follows the `/commit` procedure

## §3 Commit Messages

```
[type]: [summary of change]

[why, if needed]
```

- `type`: `feat` / `fix` / `refactor` / `style` (formatting only) / `test` / `docs` / `chore`; append `!` for a breaking change (e.g. a migration needing coordinated deployment). No scopes
- Subject: imperative, English, ~50 characters (72 at most), no trailing period
- Body: wrapped at 72, explains why, not how
- AI-authored commits keep the `Co-Authored-By:` trailer

## §4 Authority

| Operation | AI |
|---|---|
| `git add` | Allowed |
| `git commit` | Proposes the split and messages; commits after one human approval (`/commit`) |
| `git push` | Only on explicit instruction (`ask` in `.claude/settings.json`) |
| Force push (`--force`, `-f`, `--force-with-lease`) | Never (`deny`); a human may do it by hand |
| Merge into `main` | Prepares it (`prepare-merge`); executes only on approval given after the merge plan is shown |
| Rewriting pushed history | Never on its own initiative |

Permission rules are a guardrail, not a security boundary (e.g. `git -C . push` is not matched); the rules above apply regardless.

## §5 Merge

- Merge with `git merge --no-ff`: the branch's commits stay as they are, grouped by one merge commit (`git log --first-parent main` reads as a feature list; `git revert -m 1 <merge>` undoes a feature)
- Tests run once, on the merged result, before the merge commit is made
- Merge commit message — git's default subject, a short why, and trailers:

```
Merge branch 'feat/123-order-export'

Let accounting export the order list as CSV for monthly reconciliation (UC-012).

Merge-Check: required (score 34; database/migrations/2026_09_29_add_export_flag.php)
Review: enhanced
Tests: php artisan test (128 passed)
```

- `Review:` is `normal` / `enhanced` / `skipped`; `skipped` only for `light` / `recommended`. For `light`, the why line is optional

## §6 Pre-Merge Check

Runs once per branch at merge time (never per commit), from `.claude/hooks/review-score.sh`'s `MERGE_CHECK=` line.

| Tier | Condition | Before merging |
|---|---|---|
| `light` | score < 10 (`REVIEW_SCORE_LIGHT_THRESHOLD`) and no sensitive path | Tests only |
| `recommended` | 10 ≤ score < 30 | `/review` suggested; may be skipped |
| `required` | score ≥ 30 (`REVIEW_SCORE_THRESHOLD`) or any sensitive path | `/review` mandatory (enhanced level at ≥ 30) |

Score 10 ≈ 100-150 changed lines, 30 ≈ 350-450 lines. Thresholds are Trial (ADR-0015).

## §7 Parallel Sessions and Worktrees

Only when running two or more AI sessions at once:

- One worktree + one branch per session, under `.claude/worktrees/` (`claude --worktree <name>`)
- Sessions do not edit the same files (split by UC or layer); each worktree needs its own `composer install` / `npm install` / `.env`
- Integrate into `main` one branch at a time, each through §5
- No automatic per-task sub-agent review loop — review stays the single pre-merge `/review` (§6)

## §8 Precedence over Plugin Skills

These rules override plugin skills (e.g. Superpowers):

- A plan's per-task "Commit" step goes through `/commit` approval — no autonomous commits
- `finishing-a-development-branch` is superseded by `prepare-merge`
- `using-git-worktrees` only for parallel sessions (§7)
- Per-task sub-agent review loops are not run
