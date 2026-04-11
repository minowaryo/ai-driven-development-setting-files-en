# ADR-0001: Adopting Laravel as the Backend Framework

## Status
Accepted

## Date
[YYYY-MM-DD]

## Context

A backend framework for the web application needs to be selected.
The development team has extensive PHP experience and is building a web application.
Since AI-driven development is a prerequisite, a framework with well-established code conventions that AI can easily understand is desirable.

## Decision

Adopt Laravel.

## Rationale

**Reasons for adoption:**
- The most active community in the PHP ecosystem
- Standard features needed for AI-driven development: Eloquent ORM, Migrations, Seeders, Factories, etc.
- Built-in authorization via Policy / Gate
- Clear separation of concerns: FormRequest, Resource, Job, Event, etc.
- Excellent integration with testing (PestPHP / PHPUnit)
- Extensive official documentation (easy for AI to reference)

### Rejected Alternatives
- **Symfony**: Powerful but configuration is complex, potentially slowing development speed
- **Slim / Lumen**: Too simple, lacking the standard features needed for AI-driven development
- **Node.js (Express/Nest)**: Team's primary skill set is PHP

## Consequences

### Benefits
- All team members can leverage their existing knowledge
- High code generation quality since AI has learned Laravel conventions
- Rich package ecosystem (Cashier, Telescope, Horizon)

### Drawbacks / Risks
- Need to keep up with PHP version upgrades
- Somewhat constrained by framework conventions

## Related
- ADR-0002: MySQL adoption
- `docs/architecture/overview.md`
