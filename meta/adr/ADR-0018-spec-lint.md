# ADR-0018: Structural Pre-Check of the Spec Documents (spec-lint) (Trial)

## Status
Trial — promote to Accepted after use on a real project, or roll back.

## Date
2026-10-05 (implemented 2026-10-03, `9406ae7`; Japanese headings added `de664de`)

## Context

Gates 1-3 are human approvals of AI-drafted documents (`requirements.md`, `use-cases.md`,
mockups). Part of what the reviewer checked was structure, which a machine can check:
whether every use case has an Actor, a basic flow, error cases and permissions; whether ids
are well-formed and unique; whether each use case points at a real requirement; whether
template text was left in place.

A survey of the whole development cycle (2026-10-03, `meta/design/template-improvement-directions.md`)
found:

- The spec-driven-development tools' consistency steps are LLM prompts (spec-kit `/analyze`,
  Kiro "Analyze Requirements"); the one deterministic validator found (OpenSpec) checks
  headings and keywords only.
- LLM review of specifications found a median 47% of expert-identified issues, with 11%
  false flags (arXiv 2609.03230) — not a substitute for deterministic checks.
- Word-list smell detection is precise only for four categories — subjective language,
  ambiguous adverbs/adjectives, loopholes, open-ended terms — at 0.70-0.96 precision
  (Femmer et al., arXiv 1611.08847); pronoun and negation checks are mostly noise.
- The Loop Engineering design (`ADR-0016`) relies on stable use-case ids and verbatim
  use-case lines for `SPEC_CONFLICT`; nothing guaranteed them.

## Decision

- Add `.claude/hooks/spec-lint.sh`: read-only, bash + awk, no new dependency, no AI call.
  It reports, one line each: malformed or duplicate `UC-NNN` / `F-NNN` ids; a use case
  without Actor, Basic Flow, Error Cases or Permissions, or with one of them empty; a related
  requirement that does not exist, and requirements no use case refers to; template text
  left in place (outside the Approval Record and Review Criteria sections); mockup files vs
  use-case ids vs the Screen List; and, as warnings only, words from the four precise smell
  categories (English and Japanese lists, editable at the top of the script).
- `--requirements` checks `requirements.md` alone (before Gate 1). Requirement-link checks are
  skipped when `requirements.md` is only a pointer (Existing-Codebase Path). Unresolved
  `[inferred]` markers are reported separately, so the same run checks the Gate 0-3 sign-off.
- The AI runs it before asking for Gate 1, Gate 2 or the consolidated Gate 0-3 sign-off and
  shows the findings with the approval request (`CLAUDE.md`, `AGENTS.md`, `SETUP.md` Steps 2
  and 2B, `/onboard-existing-codebase`). It informs the reviewer and never approves, rejects or
  blocks; the Gate definitions are unchanged.
- One file serves both the English and the Japanese templates (headings and labels are
  accepted in both languages, with an ASCII or full-width colon), so the sibling
  repositories copy it byte-for-byte, as they do the other hook scripts.
- Tested by `meta/tests/spec-lint.test.sh` (template-internal); traced in
  `meta/traceability-matrix.md`.

## Rationale

The cheapest reliable improvement to a document gate is to take the mechanical half of the
review away from the human, so the review time goes to whether the content is right and
complete — the part no script can judge. A check that only informs keeps the Gate a human
decision and cannot block work on a false positive.

### Rejected Alternatives
- **Adopt an SDD framework's analyze step (spec-kit, cc-sdd)**: its checks are LLM prompts,
  and adopting the framework duplicates Gates 0-3 (`ADR-0014`).
- **LLM review only**: low recall (47%) and non-deterministic; may still be added as advice
  after the script, never instead of it.
- **Make a clean run a Gate condition**: changes the Gate definitions in three repositories,
  and a false positive would stop work; the findings are shown, the human decides.
- **Require EARS sentence patterns**: evidence is a single industrial case; it would change
  how the business side writes requirements.
- **A broad word list (pronouns, negations, "etc."-style everything)**: low precision in the
  research; noise teaches people to ignore the output.

## Consequences

### Benefits
- Structural gaps are caught before review, every time, at about one second per run.
- Use-case ids and section names stay regular, which the Loop Engineering checks rely on.
- Same file in all three repositories.

### Drawbacks / Risks
- It cannot see a requirement that is missing altogether — the most-cited requirements
  problem; that stays with the reviewer.
- A project that renames the template's headings must edit the label variables at the top
  of the script, or the checks report missing sections.
- Warnings on vague words may be noise in some domains; the lists are editable.

## Related
- `ADR-0010` (the same "deterministic check, informs only" shape for Controllers),
  `ADR-0013` (Trial pattern), `ADR-0014` (cc-sdd not adopted), `ADR-0016` (`SPEC_CONFLICT`)
- `.claude/hooks/spec-lint.sh`, `meta/tests/spec-lint.test.sh`, `meta/traceability-matrix.md`,
  `meta/design/template-improvement-directions.md` (B15)
