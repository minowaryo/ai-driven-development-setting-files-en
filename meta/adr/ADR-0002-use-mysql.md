# ADR-0002: Adopting MySQL as the Database

## Status
Accepted

## Date
[YYYY-MM-DD]

## Context

A database for the backend needs to be selected.
The application handles business data that requires transactional consistency.
Consideration is given to the team's MySQL operational experience, hosting costs, and ecosystem breadth.

## Decision

Adopt MySQL.

## Rationale

**Reasons for adoption:**
- Most Laravel official documentation examples are MySQL-based
- Widest support across shared hosting and cloud providers (AWS RDS / PlanetScale, etc.)
- Team has extensive MySQL operational knowledge
- Excellent integration with Eloquent (Laravel has optimized many features for MySQL)
- ACID-compliant transactions via InnoDB engine
- Extensive documentation and community (easy for AI to reference)
- JSON type support (MySQL 5.7.8+)

### Rejected Alternatives
- **PostgreSQL**: Feature-rich (JSONB, pg_trgm, RLS, etc.) but overkill for current requirements. Team has limited PostgreSQL operational knowledge.
- **SQLite**: Not suited for scale-out (production environment)
- **MongoDB**: Weak ACID guarantees, not suitable for business data

## Consequences

### Benefits
- Team can leverage existing operational knowledge
- Relatively low hosting costs
- Good compatibility with debugging tools like Laravel Telescope
- Easy to use managed services: AWS RDS MySQL / Aurora MySQL

### Drawbacks / Risks
- JSON operations (JSONB equivalent) are somewhat more limited compared to PostgreSQL
- Table locks may occur during column type changes (consider `pt-online-schema-change` for large datasets)
- Forgetting to set strict mode can cause data integrity issues

### Operational Notes
- Always set `strict: true` in `config/database.php`
- Use `utf8mb4` / `utf8mb4_unicode_ci` for character set
- Schedule a maintenance window for `ALTER TABLE` on large datasets

## Related
- ADR-0001: Laravel adoption
- `.claude/rules/20-mysql.md`
- `docs/architecture/data-model.md`
