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
  every block is paired with an after-the-fact check (e.g. `tests/` compared with the
  index staged at Gate 4 approval).
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
| B3 | `/tdd` Refactor runs `pint` before the AI's own refactoring | D1 | S | Changes `/tdd` steps |
| B4 | `/review` Step 0 also collects Larastan / `composer audit` output | D1, D6 | S | Extends ADR-0009 Step 0 |
| B5 | Rule-enforcement inventory (which costly rules are prompt-only) | D2 | M | Produces the list for later items |
| B6 | `Read` deny for `.env*`, `docs/credentials/**`, `storage/logs/**` in `settings.json` | D10 | S | Supplement only; check impact on legitimate reads |
| B7 | Platform-fact register: verified Claude Code version per fact, re-check on upgrade | D9 | S | Could live in `meta/design/` |
| B8 | Eval cases for new behavior (test lock, `disable-model-invocation`) | D7 | S | `.claude/evals/` |
| B9 | Domain Boundary backlog fixed item by item (finder → LLM → check) as a standard procedure | D1 | M | Candidate Stage 2 experiment task |

| B10 | `domain-boundary-check.sh` gaps: flag a Controller action with no `authorize()` / `can:` middleware even without an inline role check, and flag `$guarded = []` | D1, D2 | S | Found while designing Stage 2a reviewer seeds (M2, M3) |

| B11 | Pest group convention `->group('UC-NNN'[, 'AC-NNN'])` in `test-writer`, read by `regenerate-traceability` and the reviewer | D1, D6 | S | Format fixed in `gate-contract.md`; does not touch Stage 1 files |
| B12 | Merge-time diff check (`gate.sh --scope branch`) called from `prepare-merge`'s self-check | D1, D6 | M | Must follow `gate-contract.md` so Stage 2 reuses it |
| B13 | `/tdd`: `pint --dirty` on non-locked paths, `npm run build` when frontend files changed | D1 | S | After Stage 1 (same file `tdd.md`); test files formatted before the Gate 4 hash |

Order of attack: B1 → (ADR-0016 Stage 1) → B5 → B7 → B2/B3/B4 → B6/B8 → B9.
