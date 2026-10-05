# ADR-0015: Git Workflow — Short-Lived Branches, `--no-ff` Merge Record, Merge-Check Tiers

## Status
Accepted — the merge-check thresholds, the `prepare-merge` skill, and the `lite` profile are **Trial** (see `meta/adr/ADR-0013`)

> Updated 2026-09-30: two profiles, switched by one line (`Profile:` in `.claude/rules/70-git.md`).
> `lite` (default) keeps every safety rule — approved commits, no force push, push only on
> instruction, tests on the merged result — but removes waits: the AI names branches itself,
> commits once per `/tdd` cycle, asks about `/review` only for sensitive paths, and may run
> commit → merge → push on one approval of a shown plan (stopping on any failure).
> `standard` is the rule set below, unchanged. Choose `standard` for production systems with
> real data or 2+ parallel developers. Why: counting the approval stops per feature showed up
> to 6-7 in `standard`, about 3 in `lite`; for solo and pre-production work the extra stops
> bought little. The first full design is kept as `standard` so a project can switch later
> without re-deciding anything.
>
> Updated 2026-09-30 (load cost): the full rules moved to `docs/development/git-workflow.md`,
> read only before Git operations; `.claude/rules/70-git.md` keeps an always-loaded core of
> ~20 lines (profile line + the safety rules that must hold even if the full file is not
> read). This cut the per-session load from ~1,600 to ~400 tokens. Risk accepted: the full
> file can be skipped; then commit splitting and merge messages may be less tidy, while the
> safety rules — including "a merge/push request is not the approval; approve a shown plan" —
> stay in the core and still hold.
>
> Updated 2026-10-03: the pre-merge check also runs the Domain Boundary check
> (`domain-boundary-check.sh`) on every merge, in both profiles. It never changes the tier;
> its count is added to the `Merge-Check:` trailer. Reasoning: `meta/adr/ADR-0010` (2026-10-03 note).

## Date
2026-09-29

## Context

- Teams using this template are mostly solo developers, typically 2-3 per project,
  occasionally mid-size (~5-8). The primary host is GitLab; GitHub must keep working.
- The company has no Merge/Pull Request culture. Introducing one was judged too much
  friction for now, so branches, commits, and merges alone have to produce a usable record.
- Before this ADR the template said "small commits" in three places without defining a
  commit unit, had no rule for branch creation, direct commits to `main`, push timing, or
  merge method, and stated the "AI commits/pushes only on explicit instruction" rule only
  in `GLOBAL_CLAUDE.md` and the sub-agent files. The force-push ban existed only in
  `AGENTS.md`. Docs spoke of "PRs" although no PR process existed.
- The Superpowers plugin (rejected as a whole in ADR-0014) is installed in some developer
  environments; its Git skills prescribe AI auto-commit per task and an AI-executed local
  merge, which conflict with the rules above.

## Decision

The rules are stated once, in `docs/development/git-workflow.md` (read on demand), with an
always-loaded core in `.claude/rules/70-git.md` (profile + safety rules); every other file points there.
Procedures live in `/commit` (`.claude/commands/commit.md`) and the `prepare-merge`
skill (`.claude/skills/prepare-merge/SKILL.md`). In summary:

1. **Branches** — GitHub-Flow-style short-lived branches (`<type>/<issue-no>-<slug>`,
   ≤ 2 working days, 5 at most). Direct commits to `main` only for docs/typo-only changes.
2. **Commit unit** — describable in one sentence, green at every commit, behavior /
   refactor / formatting kept apart, tests with their code. In `/tdd`: Red + Green is one
   commit, Refactor another; a migration is its own commit.
3. **Messages** — the existing `[type]: [summary]` format as a minimal Conventional
   Commits subset (`feat/fix/refactor/style/test/docs/chore`, `!` for breaking).
4. **Authority** — AI commits only after one human approval of a proposed split
   (`/commit`); push only on explicit instruction (`ask`); force push denied; merge
   prepared by `prepare-merge` and executed only on explicit instruction.
5. **Merge** — `git merge --no-ff`; tests run once on the merged result; the merge commit
   carries a short "why" plus `Merge-Check:` / `Review:` / `Tests:` trailers. This commit
   is the lightweight substitute for an MR description.
6. **Pre-merge check** — `review-score.sh` gains a `MERGE_CHECK=` line with three tiers:
   `light` (score < 10, no sensitive path: tests only), `recommended` (10-29: `/review`
   suggested), `required` (≥ 30 or any sensitive path: `/review` mandatory). It runs once
   per branch at merge time, never per commit.
7. **Worktrees** only for parallel sessions; no per-task sub-agent review loop.
8. **Precedence** — these rules override plugin Git skills (Superpowers).

## Rationale

### Why `--no-ff` merge commits instead of an MR process

- `git log --first-parent main` reads as a feature-level list (what an MR list gives),
  and `git revert -m 1 <merge>` undoes a feature in one step.
- The branch's curated commits stay on `main` unchanged, so the commit-unit rule keeps
  paying off after the merge.
- GitLab's default MR merge method is "Merge commit", which produces the same history
  shape — adopting MRs later changes nothing about the history.

### Why these thresholds (calibration, 2026-09-29)

Measured read-only on the real history of 4 in-house Laravel projects (714 non-merge
commits, 92 merges, 370 author-days; scaffold commits excluded):

- Score 10 ≈ 100-150 changed lines in ~3 files; score 30 ≈ 350-450 lines in 6-8 files.
  The line weight 0.05 tracks the observed lines-per-file ratio.
- External anchors: Google eng-practices "Small CLs" (~100 lines usually reasonable,
  ~1000 usually too large) ↔ 10; SmartBear/Cisco review study (defect detection drops
  beyond 200-400 LOC) ↔ 30.
- 10 classifies 89-98% of non-sensitive changes of ≤ 100 lines as `light`; 5 would catch
  only 55-76% (burdening typo-sized work); 15 reaches ~150 lines.
- 30 catches 92-93% of units over 400 lines with almost no false alarms (0-2% of
  `required` merges are ≤ 200 lines); 25 adds noise, 40 lets 23-36% of 400+-line units through.
- Sensitive paths appear in 7-11% of units (mostly migrations, then Policies); only 1-2%
  are pushed to `required` by the sensitive rule alone, so the rule is cheap.
- Committed lock files, minified assets, and fonts were the main source of inflated line
  counts, so the script now excludes them (not `public/js/`, which is hand-written in
  plain-Blade projects).

### Rejected / deferred alternatives

- **Squash merge** — only meaningful with an MR button; discards the curated commits.
- **Rebase / fast-forward merge** — loses the feature grouping; reverting a feature needs N reverts.
- **MR/PR process (Ship / Show / Ask)** — deferred: no MR culture yet, and the merge
  commit already records why / verified / risk. Revisit when a project has 2+ active
  developers who want asynchronous review.
- **GitLab CI** — deferred: without MRs it can only notify after the push; it needs
  runner setup (self-hosted GitLab) and per-stack configuration. Adopt together with MRs.
- **Branch protection** — deferred with MRs (GitLab Free already protects the default
  branch from force-push by default).
- **Versioned warning-only merge hooks (`.githooks/`)** — deferred: they would need two
  hook files, a `review-score.sh --target` option, a `.gitattributes` rule plus the
  executable bit, and a setup step, for a path the AI-mediated flow already covers.
  Revisit when merges regularly happen outside an AI session.
- **AI auto-commit per task (Superpowers)** — conflicts with the explicit-instruction rule.
- **Per-task sub-agent review loop** — AI cost, per ADR-0009.
- **git-flow** — built for versioned multi-release software.
- **commitlint / husky / commit scopes** — overhead without a release pipeline.

## Consequences

- On the historical sample, `required` would cover ~46% of merges — a reflection of how
  large past branches were (43% exceed 400 lines), not of the threshold. Short-lived
  branches and the commit unit are what bring it down; revisit the thresholds with Trial
  feedback (candidates: lower weight for `create_*` migrations, down-weighting docs-only diffs).
- A human who runs `git merge` directly gets no automatic tier warning; the rules still apply.
- `settings.json` permission rules are a guardrail, not a security boundary.
- `GLOBAL_CLAUDE.md` and `.claude/agents/*` keep their own short commit/push prohibitions
  (their readers do not load the Git rule files).

## Related
- `.claude/rules/70-git.md` (core) and `docs/development/git-workflow.md` (full rules)
- `.claude/commands/commit.md`
- `.claude/skills/prepare-merge/SKILL.md`
- `.claude/hooks/review-score.sh` (tests: `meta/tests/review-score.test.sh` — template-internal, `APPLY_TEMPLATE.md` class X)
- `.claude/settings.json`
- ADR-0009-review-escalation-mechanism
- ADR-0012-skills-vs-commands
- ADR-0013-third-party-skill-adoption-trial
