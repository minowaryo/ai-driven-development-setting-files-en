# ADR-0010: Domain Boundary Stated as an Enumerated Contract, with Deterministic Detection

## Status
Accepted

## Date
2026-09-14

## Context

Every rule file in this harness prohibits Fat Controllers — `.claude/rules/10-laravel.md`,
`docs/ai-context/module-map.md`, `.claude/rules/50-review.md`, `.claude/commands/review.md`,
and `.claude/agents/tdd-implementer.md` all say so. All of them said it as an abstract label
("Keep it thin (Fat Controller is prohibited)"), which gives an LLM no criterion to check
its own output against. `meta/adr/ADR-0003-auth-strategy.md` had already identified the
same failure mode for authorization and fixed it structurally, by mandating Policy/Gate and
prohibiting direct role checks.

Measurement on a real project confirmed the label is not enough. A Laravel project that
**already uses this harness** (its `.claude/rules/10-laravel.md` contains "Do not call `DB::`
directly" at line 9 and "**Always use Policy / Gate** (manual checks are prohibited)" at
line 41) was scanned across its 21 Controllers:

- `DB::transaction(...)` called directly in a Controller, wrapping `User::create(...)` and
  `Employee::create(...)` — three separate violations of rules the project had adopted
- hand-written nested authorization (`isAdmin()` / `isSectionHead()` / `abort(403)`) inside a
  Controller, **despite the project having 12 Policy classes already implemented**
- only 1 of 21 Controllers referenced a Service class at all
- 103 findings in total, plus Controller methods carrying 17 and 18 branches

The rules were present, the mechanism (Policies) was present, and the violations accumulated
anyway. Prose alone does not hold the boundary.

The trigger for this ADR was a proposal to adopt a MulmoClaude/MulmoTerminal-style DSL —
declaring schema, relations, permissions, and invariants so that integrity is enforced by
construction. That direction is sound but disproportionate for a repository that ships
documents and rules rather than a code-generation engine (see Rejected Alternatives).

## Decision

### 1. State the boundary as an enumerated contract

Define the **Domain Boundary** as the Service/Action layer plus the Policy layer, and record
it in `.claude/rules/10-laravel.md` as explicit MAY / MUST NOT lists rather than a label.
A Controller may only validate via `FormRequest`, call `authorize()`, call exactly one
Service/Action, and format the response. It must not call `DB::`, call Eloquent write
methods, check roles inline, or make a decision that depends on more than one entity.

The framing is deliberately "the system stays correct even when the Controller is wrong,"
not "write the Controller correctly."

"Domain Boundary" is used in preference to "model layer" because *model* means different
things per framework, and because in this template Eloquent Models stay schema-and-relations
only — enforcement belongs in Service/Action. This keeps the new contract consistent with the
existing "do not put business logic in Models" rule rather than contradicting it.

`.claude/agents/tdd-implementer.md` — the agent that actually writes implementation code, and
the real route by which `10-laravel.md` reaches the Green phase — names the contract directly.

### 2. Detect the mechanically findable half

Add `.claude/hooks/domain-boundary-check.sh`, run from `/review` Step 0 alongside
`review-score.sh`. Pure git + awk, no AI calls, one pass over the Controllers in scope.
It reports `db-access`, `eloquent-write`, and `role-check` findings, plus a per-method
branch-density heuristic. It exits 1 when it finds something so a project may gate CI or a
pre-commit hook on it; `/review` treats the output as review material rather than a failure.

## Rationale

- The enumerated contract costs nothing at runtime and nothing to maintain, and it reaches
  the code-writing agent through a path that already exists — so it takes effect on the very
  next Controller generated, with no new setup for the user.
- Detection is deterministic and local, consistent with `meta/adr/ADR-0009-review-escalation-mechanism.md`'s
  reasoning that a check runnable at zero cost should not depend on an AI call.
- Measured cost: 0.59s across 21 real Controllers; 1.1s for a 300-Controller / 44,400-line
  synthetic tree with `--audit-all`; 0.26s for a typical diff-scoped run. An earlier draft
  that filtered the file list with one `grep` process per file took 15.8s for the same 300
  Controllers on Windows/Git Bash — the list is now filtered in a single pass, and that
  constraint (avoid per-file process spawns) is why the script is written the way it is.

### Rejected alternatives

- **A full DSL plus parser/compiler (the MulmoClaude/MulmoTerminal shape)**: the strongest
  form of the idea, and the only one that prevents violations by construction rather than
  detecting them afterwards. Rejected for now because this repository ships documents and
  rules, not a code-generation toolchain; building and maintaining a grammar, a parser, and
  CI integration is a separate project. Revisit if a downstream project needs machine-enforced
  schema/permission generation.
- **An invariant declaration loop** (declare invariants in `data-model.md` → require Red-phase
  test coverage → approve at Gate 4): **deferred, not rejected.** Its value — cross-session
  memory of business rules, which is exactly what erodes when features are added months later —
  is real, but the cost recurs on every change while the benefit arrives much later, and it has
  a structural hole: a test forces a behavior to *exist* but not to *live in a particular layer*,
  since a Feature Test through HTTP passes whether the check sits in the Controller or the
  Service. Closing that requires additionally mandating Unit Tests against the Service/Action,
  which collides with `.claude/rules/30-testing.md`'s Feature-Test-first priority and its CRUD
  restraint rule. Revisit once a project has accumulated genuine cross-entity invariants; the
  analysis is recorded here so it is not silently repeated.
- **A new always-read rule file (`05-architecture.md`)**: rejected. It would grow the reading
  surface for every session, and `10-laravel.md` is already on the path that reaches
  implementation.
- **Merging the check into `review-score.sh`**: rejected. That script has one documented job —
  score the diff to pick review depth — and mixing a pattern lint into it would muddy that
  contract and make the two independently untunable.
- **A Repository layer**: rejected, contradicts `.claude/rules/20-mysql.md`, which commits to
  using the Eloquent Builder directly.

## Consequences

### Benefits

- The prohibition becomes checkable by the AI, by the script, and by a human reviewer.
- `--stats` yields a trendable number (findings, heuristic warnings), which is the only
  quantitative read on whether the boundary is holding.
- Adoption requires no new command: `/review` Step 0 already exists.

### Drawbacks / Risks — known limitations

Stated plainly, in keeping with the disclosure in `ADR-0008-tdd-e2e-harness-tooling.md` that
this harness's sub-agent split "is not a hard enforcement mechanism":

- **This detects; it does not prevent.** Nothing here stops violating code from being written.
- **The archetypal violation is invisible to it.** A cross-entity decision in plain PHP —
  `if ($order->items->sum('qty') > $product->stock) { ... }` — contains no distinctive token.
  The branch-density heuristic is a crude proxy for this case, not a detector. A clean run is
  not evidence of a clean Controller.
- **"Exactly one Service/Action" is a counting rule** that pattern matching cannot express.
- **Scope holes**: logic moved into a base Controller, a trait, or a route closure falls
  outside the Controller path glob; `merge-base` scoping means pre-existing Controllers are
  never examined unless `--audit-all` is run deliberately.
- **Path assumption**: the default glob is `app/Http/Controllers/`. A modular or DDD layout
  that does not add its own path will be scanned as zero files and reported clean — a false
  sense of safety, called out in the script's own comments.
- **Brownfield adoption surfaces a backlog**, not a blocker: the real project measured above
  produced 103 findings on a full audit. Day-to-day diff-scoped runs stay small.
- **Tuning is expected**: thresholds, path globs, and the three rule groups are all
  environment variables, and a small project that deliberately has no Service layer can turn
  the persistence group off.
- **`.claude/hooks/` is a naming convention in this repository, not a registered Claude Code
  lifecycle hook** — there is no `.claude/settings.json` wiring it. The scripts there are
  invoked explicitly by `/review`.

## Related
- `meta/adr/ADR-0003-auth-strategy.md` — the same structural move, for authorization
- `meta/adr/ADR-0008-tdd-e2e-harness-tooling.md` — precedent for disclosing enforcement limits
- `meta/adr/ADR-0009-review-escalation-mechanism.md` — the deterministic, AI-free check precedent
- `.claude/rules/10-laravel.md`
- `.claude/hooks/domain-boundary-check.sh`
- `.claude/commands/review.md`
