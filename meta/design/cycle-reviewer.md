# Cycle Reviewer in the Non-stop Stretch (design)

> Template-internal design note (class X). Drafted 2026-10-12 as gap 2 of `nonstop-goal.md`;
> revised the same day to the sub-agent form the maintainer chose. Builds on
> `loop-reviewer-design.md` (R0) and `reviewer-input-and-residuals.md`. Decision: ADR-0019.
> [U] = not verified.

## What it replaces

Today a person runs `/tdd`, then `/review`, then asks for the HIGH / MEDIUM findings to be
fixed. The cycle review does the review and the routine fixes inside `/tdd`; the person is
asked only when a finding needs a judgment. `/review` stays as the person-started, wider review
(ADR-0009); `prepare-merge` still asks for it on sensitive paths.

## Form: a sub-agent, nothing to set up

- `.claude/agents/cycle-reviewer.md` — tools Read, Grep, Glob; `model: sonnet` (the model
  measured in Stage 2a, and cheaper than an Opus main session). It finds; it never approves,
  fixes or runs code.
- `/tdd` (after the Green confirmation) decides whether to run it, gives it the input, applies
  the route and does the one fix round.
- No setting, no switch, nothing the user starts or learns. No external CLI and no new script
  or test file. Rejected: a headless `claude -p` script (needs the CLI on PATH [U for VS Code
  users], and one more script and test to maintain); its only extra was a script-side
  cite-check and route, which here are short fixed rules in `/tdd`.

## Flow

| Step | Rule |
|---|---|
| Skip | Fewer than 20 changed application lines and no file under `resources/`, `lang/`, `routes/`, `database/migrations/`, `app/Policies/`, `app/Http/` — "Cycle review skipped: small change" |
| Input | UC ids from the cycle's tests; `git diff HEAD` of application paths in `<untrusted_diff>` tags; names of untracked files. Never the implementer's report or the main session's reasoning |
| Cite-check | A finding whose quoted line is not near the cited lines is dropped, and the count is said |
| Stop | Any `SECURITY` or `SUSPECT_INSTRUCTION`; a `SPEC_CONFLICT` / `USER_FACING_CHANGE` of MEDIUM or HIGH; any `HIGH` — shown as written. LOW spec conflicts (e.g. a message worded differently) are listed instead |
| Fix round | `DEFECT` / `DOMAIN_BOUNDARY` (MEDIUM / LOW) fixed once, tests and specs untouched; then the full suite and `verify-green` (S7) |
| Left for the person | `TEST_GAP` (tests are locked) and anything not fixed — in the Step 8 summary |
| Unavailable | No `END` line → "Cycle review unavailable — please run `/review` before merging" |

HIGH stops because the maintainer's calibration is "never miss a serious functional bug", and
the 2026-09-10 failure was a HIGH fix applied without asking.

## Honest limits

- The route and the cite-check are applied by the main session from written rules, not by a
  script; a script decides the risky part after the fix (S7 `verify-green`). If findings start
  to be dropped or misrouted, move these two rules into a script.
- The two residual hints are instructions to the reviewer here (search for a repeated rule; check
  a new screen flag is read), not deterministic lookups as in the lab; they were fitted to two
  cases (`reviewer-input-and-residuals.md`).
- Precision and recall were measured with R0 under `claude -p`, not as a sub-agent [U]. The lab
  re-check below compares the two.

## Lab check (2026-10-13, ≈ $2.4)

The sub-agent form on the four Stage 2a replays (Sonnet 5.5 main session and reviewer,
review and route only):

| Replay | Main findings | Route (rule as first written) | Route (rule as now) |
|---|---|---|---|
| t1 | 404 message differs from the UC (SPEC_CONFLICT, LOW) | Stop | No stop — listed |
| t2 | NULL section passes the 403 (DEFECT, MEDIUM); inline role check (DOMAIN_BOUNDARY, LOW) | Fix | — (re-runs: no findings; see below) |
| t3 | **Edit button still on the old rule** (`canEdit`, SPEC_CONFLICT, MEDIUM) | Stop | Stop |
| t4 | **New `can_edit` flag never read** (DEFECT, MEDIUM); 403 message (SPEC_CONFLICT, LOW); SectionHead-who-is-trainer denied delete (DEFECT, LOW) | Stop | Fix (the Policy fix then stops in S7) |

- Both screen-side residuals were found again (t3, t4), as with R0 under `claude -p`; no finding
  was dropped by the cite-check; every run ended with `END`.
- Two changes came from this check: LOW spec conflicts / user-facing changes no longer stop (t1
  and t4 stopped on a message wording — too often for the calibration), and a bug that lets a
  user see or do what their role should not is `SECURITY`, so it stops instead of being fixed
  silently.
- t2 was run twice more after the second change: no findings either time; the second run
  checked that `employees.section_id` is NOT NULL in its migration and left the NULL case as
  not verified — so the first run's MEDIUM finding was most likely invalid. Run-to-run variation
  is real; one run per cycle is what the stretch can afford.
- Cost $0.25–0.49 per review (the main session's share — collecting the diff, checking quotes —
  is included), 50–65 s.

## Cost

≈ $0.3 per reviewed cycle on a real project (R0 with spec slicing), 1–2 minutes; small cycles
are skipped. It replaces the per-cycle `/review` a person asks for today, which reads the
guidelines and the whole branch, so the net change is about zero or lower for people who review
every cycle.
