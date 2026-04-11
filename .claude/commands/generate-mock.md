# /generate-mock — Mock Generation Command

Generate an HTML mockup for the UC number specified as an argument and save it to `docs/product/mockups/`.

## Files to Read Before Running

- `docs/product/requirements.md`
- `docs/product/use-cases.md`
- `docs/product/ui-guidelines.md`
- `docs/product/mockups/README.md`

## Steps

1. Read `requirements.md` and `use-cases.md` to understand the requirements and business context for the specified UC number
2. Check the color, layout, and component guidelines in `ui-guidelines.md`
3. Generate a static HTML mockup that includes:
   - Page title and header (including navigation)
   - Main content for the target UC (structure appropriate to the screen type: list / form / detail, etc.)
   - Action buttons and interactive elements
   - Dummy data (real data must not be used)
4. Use the UC title from `use-cases.md` in English snake_case for the screen name
   (e.g. UC-006 "Order List" → `order-list`)
5. Save as `docs/product/mockups/screen-[UC number]-[screen name].html`
6. Add the screen to the list in `docs/product/mockups/README.md`

## Constraints

- Do not use real data (dummy data only)
- Interactions are not required (static HTML is fine)
- **Only use between Gate 1 approval and Gate 2 approval**
- Business review feedback must be incorporated into `use-cases.md` before proceeding to Gate 2 approval

## Usage Example

```
/generate-mock UC-006
```

→ Generates `docs/product/mockups/screen-UC006-[screen-name].html` and adds it to the screen list in `mockups/README.md`
