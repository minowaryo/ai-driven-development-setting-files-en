# 50-review.md — Review Guidelines (core)

- Any review — `/review` or a plain "review this" — reads the full guidelines first: `docs/development/review-guidelines.md` (review-score intensity, author self-check, reviewer perspectives)
- Before any merge, even when `/review` is skipped, the author self-check in that file applies (`prepare-merge` runs it)
- Whether a merge needs `/review` is decided by the pre-merge check (`docs/development/git-workflow.md` §6); `/review` itself is always started by a human (`meta/adr/ADR-0009-review-escalation-mechanism.md`)
- The scoring scripts use `REVIEW_SCORE_BASE_BRANCH` / `DOMAIN_BOUNDARY_BASE_BRANCH` (default `main`); set them when the project's base is `master` / `develop`
