# APPLY_TEMPLATE.md — Applying This Template to a Target Repository

> **When to read this file**: before copying *any* file from this template into another
> directory. It is read by whoever performs the copy (usually an AI session running in the
> target repository and pointed at this template's path). It governs only how the harness
> files get *into* the target (Phases 0-3); from Phase 4 on, the target's own copy of
> `SETUP.md` takes over. This file itself is **not** copied into the target (class X below).

## Step A0 — Choose the path from the target's state (before copying anything)

| Target directory state | Path |
|---|---|
| Empty, or contains only `.git/` | **New-project path** — nothing can collide. Use this repository as a template exactly as `README.md`'s "Getting Started" describes (clone / "use as template"), then follow `SETUP.md`. The rest of this file does not apply. |
| Already contains files (application code, its own `README.md`, config, etc.) | **Existing-files path** — follow Phases 0-3 below, then hand off to the target's `SETUP.md` Step 0 (Phases 4-6). |

There are two separate branch points, and they answer different questions:

1. **Step A0 (this file)** — *can files collide?* Decides how to copy.
2. **`SETUP.md` Step 0 (in the target)** — *is there running application code?* Decides
   how the Gate 0-3 documents get produced. A target that has files but no real
   application code (e.g. only a `README.md`) takes the existing-files path here, then
   `SETUP.md` Step 0 routes it to the New-Project Path. A target with running code is
   routed to the Existing-Codebase Path (`/onboard-existing-codebase`).

## Principles (existing-files path)

- **Never overwrite a file that already exists in the target.** Every same-path collision
  is either a defined merge (class C) or a stop-and-ask (class E) — never a silent choice.
- **Phases 0-3 add harness files only.** They do not touch application code, and the only
  modifications allowed to pre-existing target files are the class C appends, the
  `CLAUDE.md` / `AGENTS.md` appends (class D), and whatever
  the human explicitly chose when resolving a class E collision.
- **Run Phases 0-3 non-stop.** Everything they do is additive and easy to revert (new
  files, plus marked append-only blocks in class C files), so the phases are not human
  checkpoints. Stop only when a human decision is actually needed: the Phase 0 pre-check
  fails, a class E collision is found, or a Phase 3 verification fails. Otherwise finish
  Phase 3 and give one final report. Do not chain Phase 4 (`/onboard-existing-codebase`)
  into the copy session.
- **The copy source is `git ls-files` in this template**, never a raw recursive copy of the
  directory. That automatically excludes untracked runtime and machine-specific files
  (class X) even when new ones appear later.
- The procedure ends at the final report. It suggests a commit message but never commits
  or pushes.

## File Classification

| Class | Paths | Action in the target |
|---|---|---|
| **A** — copy as-is | Every path in `git ls-files` that is not listed under R / C / D / X. Today that is: `.claude/agents/`, `.claude/commands/`, `.claude/hooks/`, `.claude/rules/`, `.claude/skills/`, `meta/adr/`, `docs/` (all of it), `SETUP.md`, `GLOBAL_CLAUDE.md`, `.mcp.json`, `.claude/settings.json` | Copy byte-for-byte when the path does not exist in the target. If it does exist → class E (except `.mcp.json` / `.claude/settings.json` → class C). A file added to this template later falls into class A automatically; if it should not be copied, list it under X. |
| **R** — copy under another name | `README.md` → `README_harness.md` | The target keeps its own `README.md` untouched. `README_harness.md` is a read-only reference copy of the harness overview; no rule in the target reads or maintains it (the target's `.claude/rules/60-docs.md` "`README.md` directory tree" row refers to the template repository's own README, not to either file in the target). If `README_harness.md` already exists → class E. |
| **C** — append-merge | `.gitignore`, `.gitattributes`; `.mcp.json` and `.claude/settings.json` only when the target already has one | Keep every existing line. Append the template's rule lines that are not already present (exact-line match) inside one marked block (format below) — comment lines and blank lines are not copied; the block header already points back here. Skip the template's own `.gitignore` entries that only make sense in this repository — today `.claude/.claude-plugin/`, `.claude/evals/`, `dist/`, `docs/handbook/`, and `docs/original-docs/*.pptx` — since in the target they could hide files it actually commits (the last one would hide its own primary sources). For `.mcp.json`, add the template's `mcpServers` entries as keys; a key that already exists → class E. For `.claude/settings.json`, add the template's `permissions` entries that are missing; an entry that contradicts the target's (e.g. the target allows what the template denies) → class E. A template line that *contradicts* an existing rule (e.g. the target already sets a different `eol` for `*.sh`) → class E. |
| **D** — create fresh | `CLAUDE.md`, `AGENTS.md`, `PLAN.md` | `CLAUDE.md`: copy the template's file, set the **Repository** line to the target's `git remote get-url origin` (or `[REPOSITORY_URL]` if there is no remote), and leave every other `[...]` placeholder for Phase 4 to fill. If the target already has a `CLAUDE.md`, keep it and append the prepared content (minus its `# CLAUDE.md` title) at the end, inside the same marked block as class C. Check in Phase 0 for instructions that contradict the template (e.g. the existing file allows autonomous commits); any contradiction → class E. `PLAN.md`: create it blank — only the `# PLAN.md` title line. Copy nothing from the template's own `PLAN.md`: its header notes (e.g. the archive range) and its entries are this template's history, not the target's. `AGENTS.md` (the Codex entry point): copy the template's file; if the target already has one, append it the same way as `CLAUDE.md`, with the same contradiction check. If `PLAN.md` already exists → class E. |
| **X** — never copy | `.git/`, `.claude/settings.local.json`, `.claude/scheduled_tasks.lock`, `.claude/evals/` and `.claude/.claude-plugin/` (the template's local-only self-eval harness), `dist/`, `docs/handbook/` and `docs/original-docs/*.pptx` (template-internal, ignored via its `.gitignore`), `APPLY_TEMPLATE.md` (this file), `meta/tests/` and `meta/history/` (tests for the template's own scripts, and the archive of its own `PLAN.md` — tracked here, never copied), and anything else not in `git ls-files` | Machine-specific settings, a live session lock, template-internal tooling, and template-side procedure. A plain recursive copy (`cp -r`) would pick these up; `git ls-files` does not. Their absence does not affect the harness: Claude Code loads `CLAUDE.md`, `.claude/` and `.mcp.json`, and recreates `settings.local.json` on its own when permissions are approved. |
| **E** — collision: stop and ask | Any class A / R / D path that already exists in the target, and any contradicting class C line or key | Stop. Show the human both versions (or a diff) and the options — keep the target's / take the template's / merge by hand — and apply only what they choose. Never resolve it by picking a side yourself. |

Class C block format (`.gitignore` / `.gitattributes`):

```
# --- AI-driven development harness (appended from template; see APPLY_TEMPLATE.md) ---
<only the template rule lines not already present in the target>
```

## Phases (existing-files path)

Run every command from the **target** repository root, with `TPL` set to this template's
path. The Bash snippets need Git Bash or WSL on Windows (same prerequisite as
`.claude/hooks/`).

### Phase 0 — Pre-check (no file writes)

1. `git status --short` must be empty in the target. If it isn't, stop — ask the human to
   commit or stash first, so the harness diff is never mixed with unrelated work.
2. `git -C "$TPL" status --short` must be empty in this template too — Phase 1 copies
   working-tree content, so uncommitted template edits would otherwise leak into the
   target. Record `git -C "$TPL" rev-parse --short HEAD` as the applied template version.
3. Note the target's default branch. `.claude/hooks/review-score.sh` and
   `domain-boundary-check.sh` default to `main`; if the target uses another name (e.g.
   `master`), `REVIEW_SCORE_BASE_BRANCH` / `DOMAIN_BOUNDARY_BASE_BRANCH` must be set when
   running them. Carry this note into the Phase 3 hand-off report so Phase 4 records it in
   `docs/ai-context/common-commands.md`.
4. Build the collision inventory:

   ```bash
   git -C "$TPL" ls-files | grep -Ev '^meta/(tests|history)/' | while read -r f; do [ -e "$f" ] && echo "EXISTS: $f"; done
   [ -e README_harness.md ] && echo "EXISTS: README_harness.md"
   ```

   Hits on `README.md` (class R), `.gitignore` / `.gitattributes` (class C),
   `.mcp.json` / `.claude/settings.json` (class C), and `CLAUDE.md` / `AGENTS.md` (class D append) are expected.
   **Every other hit is class E** — list them, along with any contradiction found in an
   existing `CLAUDE.md` or `AGENTS.md`.
   If the target already has a `.claude/`, check its existing rules and commands the same
   way — both sets get loaded, so a contradiction with the template is class E even when
   the file names differ. Existing Git conventions (e.g. squash-only merges, a `develop`
   branch, a non-`main` base) that contradict `.claude/rules/70-git.md` are class E too.
5. If the class E list is empty, continue straight to Phase 1. Otherwise **stop**: present
   each class E item and resolve all of them with the human, then continue.

### Phase 1 — Copy classes A and R

```bash
git -C "$TPL" ls-files \
  | grep -vxE 'README\.md|PLAN\.md|CLAUDE\.md|AGENTS\.md|\.gitignore|\.gitattributes|APPLY_TEMPLATE\.md|meta/(tests|history)/.*' \
  | while read -r f; do
      [ -e "$f" ] && continue   # already exists: handled in Phase 0 (class E) or Phase 2 (class C)
      mkdir -p "$(dirname "$f")" && cp "$TPL/$f" "$f"
    done
cp "$TPL/README.md" README_harness.md
```

Then apply exactly the class E resolutions the human chose in Phase 0 (the loop above
skipped those paths), and nothing more.

Check: `git status --short` shows only `??` entries, plus any `M` the human explicitly
chose in a class E resolution. Keep the list for the final report.

### Phase 2 — Class C merges and class D creation

1. Append the class C block to `.gitignore` and `.gitattributes` (and merge `.mcp.json` /
   `.claude/settings.json`
   keys if the target had its own).
2. Create `CLAUDE.md` and `AGENTS.md` (or append to existing ones) and `PLAN.md` as
   described under class D.
3. Check: `git diff` on every pre-existing file that was modified must contain only the
   appended block / added keys. Keep the diff for the final report.

### Phase 3 — Verify, then hand off

1. `git status --short` — only `??` entries, plus `M` on the class C files, on an
   appended-to `CLAUDE.md` / `AGENTS.md`, and on any
   path the human chose to change in a class E resolution. Any other `M` means something
   was overwritten: stop and report.
2. Every class A file is identical to the template (paths where a class E resolution
   kept the target's version or merged by hand are expected to show up — confirm each
   one is on the Phase 0 list; anything else is a failure):

   ```bash
   git -C "$TPL" ls-files \
     | grep -vxE 'README\.md|PLAN\.md|CLAUDE\.md|AGENTS\.md|\.gitignore|\.gitattributes|\.mcp\.json|\.claude/settings\.json|APPLY_TEMPLATE\.md|meta/(tests|history)/.*' \
     | while read -r f; do cmp -s "$TPL/$f" "$f" || echo "DIFFERS: $f"; done
   cmp -s "$TPL/README.md" README_harness.md || echo "DIFFERS: README_harness.md"
   ```

   No output = pass.
3. No copied file is silently ignored by the target's `.gitignore` (or a global
   excludes file) — an ignored file would pass step 1 yet never be committed:

   ```bash
   { git -C "$TPL" ls-files \
       | grep -vxE 'README\.md|PLAN\.md|APPLY_TEMPLATE\.md|meta/(tests|history)/.*'; \
     echo README_harness.md; echo PLAN.md; } \
     | git check-ignore --no-index --stdin
   ```

   No output = pass (paths re-included by a `!` rule, such as `docs/credentials/README.md`,
   are correctly not reported). Any hit → re-run that path with `git check-ignore -v` to
   see the rule, then stop and ask (the fix is in the target's ignore rules, a human
   decision).
4. The hook scripts run in this environment (exit 0 or 1 is fine; a shell error is not):

   ```bash
   REVIEW_SCORE_BASE_BRANCH=<default-branch> bash .claude/hooks/review-score.sh
   ```

5. **Final report**: the Phase 1 file list, the Phase 2 diffs, the results above, the
   applied template version (Phase 0 step 2), and the default-branch note (Phase 0 step 3).
   Close it with a suggested commit message only — e.g. `chore: apply AI-driven
   development harness template (<template version>)`. Committing is not part of this
   procedure.
6. **End the session here.** Phase 4 starts in a new Claude Code session, so the target's
   new `CLAUDE.md` and `.claude/` are loaded from the start.

### Phases 4-6 — continue in the target, driven by its `SETUP.md`

Not repeated here; the target's `SETUP.md` is the single source of truth from this point.

| Phase | What | Where it's defined |
|---|---|---|
| 4 | `/onboard-existing-codebase` (or, for a target without running code, the New-Project Path) | `SETUP.md` Step 0 → Existing-Codebase Path |
| 5 | Review the generated documents: resolving the Needs-confirmation list is the consolidated Gate 0-3 sign-off | `SETUP.md` Existing-Codebase Path, "Gate 0-3 for this path" |
| 6 | Development via `/tdd` (Gate 4 per feature/UC) | `SETUP.md` Step 4 |

## Out of Scope

Pulling *later* template updates into a project that already adopted the harness is a
different operation (a selective merge, judged file by file) and is not covered by this
procedure.
