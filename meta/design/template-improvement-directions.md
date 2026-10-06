# Template Improvement Directions

> Template-internal design note (class X; not copied into projects). Distills the
> perspectives that came out of the Loop Engineering evaluation (2026-10-01 – 10-03) into
> directions for improving this harness **regardless of whether a project ever runs an
> autonomous loop**. Loop-specific decisions live in `meta/adr/ADR-0016`; this note is the
> broader map. Each direction becomes real only through its own PLAN.md entry / ADR.

## The core shift

The harness so far answers "what should the AI be told?" (rules, gates, docs). The
evaluation showed the next question is "**what must not depend on the AI following what it
was told?**" — and that the answer is cheap machinery around the AI, not more prose.

## Directions

### D1. Machines do what machines can; the LLM does the rest

- **Judge side** (already started: `review-score.sh`, `domain-boundary-check.sh`, ADR-0010):
  turn prose rules into checks — Pest arch tests, Larastan, `composer audit`, strict
  Pest/PHPUnit modes (`failOnSkipped`, `failOnRisky`, …) that make weakened tests fail.
- **Change side** (new): deterministic tools make the changes they can — `pint`, Rector —
  and the LLM handles only the remainder; deterministic finders produce the work list, the
  LLM fixes item by item, a check confirms. Evidence: Google (arXiv 2504.09691), Slack
  (Enzyme → RTL hybrid, 80% vs 40–60% LLM-only).
- **Method**: for every rule or task, ask in order — can a tool *check* it? can a tool
  *do* it? only then, how should the LLM do it?

### D2. Rules that matter must not rest on prompts alone

- Prompt-only today: "`tdd-implementer` does not edit `tests/`", "commands run only when a
  human types them" (false since Claude Code treats commands as model-invocable skills).
- **Method**: list the rules whose violation would be costly; for each, name the mechanism
  that enforces it (hook, `settings.json`, frontmatter flag such as
  `disable-model-invocation`, check script) or record why prose is enough.

### D3. Make cheating useless rather than impossible

- In-process blocks can be bypassed (subprocesses; no OS sandbox on native Windows), so
  every block is paired with an after-the-fact check (e.g. `tests/` and `docs/product/`
  compared with the plain copy taken at Gate 4 approval).
- **Method**: design for the weakest supported platform; add the sandbox as a bonus where
  available (macOS / Linux / WSL2), never as the only layer.

### D4. Give the AI a legitimate way out

- Models cheat less when they may say "this cannot be done as specified" (ImpossibleBench:
  54% → 9%). SPEC_CONFLICT is the first instance.
- **Method**: wherever a rule blocks the AI, also define what it should report instead and
  who decides next (ties into the existing "user-facing behavior change needs approval" rule).

### D5. Human gates where judgment is needed, machines where checking is enough

- Gate 4 approval is often a formality in practice. A formal gate gives false comfort;
  automation bias makes an AI "APPROVE" weaken human review further.
- **Method**: replace ceremonial checks with mechanical ones, keep humans on high-risk items
  (authorization, validation, regression, user-visible behavior), and let AI reviewers
  report findings plus "not verified", never a pass verdict. Offer stricter/lighter variants
  as profiles (as `lite`/`standard` already does for Git) instead of one-size rules.

### D6. Evidence over assertion

- `verification-before-completion` already asks for an actual run. Extend it to durable
  evidence: test/JUnit results, gate outputs, denial logs — files a human or a later step
  can read, not claims in chat.

### D7. Measure before expanding

- Every addition is Trial with exit and kill criteria (ADR-0013 pattern). Metrics that
  matter: human minutes per task, rework, escaped defects, cost per merged task, blocked
  tamper attempts. Harness regressions are caught by `.claude/evals/` cases (extend them
  when behavior changes).

### D8. Adopt before building — but verify, and budget dependencies

- Check built-ins and existing tools first; then verify claims hands-on (Probity looked
  like a fit until tested: no agent awareness, no Pest syntax, ~834 MB).
- **Method**: every change states its new dependencies; a new runtime is a cost to justify.
  Default target: no new runtime beyond Bash + POSIX tools + Git + the project's own
  PHP/Composer/Node.

### D9. Track platform drift

- Claude Code changed under the harness without notice: `/review` became a bundled alias,
  commands became model-invocable, frontmatter hooks do not run under `claude -p`, Laravel
  Boost gained an MCP-only install. Each silently broke an ADR premise.
- **Method**: record the verified Claude Code version next to platform facts in ADRs; keep
  small verification fixtures (like the 2026-10-03 hook test) re-runnable; re-check the
  facts the harness depends on when Claude Code is upgraded or before porting.

### D10. Treat repository content as untrusted input

- Diffs, logs, issues and test names can carry prompt injection; reviewers that run tests
  execute the coder's code; `.env`, `docs/credentials/` and logs reach the context.
- **Method**: read-only reviewers that read evidence instead of executing; `Read` deny for
  secrets as a supplement; audit logs without file contents.

### D11. Keep the maintenance cost of three repositories and two tools in view

- EN / JP / company drift; Claude Code-only mechanisms degrade Codex users.
- **Method**: prefer language-neutral artifacts (scripts, schemas, config) that port by
  copy; prose ports by translation and drifts. Pair each Claude mechanism with its Codex
  counterpart or a tool-agnostic check (git-based). Keep always-loaded context small
  (core/detail split).

## Improvement backlog (outside ADR-0016 Stage 1)

| # | Item | Direction | Size | Note |
|---|---|---|---|---|
| B1 | State the "machines first" division of labor in `docs/development/ai-workflow.md` | D1 | XS | Done 2026-10-03 |
| B2 | Strict Pest/PHPUnit settings in the template's test guidance | D1, D3 | S | Overlaps ADR-0016 Stage 2 |
| B3 | `/tdd` Refactor runs `pint` before the AI's own refactoring | D1 | S | Superseded by B13 |
| B4 | `/review` Step 0 also collects Larastan / `composer audit` output | D1, D6 | S | Extends ADR-0009 Step 0 |
| B5 | Rule-enforcement inventory (which costly rules are prompt-only) | D2 | M | Done 2026-10-06: `meta/design/rule-enforcement-inventory.md` |
| B6 | `Read` deny for `.env*`, `docs/credentials/**`, `storage/logs/**` in `settings.json` | D10 | S | Supplement only; check impact on legitimate reads |
| B7 | Platform-fact register: verified Claude Code version per fact, re-check on upgrade | D9 | S | Could live in `meta/design/` |
| B8 | Eval cases for new behavior (test lock, `disable-model-invocation`) | D7 | S | `.claude/evals/` |
| B9 | Domain Boundary backlog fixed item by item (finder → LLM → check) as a standard procedure | D1 | M | Candidate Stage 2 experiment task |
| B10 | `domain-boundary-check.sh` gaps: flag a Controller action with no `authorize()` / `can:` middleware even without an inline role check, and flag `$guarded = []` | D1, D2 | S | Found while designing Stage 2a reviewer seeds (M2, M3) |
| B11 | Pest group convention `->group('UC-NNN'[, 'AC-NNN'])` in `test-writer`, read by `regenerate-traceability` and the reviewer | D1, D6 | S | Format fixed in `gate-contract.md`; does not touch Stage 1 files |
| B12 | Merge-time diff check (`gate.sh --scope branch`) called from `prepare-merge`'s self-check — edited run migrations, dangerous ops without an ADR, secrets / `.env`, `app/` change without `tests/Feature`, `pint --test`, `composer audit`, PHPStan if present | D1, D6 | M | Must follow `gate-contract.md` so Stage 2 reuses it |
| B13 | `/tdd`: `pint --dirty` on non-locked paths, `npm run build` when frontend files changed | D1 | S | After Stage 1 (same file `tdd.md`); test files formatted before the Gate 4 hash; own `style:` commit when it reformats unrelated lines |
| B14 | `Model::shouldBeStrict(! isProduction())` + `Http::preventStrayRequests()` in tests | D1 | XS | Done 2026-10-03 (rules + `SETUP.md` Step 4); snippets not yet run in a real Laravel app |
| B15 | `spec-lint.sh`: structure, IDs, links, placeholders, mockups, narrow word list in requirements / use-cases | D1 | S | Done 2026-10-03 |
| B16 | Doc consistency: PHPStan only where Larastan exists, raw SQL stated once, one author self-check, UC ID notation, SQLite test default, CSRF class name | D1, D11 | S | Done 2026-10-03 |
| B17 | Mutation testing of changed classes after Green (`pest --mutate --class=…`, Xdebug/PCOV); survivors go back to `test-writer` | D3, D6 | M | Stage 2 experiment candidate; cannot run before Gate 4 |
| B18 | Spec drift: report edits to `use-cases.md` since its approval commit; Approval Record in `requirements.md` / `data-model.md`; lock `docs/product/**` for the implementer | D2, D3 | S | Pairs with the Stage 1 hook |
| B19 | `acceptance-criteria.md` has no reader; `00-global.md` and `SETUP.md` list different required ai-context files | D11 | S | Needs a decision (Loop Stage 4 for AC) |
| B20 | Deferred: commit-msg hook (per clone), `Read` deny for `.env` (also blocks `.env.example` writes, leaks via subprocess), data-model ↔ schema diff (needs a DB), ESLint / gitleaks / migration linters (new deps, immature) | D1, D10 | — | Revisit on demand |

| B21 | Small doc fixes: `authz-authn.md` still names `VerifyCsrfToken`; XSS rule omits Vue `v-html`; ban `#[Unguarded]` (Laravel 13) next to `$guarded = []`; `do-not-touch.md` cites `Authenticate.php` (absent since Laravel 11) and puts all of `app/Policies/` under "ADR required", which clashes with adding a Policy per feature | D11 | XS | Done 2026-10-06 (also `#[Fillable]` accepted on Laravel 13) |
| B22 | Required ai-context files: `00-global.md` lists 2, `SETUP.md` 4 (part of B19) — Gate 0 wording, keep `00-global.md` / `SETUP.md` / `AGENTS.md` in sync | D11 | XS | Gate 0 text; no UX change |
| B23 | `review-score.sh` sensitive paths: add `routes/api.php`, `config/database.php`, `bootstrap/app.php` | D1 | XS | UX: merges touching them ask about `/review` |
| B24 | More finders for the merge-time check (B12): `float`/`double` money columns, PII-looking fields in `Log::` calls, audit channel config, code change without its doc (migrations → `data-model.md`, Policies → `authz-authn.md`), new model without CRUD Feature tests, `fix:` commit without a test, mocked DB in tests | D1, D6 | M | Fold into B12 (Loop); findings only |
| B25 | Repo hygiene checks: `PLAN.md` line count, branch name, E2E file name | D1 | XS | Dropped 2026-10-06: low effect |
| B26 | `DB::prohibitDestructiveCommands($this->app->isProduction())` in `SETUP.md` Step 4 (blocks `migrate:fresh` / `db:wipe` in production) | D1, D3 | XS | Done 2026-10-06 (also blocks production `migrate:rollback`; undo with a forward migration) |
| B27 | Larastan opt-in rules (`checkModelProperties`, `checkModelMethodVisibility`, `checkDispatchInTransactionAfterCommit`) where Larastan is installed | D1 | XS | Dropped 2026-10-06: Larastan projects only, low effect |
| B28 | Frontend greps: Options API, `target="_blank"` without `rel`, `document.querySelector`, missing `<style scoped>` | D1 | S | Dropped 2026-10-06: low risk once `v-html` is in the rules (B21) |

Order of attack: B1 → (ADR-0016 Stage 1) → B5 → B7 → B2/B3/B4 → B6/B8 → B9. Amended
2026-10-03 by the user: group 1 (B14–B16) first; group 2 (B11–B13, B17) belongs to the Loop stages.
Superseded 2026-10-06 by the priority list below.

## Priority of the open items (2026-10-06)

Weighed by effect, security, governance (rules that hold without relying on the AI or a
reviewer remembering them), groundwork for later automation (the Loop stages), and UX (what
changes for the people using the harness — an item that adds questions or waiting is ranked
down unless its security value is high). Owner: **T** = this track (loop-independent),
**L** = the Loop Engineering session.

| Priority | Item | Owner | Why | UX impact |
|---|---|---|---|---|
| P1 | B10 missing `authorize()` / `$guarded = []` in the boundary check | T | Security: broken access control and mass assignment are the top Laravel risks; small change to an existing script | More findings in `/review` and at merge — only when the code has the problem; never blocks |
| P1 | B12 merge-time diff check (+ B4) | L | Highest leverage: secrets / `.env`, edited or dangerous migrations, `composer audit`, untested `app/` changes on every merge; it is `gate.sh` v0, the base of Stages 2–3 | Findings in the merge plan, a few seconds per merge; must stay findings-only to keep merges smooth |
| P1 | B18 spec drift since approval + Gate 1 / 3 approval records | L / T | Governance: an approved spec cannot change silently; groundwork for `SPEC_CONFLICT` and Stage 4 traceability | One more line in the approval record per Gate; a drift notice only when the spec changed |
| P2 | B23 sensitive-path list | T | Governance: routing, DB and app bootstrap changes get the same merge question as migrations and Policies | One more question at merge when those files change (in `lite`) |
| P2 | B14 run `SETUP.md` Step 4 in a real Laravel app | T | Effect: confirms the strict modes catch N+1 / unfillable attributes before teams rely on them | None |
| P2 | B24 extra finders (fold into B12) | L | Security (PII in logs) and governance (audit channel, doc map) | More merge findings; FIND-type items can be noisy — keep them in the plan, never as questions |
| P2 | B11 UC tag in tests | L | Groundwork: makes requirement → test traceability scriptable (Stage 3 / 4) | Test-writer adds one `->group()` per test; humans see no change |
| P2 | B7 platform-fact register | T / L | Governance of the harness itself: Claude Code changes broke ADR premises silently; overlaps ADR-0016 item 10 | None (maintainer-facing) |
| P2 | B19 / B22 Gate 0 file set; `acceptance-criteria.md` reader | T / L | Governance: one Gate 0 definition; the AC part waits for Stage 4 | None for B22; AC part decides whether a document is still asked for |
| P2 | B13 `/tdd` Pint / build | L | Effect: machine-fixable failures stop consuming AI turns | Faster cycles; formatting may add a `style:` commit |
| P2 | B8 eval cases | L | Groundwork: regression tests for harness behavior | None |
| P2 | B17 mutation testing / B2 strict PHPUnit | L | Effect on test quality | Longer post-Green step (seconds to minutes); needs Xdebug / PCOV |
| P3 | B9 boundary backlog procedure | L | Stage 2 experiment task | None until used |
| — | B6, B20 | — | Deferred (side effects, new dependencies, per-clone setup) | `.env` read deny would block legitimate setup writes |

Next for this track: B10 (approve its extra findings first), then B23 (approve the extra
merge question first). B21 and B26 were done 2026-10-06; B25, B27 and B28 were dropped as low effect.

## Whole-cycle survey (2026-10-03)

Asked of every phase: can a tool check it, do it, or find where? Findings that shaped B11–B20:

- The spec side is regular enough for awk (UC headings, sections, F-ID links), and the
  SDD tools' own "analyze" steps are LLM prompts; the one deterministic validator (OpenSpec)
  is a heading/keyword check. LLM spec review found a median 47% of expert issues with 11%
  false flags (arXiv 2609.03230) — run deterministic checks first, LLM review as advice.
- Word-list smell detection is worth it only for four categories (Smella, arXiv 1611.08847);
  pronoun and negation checks are noise. A lint cannot catch *missing* requirements, the
  most-cited problem (NaPiRE, 48%) — that stays with the human reviewer. Late fixes cost a
  median 1.85× more for requirements issues (Menzies et al. 2016), not 100×.
- Implementation side: written quality gates (`pint --test`, PHPStan) were never run by any
  command; Laravel's built-in strict modes turn N+1 / mass-assignment slips into failing
  tests at zero cost. Lint-gated edits raised SWE-agent's resolve rate 15.0% → 18.0%
  (arXiv 2405.15793). Mutation feedback raised LLM test suites' mutation scores ~78% → ~90%
  (arXiv 2506.02954).
- Loop gaps found on the way and passed to that session: Stage 1 locked `tests/` but not the
  spec, so SPEC_CONFLICT's `grep -F` quote check could be satisfied by editing the spec (since closed: ADR-0016 locks `docs/product/` too);
  `disable-model-invocation` on every command may stop `/tdd` → `/generate-e2e-test` and
  `prepare-merge` → `/commit` hand-offs; Larastan is a new dependency, not an existing one.
