# 40-security.md — Security Rules

## Secrets Management (Most Important)

### Absolute Prohibitions
- Hardcoding API keys or passwords in code
- Committing, pasting in chat, or sharing `.env` actual values with AI
- Including production credentials in AI prompts
- Committing `secrets.*` type files to Git

### Correct Management Methods
- Secrets go in `.env` only (`.env.example` lists key names only)
- Use a Secret Manager (e.g. AWS Secrets Manager) for production secrets
- Use dummy values in contexts passed to AI

### Handling `docs/credentials/`

Unlike `docs/original-docs/` (reference-only, editing prohibited), `docs/credentials/` is intended for recording credentials needed during development, and **AI is permitted to create, edit, and read it**. However, the following must always be observed:

- Never output or quote actual values (production API keys, passwords, tokens, etc.) directly in chat responses, commit messages, or PR descriptions
- Register `docs/credentials/` in `.gitignore` and never commit it (a local, development-environment-only location)
- The actual production secrets are still managed via Secret Manager per the rules above — `docs/credentials/` only holds records of "where things are stored" or dev-only dummy values
- If an actual production-grade value is found, do not handle it as-is — stop and confirm with the user (always pause before committing or outputting it)

## Authentication & Authorization

- Authentication: use Laravel Sanctum / Passport
- Authorization: **always use Policy / Gate** (direct role checks are prohibited)
- Sessions: set HttpOnly + Secure cookies
- CSRF: always enable the `VerifyCsrfToken` middleware

## Input Validation

- Always validate user input with FormRequest
- SQL injection prevention: use Eloquent (raw SQL is prohibited)
- XSS prevention: use Blade's `{{ }}` (minimize use of `{!! !!}`)
- File uploads: validate MIME type, size, and extension

## Logging & Auditing

### Must NOT appear in logs
- Passwords
- API keys and tokens
- Credit card numbers
- Personally Identifiable Information (PII)

### Should appear in logs
- User ID (in a non-personally-identifiable form)
- Operation type and timestamp
- Error type and stack trace (minimal in production)

### Audit Log Channel

Audit entries for privileged or destructive operations go to a **dedicated `audit` channel**, not the default application log.

- Define an `audit` channel in `config/logging.php` (`storage/logs/audit.log`, daily rotation, retention driven by a `LOG_AUDIT_DAYS` env var — add the key to `.env.example`)
- Pin the channel's `level` to `info` **independently of `LOG_LEVEL`**, so raising the application log level in production can never silence the audit trail
- Always write entries with this fixed minimal schema — no free-form message shapes, so the log stays machine-parsable:

| Field | Content |
|---|---|
| `action` | Operation name (e.g. `employee.deleted`) |
| `actor_id` | ID of the acting user (ID only — never name or email) |
| `subject_type` | Class / table name of the target record |
| `subject_id` | ID of the target record |

- Never put PII (name, email, address, etc.) or the changed values themselves into an audit entry — `subject_type` + `subject_id` is enough to identify the record
- The actor stamp columns on the record (see `.claude/rules/10-laravel.md`) and this channel are complementary: the columns hold the latest state, the channel holds the history

## Dependency Packages

- Run `composer audit` regularly to check for vulnerabilities
- Verify major updates in a test environment before merging
- Remove unused packages

## OWASP Top 10 Compliance Checklist

- [ ] Injection (SQLi / XSS)
- [ ] Broken Authentication
- [ ] Sensitive Data Exposure
- [ ] XXE
- [ ] Broken Access Control
- [ ] Security Misconfiguration
- [ ] Insecure Deserialization
- [ ] Using Components with Known Vulnerabilities
- [ ] Insufficient Logging
