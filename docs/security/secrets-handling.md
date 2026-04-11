# secrets-handling.md — Handling Secrets and Confidential Information

> **Especially critical rules in the AI era.**
> Secrets leakage can lead to service outages, data breaches, and cost explosions.

## Absolute Prohibitions (including when using AI)

| Prohibited Action | Reason |
|---|---|
| Hardcoding API keys or passwords in code | Remains in Git history and leaks permanently |
| Committing `.env` actual values | Visible to everyone via the repository |
| Pasting production credentials into AI prompts | Risk of remaining in AI training data or conversation logs |
| Pasting secrets in chat or Slack | Risk of leaking via logs or notifications |
| Outputting secrets or PII in logs | Risk of leaking via the logging infrastructure |

## Correct Management Methods

### Development Environment
```
# .env (git-ignored — write actual values here)
DB_PASSWORD=your_actual_password

# .env.example (committed to Git — key names only)
DB_PASSWORD=
```

### Production Environment
- Use AWS Secrets Manager / GCP Secret Manager / HashiCorp Vault
- Use CI/CD environment variable features (e.g. GitHub Actions Secrets)
- Do not place `.env` files directly on production servers

### When Providing Context to AI
```
# OK: pass context with dummy values
DB_HOST=localhost
DB_PASSWORD=dummy_password_for_context

# NG: paste actual values
DB_PASSWORD=actual_prod_password_here
```

## Types of Confidential Information

| Type | Examples | Where to Manage |
|---|---|---|
| DB connection info | host, user, password | .env / Secret Manager |
| API keys | OpenAI, Stripe, AWS | .env / Secret Manager |
| JWT secret key | APP_KEY | .env / Secret Manager |
| OAuth credentials | client_id, client_secret | .env / Secret Manager |
| PII | Name, email, phone number | DB (encrypted) |

## Handling PII (Personally Identifiable Information)

- Do not output PII in logs (record user IDs only)
- Do not dump data containing PII when debugging
- Mask PII when consulting AI (e.g. `user@example.com` → `[email]`)

## Incident Response

If secrets are leaked:
1. Immediately rotate (invalidate) the affected key or password
2. Review access logs to detect unauthorized use
3. Identify the scope of impact and report to stakeholders
4. Record the cause and prevention measures in an ADR

## Checklist (When Creating a PR)

- [ ] Are `.env` actual values included in the code?
- [ ] Does `git diff` show any secrets mixed in?
- [ ] Do log outputs include PII?
- [ ] Does `composer audit` show any known vulnerabilities?
