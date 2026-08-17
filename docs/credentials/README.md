# credentials — Development Credentials Reference

A place to record credentials needed during development (API key references, test account information, etc.).
Unlike `docs/original-docs/`, AI is permitted to create, edit, and read files here.

## Notes for AI (see `.claude/rules/40-security.md`)

- Never output or quote actual values (production API keys, passwords, tokens, etc.) directly in **chat responses, commit messages, or PR descriptions**
- This directory is registered in `.gitignore`. Do not commit it to the repository (local, development-environment only)
- The actual production secrets are managed via Secret Manager. Only keep references to "where things are stored" or dev-only dummy values here
- If a production-grade value is found, do not handle it as-is — confirm with the user

## OK to store here

- Dummy credentials for development/test environments
- References to where production secrets are stored (e.g. "the Stripe test key is stored in 1Password under `xxx`")
- Notes on temporary local-development tokens/credentials

## Never store here

- Actual production API keys, passwords, or tokens
- Personally identifiable credentials
