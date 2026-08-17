# ADR-0009: Automatic Review-Intensity Determination Based on a Diff Score

## Status
Accepted

## Date
2026-08-14

## Context

`.claude/rules/30-testing.md` and `.claude/rules/00-global.md` define an operating rule that `/review` should be run after Refactor completes and before merging, but there was no mechanism to detect this and prompt for it, so in practice it was easy to forget.

At the same time, running an AI-driven enhanced review (a Workflow with multiple perspectives and adversarial verification) on every single change would make AI costs excessive. Development also tends to proceed in Phase units (a plan bundling several UCs/features), but ad-hoc small fixes outside a Phase also occur, so tying the mechanism to Phase boundaries would introduce a classification cost ("which Phase does this commit belong to?") that becomes an operational burden.

## Decision

Adopt the following automatic review-intensity determination mechanism.

### Overview

1. When the `/review` command runs, its first step (Step 0) executes the `review-score` script (a deterministic local script that does not call AI)
2. The script measures **the diff from the point where the current branch diverged from `main` (`git merge-base main HEAD`) to the current HEAD** (it keeps no state file)
3. It computes a score using the following weights:
   - Number of changed files
   - Number of changed lines (added + deleted)
   - Matches against sensitive paths (DB migrations, Policies, auth-related directories, etc.)
4. If the score exceeds the threshold, it displays a recommendation to review at the enhanced level, and `/review` proceeds at the enhanced level (a Workflow with multiple perspectives and adversarial verification). At or below the threshold, it proceeds at the normal level
5. The score calculation itself runs locally without calling AI, but the choice and execution of the review level based on that result happens only within a human's explicit `/review` invocation. No review Workflow is ever launched automatically in the background or at times like `git push` (this policy — "execution itself is always triggered by a human calling `/review`" — is referred to below as **Option A (semi-automatic)**)

### Why no state file (the merge-base approach)

A checkpoint approach was initially considered — recording the "last reviewed commit SHA" in `.claude/review-checkpoint` — but was rejected for the following reasons:

- Because the checkpoint is a single state shared across the whole repository, workflows that move between multiple branches (e.g. switching to a small hotfix branch while working on a large Phase branch) would compute the score against an unrelated branch's history, either unfairly inflating a small change's score or producing noisy results
- If updating the checkpoint is forgotten, subsequent scores keep being computed larger than reality

With an approach based on `git merge-base main HEAD`, the score's scope is automatically separated per branch, so the problem of managing/forgetting-to-update a state file doesn't arise at all. It still holds, as before, that there's no need to distinguish between a cohesive Phase-unit development effort and an ad-hoc fix outside a Phase (either is picked up automatically as long as it's part of the diff since the branch diverged from `main`).

As a trade-off, if `/review` is run multiple times on the same long-lived branch, the diff is not reset to "the increment since the last review" — it always recomputes the diff for the entire branch. So a second or later `/review` run may again recommend the enhanced level, including parts that were already reviewed. This is a minor inefficiency (redundant re-checking) that we judge to be less harmful than having the score break across branches, so we accept it.

## Rationale

- The score calculation (equivalent to just `git diff --stat`) runs entirely locally without ever calling AI, so it can be run at zero cost regardless of how often `push` happens
- The AI-cost-incurring enhanced review only happens when the score is actually high (i.e., a genuinely higher-risk change) and only through an explicit human action, avoiding uncontrolled automatic execution or wasted cost
- Being non-blocking means the mechanism never slows down development speed or `push` itself just to deliver a notification

### Rejected alternatives

- **Run an AI-driven complexity analysis on every commit**: rejected because AI cost would be excessive
- **Strictly tie Phase definitions to commits/branches**: rejected due to high classification cost, which conflicts with the requirement that ad-hoc fixes shouldn't need to be tracked
- **Auto-launch via a pre-push hook + install script**: `.git/hooks/` is outside Git's version control, so every new development environment would need an install step (running a script or manually copying files), complicating the file layout and operations. Rejected in favor of keeping the file set simple — `review-score`'s invocation was instead folded into `/review`'s own Step 0
- **Auto-launch the review Workflow in the background when the score exceeds the threshold (Option B: fully automatic)**: a dedup marker keyed on `(branch, HEAD SHA)` could in principle prevent repeated automatic runs against the same state. But that would require a new automatic-trigger path (e.g. push detection) and a new state file for dedup, bringing back — in a different form — the "state file management / consistency across multiple branches" problem the merge-base approach was designed to eliminate. Prioritizing the policy of keeping the file set simple, we adopt Option A for now (semi-automatic: a human explicitly runs `/review`, and only the level selection is automated). Option B can be reconsidered later if forgetting to run `/review` becomes a real operational problem

## Consequences

### Benefits

- Notification helps prevent forgetting to run `/review`
- AI cost scales with how often and how large reviews are actually run, not with push frequency
- No operational cost is incurred in distinguishing cohesive Phase-unit development from ad-hoc fixes outside a Phase

### Drawbacks / Risks

- The score weights and threshold need per-project tuning (the initial values are heuristic, tuning is expected)
- Because execution itself is triggered by a human calling `/review` (Option A), the risk of "forgetting to run `/review` in the first place" still remains (this depends on adherence to the existing operating rule in `.claude/rules/30-testing.md`) — unchanged from the existing rule (run after Refactor completes, before merge)
- Running `/review` multiple times on the same long-lived branch re-evaluates the entire branch diff each time, so the enhanced level may be recommended again, including already-reviewed parts (a minor inefficiency from redundant re-checking, not a functional blocker)

## Related
- `.claude/rules/30-testing.md`
- `.claude/rules/50-review.md`
- `.claude/commands/review.md`
- ADR-0004-ai-development-policy
