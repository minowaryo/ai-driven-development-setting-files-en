# ADR-0019: The Non-stop Stretch (Loop Engineering Stage 3, Redefined)

## Status
Trial

## Date
2026-10-12

## Context

ADR-0016 planned Stage 3 as a bounded Green **retry loop**. Stage 2a (ADR-0017) and analysis A
(`meta/history/loop-stage2a-results.md`) showed that the implementer reaches green in one call
in 9 of 10 real cycles; the person's time goes to go-aheads ("proceed", "commit"), to commands a
person must start (`/review`, `/verify`), and to late judgments. A retry loop would rarely run.

The maintainer's goal (2026-10-08): once a person approves, the work runs **without stopping**,
review included, and stops only where a machine-checked guardrail says a person must decide —
not a black box. Calibration (2026-10-12): the harness should let people develop quickly; some
changes may slip through to the final review, but serious security risks, serious functional
bugs and destructive operations must never be missed. Main users will likely be on Standard
seats: no new settings to learn, and per-cycle tokens kept flat.

## Decision

Stage 3 is redefined as the **non-stop stretch** (`meta/design/nonstop-goal.md`):

1. **Scope** — from Gate 4 approval to the completion report, inside a person-started `/tdd`.
   People still decide the spec (Gates 0–3), the tests (Gate 4) and the final report. Merge stays
   human. Moving the start to spec approval waits until a machine check is shown, with numbers,
   to replace Gate 4.
2. **S7 — stop on risky changes after Green** (`meta/design/s7-user-facing-stop.md`):
   `tdd-snapshot.sh mark-green` / `verify-green` stop on permission, destructive, security,
   secret, outside-effect, dependency and integrity changes made after Green, and list the other
   user-facing changes for the final review. Deterministic, 0 tokens.
3. **Cycle review** (`meta/design/cycle-reviewer.md`): a findings-only sub-agent
   (`cycle-reviewer`, Read / Grep / Glob) that `/tdd` runs after Green, skipped for small
   changes. Findings that need a judgment (spec conflict, security, user-facing change, suspect
   instruction, any HIGH) stop the stretch; DEFECT / DOMAIN_BOUNDARY findings are fixed **once**,
   followed by the full suite and S7.
4. **No new concepts for users** — no switch or setting; what can be found automatically is
   (e.g. the project's own role predicates for S7).

Still to come under this ADR (gaps 3–6 of `nonstop-goal.md`): screenshots in the report
(separate session), chaining the remaining `/tdd` steps, limits for attempts and budget, a
guardrail regression suite, and a pilot on a real project.

**2026-10-13 — chaining and limits (gap 4, `meta/design/stretch-chaining-limits.md`).**
`/tdd` no longer waits between steps from Gate 4 approval to one completion report (Step 8,
judgment items first; in `lite` it carries the commit and merge plan). S5 and S9 are now
machine checks in `agent-guard.sh`: per Gate 4 approval, a third `tdd-implementer` run and
implementer writes / commands past 60 are refused (about twice the observed maximum of 2 runs
and 34 calls). Time and tokens are not limited — a hook cannot see them. 0 tokens, no setting.

## Rationale

- Removing go-aheads saves more of the person's time than retries would (analysis A).
- Guardrails that must hold are machine checks (S1–S3, S7); judgment stays with people (D5).
- A sub-agent needs nothing installed and adds no script; the risky part after the fix is still
  decided by a script (S7).

### Rejected alternatives

- **Bounded Green retry loop (ADR-0016 Stage 3 as drafted)** — would rarely fire.
- **Stage 2b human A/B** — answers a question the new goal does not ask (ADR-0017 follow-up).
- **Headless `claude -p` reviewer script** — needs the CLI on PATH and one more script and test;
  its extra (script-side cite-check and route) is kept as written rules for now.

## Consequences

### Benefits
- The person is asked at Gate 4, on a stop condition, and once at the end — not after every step.
- The one rule that failed in practice (user-facing change without approval) is now backed by a
  machine for the cases that matter most.

### Drawbacks / Risks
- Pattern-based S7 can miss a permission change written without the usual words; the reviewer
  and the final review cover it, without a guarantee.
- The cycle review's route is applied by the main session from written rules; watch for dropped
  or misrouted findings in the pilot.
- ≈ $0.3 and 1–2 minutes per reviewed cycle.

## Related
- ADR-0009 (`/review` stays person-started; note added), ADR-0016 (Stage 1 and the original
  roadmap), ADR-0017 (Stage 2a and the follow-up that skipped 2b)
- `meta/design/nonstop-goal.md`, `s7-user-facing-stop.md`, `cycle-reviewer.md`,
  `loop-reviewer-design.md`, `reviewer-input-and-residuals.md`
