# ADR-0003: Authentication Strategy (Sanctum + Policy/Gate)

## Status
Accepted

## Date
[YYYY-MM-DD]

## Context

An authentication and authorization strategy needs to be defined for a system that uses both API and traditional web sessions.
A mechanism is required that ensures security while also being easy to implement correctly in AI-driven development.

## Decision

- **Authentication**: Laravel Sanctum (supports both API tokens and session authentication)
- **Authorization**: Always route through Policy / Gate (direct role checks are prohibited)

## Rationale

**Reasons for adopting Sanctum:**
- Supports both SPAs and API tokens
- Natively integrated with Laravel, requiring minimal additional configuration
- Lighter and simpler than Passport

**Reasons for the Policy/Gate approach:**
- Centralizes authorization logic in one place (prevents it from being scattered)
- Easy to write tests for
- Helps prevent AI-generated code from missing authorization checks
- `before()` can be used to centrally manage all admin permissions

### Rejected Alternatives
- **Laravel Passport**: Over-engineered unless OAuth is required
- **JWT (custom implementation)**: Sanctum is sufficient; custom implementations carry high risk
- **Direct role checks**: Authorization logic becomes scattered, making it easy for AI-generated code to miss checks

## Consequences

### Benefits
- Centralized management of authorization logic
- Reduced risk of missing authorization checks in AI-generated code
- Easy to write tests

### Drawbacks / Risks
- Discipline is required to always write the Policy `authorize()` call in Controllers
- If forgotten, the rule must be explicitly stated in `.claude/rules/40-security.md`

## Related
- `docs/architecture/authz-authn.md`
- `.claude/rules/40-security.md`
- `.claude/rules/10-laravel.md`
