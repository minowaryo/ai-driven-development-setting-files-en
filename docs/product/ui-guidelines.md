# UI Guidelines

> This file defines the project-specific UI/design specifications.
> AI must always refer to this file when generating mockups or implementing the frontend.

---

## Color Palette

| Usage | Color Code | Notes |
|---|---|---|
| Primary | `#[COLOR]` | Main actions and buttons |
| Secondary | `#[COLOR]` | Secondary actions |
| Danger | `#[COLOR]` | Deletion and errors |
| Warning | `#[COLOR]` | Caution and warnings |
| Success | `#[COLOR]` | Success and completion |
| Background | `#[COLOR]` | Page background |
| Surface | `#[COLOR]` | Card and panel background |
| Text primary | `#[COLOR]` | Body text |
| Text secondary | `#[COLOR]` | Supplementary text |

---

## Typography

| Usage | Font | Size | Weight |
|---|---|---|---|
| Heading H1 | [FONT] | [SIZE] | Bold |
| Heading H2 | [FONT] | [SIZE] | SemiBold |
| Body | [FONT] | [SIZE] | Regular |
| Label | [FONT] | [SIZE] | Medium |
| Caption | [FONT] | [SIZE] | Regular |

---

## Layout Principles

- **Grid**: [e.g. 12-column / 8px base grid]
- **Breakpoints**:
  - Mobile: `< 768px`
  - Tablet: `768px–1024px`
  - Desktop: `> 1024px`
- **Container max width**: `[e.g. 1280px]`
- **Standard spacing**: `[e.g. 16px / 24px / 32px]`

---

## Component Guidelines

### Buttons
- Primary: Main action (maximum one per screen)
- Secondary: Secondary actions
- Danger: Delete and cancel (always require a confirmation dialog)
- Ghost: Navigation-related

### Modals
- Use cases: confirmation dialogs and simple form inputs
- Do not use modals for complex operations that require full-page transitions
- Do not stack modals inside modals

### Tables
- Pagination: [e.g. 20 items per page]
- Display an arrow icon on sortable columns
- Always display a message for empty states (0 items)

### Forms
- Display validation errors inline, directly below the field
- Mark required fields with an `*`
- Communicate success / failure after submission via toast notifications

---

## Icons

- Library: [e.g. Heroicons / FontAwesome / Material Icons]
- Size rules: [e.g. 16px (inline) / 20px (button) / 24px (navigation)]

---

## Mockup Creation Rules (for AI)

Instructions for AI when generating mockups:

1. Read this file (`ui-guidelines.md`) before generating HTML
2. Include the corresponding UC number in the file name (e.g. `screen-UC006-filter.html`)
3. Place the file in `docs/product/mockups/`
4. Add the screen to the list in `docs/product/mockups/README.md`
5. Do not use real data — render with dummy data
6. Interactions are not required (static HTML is fine)

### Mockup Generation Prompt Template

```
Read docs/product/use-cases.md [UC-XXX] and docs/product/ui-guidelines.md,
then generate an HTML mockup for [screen name] as docs/product/mockups/screen-[UC-XXX]-[screen-name].html.
Real data is not needed. Please use dummy data.
```
