# Rule Enforcement Inventory

> Template-internal design note (`meta/design/`, class X). Backlog item B5 in
> `template-improvement-directions.md`: which rules of the implementation-and-after half of the
> cycle rest on prose alone, and which tool could check, do, or find them. Taken from the
> whole-cycle survey of 2026-10-03; "Enforced now" updated 2026-10-06. Spec-side checks are
> covered by `spec-lint.sh` (ADR-0018). Re-check this table when a rule or script changes.

Kind: **CHECK** a tool can verify it · **DO** a tool can perform it · **FIND** a tool can list
candidates for the AI / human · **LLM** judgment only · **HUMAN** decision only.

| Area | Rule (source) | Kind | Tool | Enforced now | Backlog |
|---|---|---|---|---|---|
| Model | No `$guarded = []` / `#[Unguarded]` (`10-laravel.md`) | CHECK | grep over `app/Models` | No | B10, B21 |
| Model | `$fillable` covers every filled attribute (`10-laravel.md`) | CHECK | `Model::shouldBeStrict()` throws in tests | Yes, once `SETUP.md` Step 4 is done | B14 |
| Model | Actor stamps only via the trait, not in `$fillable` (`10-laravel.md`) | FIND | grep `created_by` columns vs `HasActorStamps` | No | — |
| Controller | No `DB::`, Eloquent writes, inline role checks (`10-laravel.md`) | CHECK | `domain-boundary-check.sh` | Yes — `/review` and every merge | — |
| Controller | No decision spanning two entities (`10-laravel.md`) | LLM | — | Review only | — |
| Controller | Validation through FormRequest; `authorize()` called (`10-laravel.md`) | FIND | grep `$request->validate(` / missing `authorize` | Partly (priority files) | B10 |
| PHP | `declare(strict_types=1)` (`coding-standards.md`) | DO | Pint rule `declare_strict_types` | No | B13 |
| Style | Pint passes (`ai-workflow.md` Quality Gates) | DO + CHECK | `pint --dirty` / `pint --test` | No command runs it | B12, B13 |
| Static | PHPStan level 6+ where Larastan is installed (`ai-workflow.md`) | CHECK | Larastan (+ opt-in rules) | No command runs it | B4, B12, B27 |
| SQL | Raw SQL only with bindings; `DB::statement` / `unprepared` need an ADR (`20-mysql.md`) | CHECK | grep over `app/` | Controllers only | B12 |
| Performance | No N+1 (`10-laravel.md`, `20-mysql.md`) | CHECK | `Model::shouldBeStrict()` (lazy loading throws) | Yes, once Step 4 is done | B14 |
| Performance | Avoid `SELECT *`; run `EXPLAIN` (`20-mysql.md`) | LLM | — | Review only | — |
| DB | `utf8mb4`, collation, `strict` in `config/database.php` (`20-mysql.md`) | CHECK | grep (Laravel defaults comply) | No | — |
| DB | No `float` / `double` for money (`20-mysql.md`) | FIND | grep new migrations | No | B24 |
| DB | Never edit a migration that has run (`20-mysql.md`) | CHECK | `git diff --diff-filter=MD <base> -- database/migrations/` | No (path only scored as sensitive) | B12 |
| DB | Dangerous operations need an ADR (`20-mysql.md`) | CHECK | grep new migrations + require a new ADR in the diff | No | B12 |
| DB | NOT NULL only with a default; drop columns in stages (`20-mysql.md`) | FIND | grep | No | B12 |
| DB | Tests on MySQL, not SQLite (`30-testing.md`) | CHECK | `phpunit.xml` | Yes, once Step 4 is done (SQLite allowed as fallback) | B14 |
| Frontend | No Options API; `defineProps` form (`15-frontend.md`) | CHECK | grep `.vue` | No | B28 |
| Frontend | `<Link>` for internal links; `rel` with `target="_blank"` (`15-frontend.md`) | CHECK / FIND | grep | No | B28 |
| Frontend | No `document.querySelector`; `<style scoped>` (`15-frontend.md`) | CHECK | grep | No | B28 |
| Frontend | Build after frontend edits (`15-frontend.md`) | DO | `npm run build` when `resources/js|css` changed | No | B13 |
| Security | No secrets / `.env` in the diff (`40-security.md`) | CHECK | regex over the diff + staged file names | No | B12 |
| Security | `docs/credentials/` ignored (`40-security.md`) | CHECK | `.gitignore` | Yes | — |
| Security | No PII in logs (`40-security.md`) | FIND | grep `Log::` lines with email / name / phone | No | B24 |
| Security | Audit channel: `info` level, `LOG_AUDIT_DAYS`, fixed schema (`40-security.md`) | CHECK | grep `config/logging.php`, `.env.example` | No | B24 |
| Security | `composer audit` (`40-security.md`) | CHECK | `composer audit --locked` (needs network) | No | B4, B12 |
| Security | XSS: no `{!! !!}` / `v-html` with user input (`40-security.md`) | FIND | grep | No | B21, B28 |
| Security | Production-destructive commands blocked | CHECK | `DB::prohibitDestructiveCommands()` | No | B26 |
| Tests | Every change has a Feature Test (`30-testing.md`) | CHECK | `app/` changed but `tests/Feature/` not | No | B12 |
| Tests | Regression test for every bug fix (`30-testing.md`) | CHECK | `fix:` commit without a `tests/` change | No | B24 |
| Tests | Don't mock the DB (`30-testing.md`) | FIND | grep `DB::shouldReceive`, mocked Models | No | B24 |
| Tests | No real outbound HTTP (`30-testing.md`) | CHECK | `Http::preventStrayRequests()` | Yes, once Step 4 is done | B14 |
| Tests | CRUD coverage for a new model (`30-testing.md`) | FIND | new `create_*_table` → matching Feature tests | No | B24 |
| Tests | Implementer never edits `tests/` (`tdd-implementer.md`) | CHECK | `agent-guard.sh` + `tdd-snapshot.sh` | Yes (ADR-0016 Stage 1) | — |
| Tests | Approved tests are meaningful (Gate 4) | CHECK (after Green) | mutation testing | No | B17 |
| Git | Never implement on `main` (`70-git.md`) | CHECK | hook or pre-commit | No (prompt) | — |
| Git | Commit subject format, ≤ 72 chars (`70-git.md`) | CHECK | commit-msg regex | No | B20 |
| Git | Branch name, migration in its own commit (`git-workflow.md`) | CHECK | regex / `/commit` grouping | No | B25 |
| Git | No force push; push only on request (`70-git.md`) | CHECK | `settings.json` deny / ask | Yes | — |
| Docs | Code change X ⇒ update doc Y (`60-docs.md`) | FIND | path → doc map (migrations → `data-model.md`, Policies → `authz-authn.md`, …) | No | B24 |
| Docs | `PLAN.md` under 300 lines (`60-docs.md`) | CHECK | `wc -l` | No | B25 |
| Docs | `original-docs` read-only; do-not-touch areas (`00-global.md`, `do-not-touch.md`) | CHECK | diff path check | Partly (sensitive paths) | B23 |
| Process | Gate approvals; user-facing changes need approval (`00-global.md`) | HUMAN | — | — | — |

Where they would run: inside `php artisan test` (strict modes — no workflow change), the
`prepare-merge` self-check (B12, every merge), `/commit` (per commit), `/review` Step 0
(only when `/review` runs), Claude Code hooks (every tool call — bash builtins only), git hooks
(per clone, not versioned).
