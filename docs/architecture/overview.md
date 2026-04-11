# overview.md — System Architecture Overview

## System Overview

[Describe the purpose and overall picture of the system in 1–2 paragraphs]

## Architecture Diagram

```
[Browser / Mobile]
        ↓ HTTPS
[Load Balancer]
        ↓
[Laravel Application]
   ├─ Routes (api.php / web.php)
   ├─ Middleware (Auth / Throttle)
   ├─ Controllers
   ├─ Services / Actions
   └─ Models (Eloquent)
        ↓
[MySQL]    [Redis (Cache / Queue)]    [S3 (Storage)]
        ↓
[Queue Worker (Horizon)]
```

## Main Components

| Component | Role | Technology |
|---|---|---|
| Web Application | API server and frontend | Laravel [version] |
| Database | Data persistence | MySQL [version] |
| Cache | Sessions and API caching | Redis |
| Queue | Async jobs | Laravel Horizon + Redis |
| Storage | File storage | AWS S3 |
| CDN | Static asset delivery | [e.g. CloudFront] |

## External Integrations

| External Service | Integration Purpose | Direction |
|---|---|---|
| [Service name] | [Purpose] | Outbound / Inbound / Bidirectional |

## Deployment Environments

| Environment | Purpose | URL |
|---|---|---|
| local | Local development | http://localhost |
| staging | Testing and QA | [staging URL] |
| production | Production | [production URL] |

## Related Documents

- Detailed design: `docs/architecture/data-model.md`
- Authentication and authorization: `docs/architecture/authz-authn.md`
- ADRs: `docs/adr/`
