# Mockups

Manage the list of mockup files and their corresponding use case numbers.

## File Naming Convention

```
screen-[UC number]-[screen name (lowercase, hyphen-separated)].[html|png|md]
```

Examples:
- `screen-UC006-order-list.html`
- `screen-UC007-order-detail.html`
- `screen-UC007-order-detail.png` + `screen-UC007-order-detail.md` (for image mockups, always include a companion .md)

## Screen List

| File Name | UC | Screen Name | Created | Business Review | Feedback Incorporated |
|---|---|---|---|---|---|
| *(add entries here)* | | | | | |

## Operation Rules

- Mockups are created **between Gate 1 approval and Gate 2** (do not wait for Gate 3)
- Incorporate business review feedback into `docs/product/use-cases.md`
- Proceed to Gate 2 (final use-cases.md approval) after incorporating feedback
- Image mockups (PNG, etc.) must always include a companion .md file (for providing context to AI)

## Companion .md Content (for image mockups)

```markdown
# [Screen Name] Mockup Supplement

## Corresponding UC
- UC-XXX: [UC Title]

## Notes & Design Intent
- [Key points to communicate to AI, as bullet points]

## Business Review Feedback (reviewed)
- [Feedback content and response policy]
```
