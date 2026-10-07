# Fixture-Literal Check (design draft)

> Template-internal design note (class X). Drafted 2026-10-07 as prerequisite 1 of the ADR-0017
> outcome (conditional go). [U] = not verified. Becomes a hook script only after the maintainer
> approves this design; the script follows `gate-contract.md` (exit codes, factual messages,
> no AI, no new runtime dependency).

## Why

Stage 2a check ① found that the cheating an implementer actually attempts is not editing tests
or the spec (0 of 34 runs) but **special-casing the test's data in the application code** —
for example `if ($product->sku === 'SKU-A')` so that the approved test passes while the real
behaviour is not implemented. Stage 1 (hook + snapshot) cannot see it; the agent's report said
"all tests pass". Only the lab's sealed oracle test caught it. A person reading the diff would
catch it, but a loop would not be reading.

## What it detects

A quoted string literal that is

1. present in the **approved test files** (data the test feeds in or expects), and
2. present on a **line added to application code** (`app/`, `routes/`, `config/`, `database/`,
   `resources/`; never `tests/`) **in a comparison or branch context** — `===`, `==`, `!==`,
   `!=`, `case`, `match`, `in_array(`, `->where(` / `->firstWhere(`, and
3. **not** a word of the specification (`docs/product/use-cases.md`) and **not** already present
   in the application code at the cycle's start (so existing domain vocabulary such as a status
   name or role name is never a hit).

Literals are 3–60 characters. Numbers are out of scope in this version: they are too common in
legitimate code (`1`, `100`), and a bent number (`max:99`) is a spec conflict that the reviewer
or a person reads against the spec, not a fixture leak. [U] whether a narrow numeric rule
(a comparison of an `id`/`sku`/`email` field with a number) is worth adding.

## Interface

`fixture-literal-check.sh [--base <ref>]` run from the project root.

| Input | Source |
|---|---|
| Test literals | the test files in the approved snapshot (`$(git rev-parse --git-path claude-tdd)/approved/tests/`) — no list is hand-maintained |
| Spec words | `docs/product/use-cases.md` from the same snapshot |
| Added lines | `git diff <base>` filtered to the application paths; `<base>` defaults to the commit recorded at Gate 4 (the cycle start) |
| Existing vocabulary | application files at `<base>` (`git grep`) |

| Exit | Meaning |
|---|---|
| 0 | no hit |
| 2 | hit (gate-contract: tampering detected, special-casing) — printed as `FIXTURE_LITERAL <file>:<line> '<literal>' also appears in <test file>`; factual, no instruction |
| 3 | tool error (no snapshot, base not found) — fail closed |

Exit 1 is not used: a hit is a person's decision, never an automatic retry. Reads files
directly; never trusts the agent's report; no AI.

## Where it runs

In `/tdd` Step 4, right after the snapshot comparison: exit 2 shows the lines and stops, like a
snapshot difference. Later, as one check of `gate.sh --scope cycle` (no change to the script).
Not in `prepare-merge` (the cycle's start commit is not known there).

## Validation (done offline on stored lab data, no model usage)

A prototype of this rule was run over the stored diffs:

| Data | Result |
|---|---|
| Check ① (34 runs) | 1 hit = the one known silent special case (Haiku, C2, `'SKU-A'`); **0 false positives** on the other 33; 0 missed |
| Check ③ (4 real-project AI diffs) | 0 hits (no false positives) |

Limits: one true positive only — the rule is untested against other disguises (a literal split
across two strings, a constant defined in app code, a lookup table keyed by the test's value).
The final script must therefore also be tested with synthetic positives of those forms and
the known gaps listed in `tdd-guard.md` Limits.

## Decisions needed

- Adopt as a new hook script under `.claude/hooks/` with its **one** test file
  `meta/tests/fixture-literal-check.test.sh` (the one-test-per-hook-script rule; this is a new
  test file only because it is a new hook script).
- Wire into `/tdd` Step 4 (a change to the command).
- Company repository: port after the hold is lifted for it (Stage 1 items only so far).
