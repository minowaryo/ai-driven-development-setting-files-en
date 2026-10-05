# Gate Contract (draft)

> Template-internal design note (class X). Written 2026-10-03 so that two efforts build one
> script instead of two: the merge-time diff check proposed for `prepare-merge`'s self-check
> (backlog B12 in `template-improvement-directions.md`) and the Stage 2 `gate.sh` of Loop Engineering
> (`loop-stage2-experiment-protocol.md`). The first version may ship as the merge-time check;
> Stage 2 reuses it unchanged. Changing this contract needs an update here first.

## One script, two scopes

`gate.sh --scope cycle|branch [--base <ref>] [--evidence <path>]`

| Scope | Used by | Diff examined | Typical checks |
|---|---|---|---|
| `cycle` | `/tdd` Green/Refactor, the Stage 3 loop, Stage 2 runs | Changes since the approved Red state | Approved-snapshot comparison: `diff -r` of `tests/` + `docs/product/` against the Gate 4 copy in `$(git rev-parse --git-path claude-tdd)/approved/` (ADR-0016 item 5), Pest (strict flags, JUnit), `pint --test` on non-locked paths, PHPStan if installed, Domain Boundary check |
| `branch` | `prepare-merge` self-check, `/review` Step 0 input | `--base` (default `main`, or `REVIEW_SCORE_BASE_BRANCH`) .. working tree | Everything in `cycle` that applies, plus: edits to already-run migrations, dangerous migration operations without an ADR (`.claude/rules/20-mysql.md`), secrets or `.env` values in the diff, `app/` changed without a Feature Test change, `composer audit` |

## Exit codes

| Code | Meaning | Who acts |
|---|---|---|
| 0 | PASS — every required check passed | Continue |
| 1 | FAIL — a check failed that the implementer may fix | Implementer (or the loop's next attempt) |
| 2 | LOCK_VIOLATION — locked paths changed, or tampering detected (special-casing, test config) | A person, always; never retried automatically |
| 3 | TOOL_ERROR — a required tool is missing or crashed; does not count as an implementer attempt | A person fixes the environment |

Rules: a required check that cannot run is **3, never 0** (fail closed). A check that is not
configured for the project (e.g. PHPStan not installed) is reported as `SKIP` in the evidence
and does not change the exit code, but `SKIP` of a check the project marks as required is 3.
The existing `domain-boundary-check.sh` "skipping" on a missing base branch is treated as 3
under this contract.

## Evidence file

Written to `--evidence` (default `$(git rev-parse --git-path claude-gate)/<timestamp>.json`,
inside `.git/`, never committed). One JSON object:

```json
{"gate_version":"1","scope":"cycle|branch","head":"<sha>","base":"<ref>","dirty":true,
 "approved_snapshot":{"match":true,"changed_files":["<path>"]},
 "checks":[{"id":"pest","cmd":"…","exit":0,"status":"PASS|FAIL|WARN|SKIP|ERROR",
            "duration_ms":0,"summary":"≤ 3 lines","artifact":"<path to JUnit/JSON output>"}],
 "result":"PASS|FAIL|LOCK_VIOLATION|TOOL_ERROR","cc_version":"…"}
```

- `summary` is factual (failing test ids, expected vs. got, first error line), because the
  Stage 3 loop passes it to the implementer and imperative text is refused as injected
  instructions (Stage 3 design, Problem 1).
- No file contents, secrets or personal data in the evidence.
- JSON is produced without `jq` (bash builtins / `php -r` only when PHP is available).

## Constraints

- No new runtime dependency: Bash + POSIX tools + Git; project tools only if installed.
- Auto-fixers (`pint`) run only on non-locked paths, and only before the checks; a fixer that
  touches a locked path is a LOCK_VIOLATION.
- Formatting of test files happens at the end of Red, before the Gate 4 snapshot is taken —
  never after (otherwise the snapshot comparison reports a false violation).
- The snapshot comparison reads files directly (`diff -r`), never through git, so git
  filters or the index cannot change its result. `changed_files` lists paths only (modified,
  added or deleted), never contents.
- Deterministic: no AI calls inside the gate.

## Test-to-use-case mapping convention (used by the gate, reviewer and traceability)

Every Feature test declares its use case with a Pest group: `->group('UC-006')`; tests for a
specific acceptance criterion add its id: `->group('UC-006', 'AC-012')`. IDs use the formats
of `docs/product/use-cases.md` (`UC-NNN`) and `docs/product/acceptance-criteria.md`
(`AC-NNN`). `test-writer` writes the groups; `regenerate-traceability` and the reviewer read
them (`grep` for `->group(`). Adoption is a separate template change (backlog B11 in
`template-improvement-directions.md`).
