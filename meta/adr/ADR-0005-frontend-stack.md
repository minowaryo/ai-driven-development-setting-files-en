# ADR-0005: Frontend Technology Selection Policy (a Selection Framework Within the PHP/Laravel Ecosystem)

## Status
Accepted

## Date
2026-04-12

## Context

This repository is a template reused across multiple Laravel projects.
Team skill sets, the richness of UI requirements, and the need for API reuse (e.g. mobile app integration) vary by project,
so fixing the frontend technology to a single stack would force a choice that doesn't fit every project's characteristics.

For that reason, instead of settling on one fixed stack for all projects, this template adopts the policy of **giving each project the flexibility, at project kickoff (Gate 0), to select the frontend technology that best fits it from within the PHP/Laravel technology range.**

The options under consideration are:

1. **Blade** (Laravel's standard templating)
2. **Livewire** (server-driven reactive UI)
3. **Vue 3 + Inertia.js + Pinia** (server-driven, no separate API)
4. **React + Inertia.js**
5. **Vue 3 / React SPA + Laravel API** (API-separated)

## Decision

**Do not fix all projects to a single frontend stack.**
At project kickoff, select from within the PHP/Laravel technology range using the selection criteria and comparison table below, and record the selection and its rationale in that project's own ADR (e.g. `docs/adr/ADR-XXXX-frontend-stack-selection.md`)
(this corresponds to the "Frontend technology decision (library change, etc.)" row in `.claude/rules/60-docs.md`).

Absent a strong reason otherwise, the default recommendation is **Vue 3 + Inertia.js + Pinia** (see Rationale for why).

### Comparing the options

| Option | Good fit when | Watch out for |
|---|---|---|
| Blade | Mostly simple CRUD, no need for SPA-like interactivity, want the fastest possible start, team is unfamiliar with JS | Not a good fit for rich UI/UX |
| Livewire | Want a reactive UI without dedicating (or wanting to minimize) a JS frontend specialist | Not a good fit for large-scale or complex client-side state management |
| **Vue 3 + Inertia.js + Pinia** (default recommendation) | Need SPA-like UX and want to avoid the cost of designing and operating a separate REST API | Has Inertia-specific constraints such as not using Vue Router (`.claude/rules/15-frontend.md`) |
| React + Inertia.js | Team has many React-experienced developers, want to reuse existing React assets/design system | `.claude/rules/15-frontend.md` needs to be rewritten for React (the Vue-oriented content can't be used as-is) |
| Vue/React SPA + Laravel API | Need to separate the API for mobile app or external partner integration, want to operate frontend and backend as separate teams/repositories | Higher operational overhead than an Inertia setup — authentication, CORS, API versioning, etc. |

### Selection criteria

At project kickoff, check the following against the comparison table and select accordingly.

- Team skill set (JS experience, and whether that experience is with Vue or React)
- Richness of UI requirements (is SPA-like interactivity required?)
- Need for API reuse (will the same API be reused for a mobile app or external partner integration?)
- Development speed / maintenance cost (is there a dedicated frontend developer, team size)
- Whether authentication/authorization should be centralized on the Laravel side (Sanctum / Policy) — easy with an Inertia setup

### Selection process

The selection is carried out as a required step of Gate 0 (`CLAUDE.md`'s Gate 0 Step 1a/1b/1c). Summary:

1. **Select**: decide the frontend technology based on the selection criteria above, and record it with the `/adr` command as
   `docs/adr/ADR-XXXX-frontend-stack-selection.md`
   (if you choose anything other than the default recommendation — Vue 3 + Inertia.js + Pinia — or are torn between candidates, document the reasoning and the rejected options)
2. **Reflect into the rule file**: rewrite `.claude/rules/15-frontend.md` to match the selected stack
   (if Vue 3 + Inertia.js + Pinia was selected, the default content can be used as-is)
3. **Reflect into ai-context**: reflect the selection in the tech-stack table of `docs/ai-context/project-summary.md`
   and the Frontend section of `docs/ai-context/module-map.md`

See `CLAUDE.md`'s Gate 0 Step 1 for the detailed procedure.

## Rationale (default recommendation: Vue 3 + Inertia.js + Pinia)

### Why Inertia.js
- Can reuse Laravel's Controllers, Routes, and Middleware as-is, eliminating the cost of designing and maintaining a separate REST API
- Authentication/authorization (Sanctum / Policy) can stay centralized on the Laravel side
- Lower operational overhead than a separated SPA/API, given the team size and maintenance cost

### Why Vue 3
- Composition API + `<script setup>` gives high logic reusability and strong TypeScript affinity
- Widely adopted in the Laravel community (e.g. Laravel Breeze's Vue option)
- Compared to React, its template syntax is closer to Laravel Blade, lowering the learning curve

### Why Pinia
- The officially recommended state management library for Vue 3
- More type-safe with less boilerplate compared to Vuex

## Consequences

- Each project records its selected frontend technology in `docs/ai-context/project-summary.md`
- `.claude/rules/15-frontend.md` is treated as the "canonical" file whose name and reference path never change regardless of which stack is selected.
  Projects that select Vue 3 + Inertia.js + Pinia follow its default content as-is (the layout under `resources/js/`, not using Vue Router, etc.)
- Projects that select a non-Vue stack (Blade / Livewire / React / SPA) rewrite the content of `.claude/rules/15-frontend.md`
  for that stack (reference tables in `CLAUDE.md` and elsewhere don't need updating, since the file name doesn't change)
- Even when the default recommendation (Vue 3 + Inertia.js + Pinia) is chosen, it's recommended to leave a brief note of the rationale in the project's `docs/ai-context/project-summary.md`, as a record that the selection was made explicitly rather than assumed
