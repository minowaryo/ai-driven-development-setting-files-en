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
