# Changed Screens and Screenshots in the Merge Plan — design

> Template-internal design note (class X). Drafted 2026-10-12 as gap 3 of
> `nonstop-goal.md` ("Screenshots in the Playwright / verification step, linked from the
> report"); revised the same day over several rounds of review by the maintainer, then
> approved for implementation. [U] = not verified.

## Goal

At the end of a branch, the person judging the work sees which screens it added or changed,
and can look at them per role without launching the app. Screenshots are saved and linked,
**never read back by the model**.

Weighed against cost (main users on Standard seats): in `ihs-tech-uplift` (2026-06-24 –
10-08, 118 non-merge commits) 31 of the 46 commits touching `app/` or `routes/` also touched
screen files, and 8 added a page. Capturing every cycle would start Playwright almost every
cycle. So:

- **The changed screens are always named** — git only, 0 tokens, about a second.
- **Screenshots are taken automatically only when a page was added** (a new screen is almost
  always worth seeing). Changed screens are captured when the person asks.
- **Once per branch, in `prepare-merge`** — the merge plan is the one report the person
  approves. Not inside `/tdd` (too heavy: screens change in most cycles).
- **Direct work on `main`** needs nothing extra: `/commit` step 1 already moves code changes on
  `main` onto a branch, so they reach `prepare-merge`. A commit made outside `/commit` is not
  covered (accepted: not worth stricter rules).

## Which screens: git decides

Deliberately small: catch that a screen file changed, and stop there.

```bash
base=$(git merge-base HEAD "${REVIEW_SCORE_BASE_BRANCH:-main}")
git diff --name-status "$base" -- resources/js/Pages resources/js/pages resources/js/Components resources/js/components resources/js/Layouts resources/js/layouts resources/views
git ls-files --others --exclude-standard -- resources/js/Pages resources/js/pages resources/views
```

- `prepare-merge` runs on a branch, so the base is where the branch left the local base branch
  (not `origin/main`, which would also pick up merged but unpushed branches). `git diff <base>`
  includes uncommitted changes, and the third line adds new page files not yet in git — both
  matter because a `lite` combined run commits during the merge plan.
- A page that is `A` or untracked is a **new screen**; anything else except `D` is
  **changed**, named by its own file — a component is named as the component, not resolved to
  the pages that use it.
- The paths cover every stack the template offers (Vue / React + Inertia, upper- or lower-case
  folders [U: lower-case in Laravel's newer starter kits], Blade / Livewire), so no project
  edits them; a path that does not exist matches nothing.
- Not attempted: component-to-page resolution, roles, size of the change. No new script and no
  new `meta/tests` file.

## Screenshots (only where Playwright is set up)

Needs `playwright.config.ts` and `tests/e2e/`. Without them the screens are still named.

- **Catalog** `tests/e2e/screens.ts` (committed): one line per screen — page, UC, name, URL,
  roles. No navigation code, so UI changes do not break entries; a state that needs interaction
  (an open modal) is captured as first shown. `roles` lists only roles that see the screen
  differently. The AI adds a line for a screen with no entry when it is about to capture it.
- **Capture spec** `tests/e2e/screen-capture.spec.ts`: created once per project from the snippet
  in `e2e-testing.md`; skips itself unless `CAPTURE_SCREENS` is set, so normal runs are
  unaffected. Per (entry × role): `loginAs` → `goto(url)` → screenshot. `loginAs(page, role)` is
  one shared helper in `tests/e2e/support/`, created once.
- **Storage**: one flat, git-ignored directory `tests/e2e/.screenshots/`, emptied at the start
  of each capture. Name: `{uc}_{screen}_{role}.png`, e.g. `uc042_schedule-edit_section-head.png`.
- **Files written at merge time** (catalog lines; on first use the spec and helper) become one
  `test:` commit, shown under the screens line rather than in the commit table (maintainer,
  2026-10-12: both describe the same new screen) — only when a capture wrote them.
- **Cannot capture** (no seed record or role user, login failed, page error, server did not
  start): counted on the same line with the first reason. Nothing stops; no seeder is changed.

## In the merge plan: one line

```
Screens: new Schedules/Index (2 screenshots in tests/e2e/.screenshots/), changed Schedules/Edit, DatePicker and 3 more — say "take screenshots" to capture the changed ones.
```

- In the reply language and plain words; names shortened to the path below the folder without
  the extension; at most 5 names, then "and N more".
- No screen changed → no line. No Playwright → names only.
- On "take screenshots", the changed screens are captured and the reply lists one row per image
  (screen × role → path) — the person asked, so the longer list is wanted there.

## Cost

- Tokens: 0 for detection, capture and the line; one catalog line per newly captured screen; on
  first use, the spec and `loginAs` (≈ 2–5k, more if the E2E seeders must be read to find the
  role users [U]).
- Time [U]: every merge ≈ +1 s. A merge with a new screen: one Playwright run, ≈ 10–30 s (app
  server start, E2E seeding if configured, ≈ 1 s per image). A broken E2E environment waits for
  the server timeout (60 s in `ihs-tech-uplift`) and then reports "not captured".

## D12 check

| Criterion | Result |
|---|---|
| Recurs | Yes — every project with screens |
| Tool-neutral | The list is git only; capture uses Playwright, already the template's E2E tool (ADR-0006) |
| Cheap per session | A few lines in `prepare-merge`; the capture section of `e2e-testing.md` is read only when capturing |
| No cheaper layer | E2E specs cover critical flows only; nothing names changed screens today |
| Cheap to maintain | Prose plus one snippet; no script, no test file |

## Files changed

`docs/development/e2e-testing.md` (capture section), `.claude/skills/prepare-merge/SKILL.md`
(steps 2 and 5), `.gitignore`, `docs/ai-context/common-commands.md`,
`meta/design/nonstop-goal.md` (report item 2, gap 3), `PLAN.md`. Not changed: `/tdd`,
`/generate-e2e-test`, `/commit`, and S7's files.
