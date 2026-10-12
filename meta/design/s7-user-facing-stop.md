# S7 — Stop on a Risky Change After Green (design draft)

> Template-internal design note (class X). Drafted 2026-10-12 as gap 1 of
> `nonstop-goal.md`; adjusted the same day to the maintainer's calibration below. Nothing here
> is built. [U] = not verified.

## Calibration (maintainer, 2026-10-12)

The harness should let people develop quickly: the stretch should rarely stop. Some changes may
slip through to the final review, **as long as serious security risks, serious functional bugs
and destructive operations are never missed**. So: stop only on those; list everything else for
the person's single final review.

## Problem

"Any change that materially alters how the app behaves for its users must be approved by a
human" (`.claude/rules/00-global.md`) is enforced only by the prompt. It failed on 2026-09-10:
after `/review`, the AI changed who may edit an employee (FormRequest + Controller) without
asking. In the non-stop stretch nobody reads each step.

## Where it can happen

Green is bounded by the Gate 4 tests (S1, S2). The fix round (reviewer findings) and Refactor
are not covered by any approved test — the check guards the code changed **after Green**.

## Proposal

When Step 4's checks pass, record the application files (a copy next to the approved snapshot).
After the fix round and after Refactor, compare against it and sort each changed file:

| Class | What | Default detection (deterministic) | Action |
|---|---|---|---|
| **Stop** — permissions | Who may do what | changed `app/Policies/**`, `app/Http/Middleware/**`, `routes/**`; added lines with `authorize(`, `Gate::`, `->can(`, `abort(403`, a role predicate (`->isAdmin(`, `->hasRole(` …) or a `->role ===` comparison anywhere in the watched files | Exit 2, one line per file; the person decides |
| **Stop** — destructive | Data loss or schema | changed `database/migrations/**`; added lines with `delete(`, `forceDelete(`, `truncate(`, `DB::statement` | Exit 2 |
| **Stop** — security | Exposure | changed `config/auth.php`, `config/session.php`, `bootstrap/app.php` (CSRF exclusions and middleware live there since Laravel 11); added `v-html`, `{!!`, `whereRaw` / `DB::raw`, `$guarded = []`, `#[Unguarded]`, `makeVisible(`; a removed line in a `$hidden` list | Exit 2 |
| **Stop** — secrets | Credentials in the code | a changed `.env*` file other than `.env.example`; added lines that look like a key or password assignment (`(api_?key\|secret\|token\|password)\s*[=:]\s*['"][^'"]{8,}`) | Exit 2 |
| **Stop** — outside effects | Real mail, requests or scheduled runs | added `Http::`, `Mail::`, `Notification::`, `->notify(`, `Schedule::`; changed `routes/console.php`, `app/Console/**`, `app/Jobs/**` | Exit 2 |
| **Stop** — dependencies | New code from outside | changed `composer.json`, `composer.lock`, `package.json`, `package-lock.json` | Exit 2 |
| **Stop** — integrity | Data left half-written | a removed line with `DB::transaction`, `lockForUpdate(` or `sharedLock(` | Exit 2 |
| **List** — everything user-facing | Screens, wording, validation, responses | changed `resources/js/**`, `resources/views/**`, `lang/**`, `app/Http/Requests/**`, `app/Http/Controllers/**` | Exit 0; listed under "Changed after Green" in the completion report, next to the screenshots |

Why the last four (added 2026-10-12): a leaked secret cannot be taken back; outside effects
reach real people or run unattended at scale; a new dependency brings code nobody reviewed; a
removed transaction or lock corrupts data silently. None of them shows up as a failing test.

Serious functional bugs are covered by the other stops: the full suite must still pass with the
same test count, and a reviewer HIGH routes BLOCKING (S6).

The 2026-09-10 change stops: replayed on a copy of the project (2026-10-12), its three
`->isAdmin()` checks in the FormRequest and Controller print `STOP permissions`. A first version
that looked only for `authorize(` / `Gate::` let it through (both files only LISTED), so the role
predicates of `domain-boundary-check.sh` were added, extendable per project with
`TDD_GREEN_ROLE_PREDICATES`. A label or validation tweak does not stop; it shows in the final report.

## Honest limits

- Pattern-based: a permission or destructive change written without these tokens (e.g. a
  hand-rolled role comparison in a Service) passes the stop and relies on the reviewer
  (probabilistic) and on the final review.
- A mass `update` without `where` is not detected: `$model->update([...])` on one record is
  normal Service code, so a line pattern would stop most cycles. Left to the reviewer.
- Files git ignores (e.g. generated route helpers) are skipped.
- The threat is a mistake by the main session, not tampering (the copy is locked only for
  `tdd-implementer`).

## Cost and where it runs

Inside `/tdd` only (the Green copy is the reference; outside `/tdd` there is none). The merge
plan already asks about sensitive paths (`review-score.sh`). Deterministic, bash + git, 0 tokens,
≈ 2.6 s each on a real project (206 application files, Git Bash on Windows); two subcommands of `tdd-snapshot.sh` (`mark-green`, `verify-green`) with cases added to
its existing test file — no new script, no new test file. Most cycles: no stop, one extra list
in the report.

## Decisions (resolved by the calibration)

1. Controllers: listed, not a stop; permission-like lines inside them stop.
2. Runs in `/tdd` only.
3. User-facing changes other than permissions / destructive / security pass without a person
   and are listed for the final review.
