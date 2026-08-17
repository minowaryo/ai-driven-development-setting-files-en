# 15-frontend.md — Frontend-Specific Rules

> **Purpose of this file**: the canonical home for frontend implementation rules.
> Record the implementation rules for whichever frontend stack this project selected
> via the process in `meta/adr/ADR-0005-frontend-stack.md`.
> The content below covers the default recommendation, **Vue 3 + Inertia.js + Pinia**.
> If a project selects a different stack (Blade / Livewire / React / etc.), rewrite
> this file's own content for that stack (do not rename the file or change its path).

## Assumed Versions

- **Vue**: 3.3 or later (`useTemplateRef` requires 3.5+, so default to `ref`; `useTemplateRef` is also fine on 3.5+ environments)
- **Inertia.js**: @inertiajs/vue3
- **State management**: Pinia
- **TypeScript**: optional (if used, apply the "Additional rules when using TypeScript" section at the end of this file)

---

## Architecture Guidelines

- Separate the responsibilities of Pages and Components (Inertia's `Pages/` directory = root components)
- Consolidate logic into Composables (`use~`) and keep components thin
- No prop drilling (if it goes three levels deep or more, extract to Pinia or a Composable)

---

## Component Rules

- Always use `<script setup>` + the Composition API (**Options API is prohibited**)
- The declaration style for `defineProps` / `defineEmits` follows the project's language setting:
  - When using TypeScript: `defineProps<{ foo: string }>()` form (type parameter required)
  - When using JavaScript: `defineProps({ foo: String })` form (runtime declaration)
- Each component has a single responsibility (one file = one role)
- Keep global component registration to a minimum

---

## Inertia.js Rules

### Directory layout
| Path | Role |
|---|---|
| `resources/js/Pages/` | Inertia page components (one per route) |
| `resources/js/Components/` | Generic / shared components |
| `resources/js/Composables/` | Composables for logic separation |
| `resources/js/stores/` | Pinia stores |
| `resources/js/app.js` | Entry point |

### Links & navigation
- Always use `<Link>` / `router.visit()` for **internal navigation** (using a raw `<a>` tag directly is prohibited)
- `<a>` tags are fine for **external URLs, `mailto:`, and file downloads**
  - Always add `rel="noopener noreferrer"` whenever you set `target="_blank"`

### Data passing & validation
- Receive server-side validation errors via `useForm()`'s `errors`
- Retrieve shared props (e.g. the authenticated user) via `usePage().props`
- Page component `props` should only receive data passed from the Controller

---

## Pinia Rules

- Place stores in `resources/js/stores/`
- Store names follow the `useXxxStore` form (e.g. `useUserStore`)
- Write side effects (API calls, etc.) only inside `action`s
- **Do not put component-local state into a store** (manage it with `ref` / `reactive` instead)

---

## Naming Conventions

| Target | Convention | Example |
|---|---|---|
| Page component | PascalCase | `UserIndex.vue` |
| Generic component | PascalCase | `BaseButton.vue` |
| Composable | use + PascalCase | `useUserForm.js` |
| Store | use + PascalCase + Store | `useUserStore.js` |

---

## Prohibited Practices

- Using the Options API
- Defining global styles without `<style scoped>` (except Tailwind)
- Direct DOM manipulation such as `document.querySelector` (use `ref` for template references instead)

---

## Additional Rules When Using TypeScript

TypeScript is optional. When used, apply the following:

- Make type parameters explicit with `defineProps<{}>()` / `defineEmits<{}>()`
- Do not use the `any` type (use `unknown` + a type guard when inference isn't possible)
- Add type annotations to Composable / store arguments and return values
- Use `.ts` / `.vue` file extensions (`<script setup lang="ts">`)
