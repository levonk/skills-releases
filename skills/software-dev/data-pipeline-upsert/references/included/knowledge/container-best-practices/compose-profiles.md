---
type: Practice
title: Compose Profiles — Optional Services via Named Profiles
description: Use compose profiles to group optional services so a single compose file serves multiple deployment topologies (app-only, app+database, app+proxy, app+auth) without duplicating files or commenting out services.
tags: [docker, docker-compose, profiles, optional-services, deployment-topology, nixos-modules, compose]
date:
  created: "2026-08-10"
  knowledge-basis: "2026-08-10"
  last-used: "2026-08-10"
sources:
  - id: docker-compose-profiles-docs
    resource: "https://docs.docker.com/compose/how-tos/profiles/"
    title: "Docker Compose — Profiles"
---

# Compose Profiles — Optional Services via Named Profiles

## Failure Mode

A project needs multiple deployment topologies: local dev (app + SQLite),
CI (app + PostgreSQL), production (app + PostgreSQL + reverse proxy +
auth). Without profiles, teams either:

- **Maintain multiple compose files** (`docker-compose.yml`,
  `docker-compose.prod.yml`, `docker-compose.ci.yml`) that drift apart and
  duplicate the core service definitions.
- **Comment out services** in a single file and forget to uncomment them
  for production.
- **Use `docker compose up` with all services** and pay the cost of
  starting a database, proxy, and auth service even for a quick local dev
  loop that only needs the app.

## Symptoms

- `docker compose up` starts 6 services when you only needed 1.
- A `docker-compose.prod.yml` override file exists but has not been updated
  since the core `docker-compose.yml` added a new service — production is
  missing a service that dev has.
- CI uses a different compose file than local dev, so a "works on my
  machine" failure is traced to a compose file mismatch, not a code bug.
- New team members do not know which compose file to use for which
  environment.

## Practice

Use **compose profiles** to tag optional services with named profiles. A
service with no `profiles` key always starts. A service with
`profiles: ["with-db"]` only starts when `--profile with-db` is passed.
One compose file, multiple topologies:

```yaml
services:
  # Always runs — the core app
  app:
    build: .
    ports:
      - "${PORT:-3000}:${PORT:-3000}"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:${PORT:-3000}/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Optional: local PostgreSQL (--profile with-db)
  postgres:
    image: postgres:17-alpine
    profiles: ["with-db"]
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-postgres}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  # Optional: reverse proxy with HTTPS (--profile cloud)
  caddy:
    image: caddy:2-alpine
    profiles: ["cloud"]
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
    depends_on:
      app:
        condition: service_healthy

  # Optional: auth service (--profile auth)
  auth-service:
    build: ./auth-service
    profiles: ["auth"]
    environment:
      AUTH_PORT: "${AUTH_SERVICE_PORT:-9000}"
    depends_on:
      app:
        condition: service_healthy

volumes:
  postgres_data:
  caddy_data:
```

### Usage

```bash
# App only (default — zero config, uses SQLite)
docker compose up -d

# App + local PostgreSQL
docker compose --profile with-db up -d

# App + Caddy HTTPS reverse proxy
docker compose --profile cloud up -d

# App + PostgreSQL + Caddy + auth (full production)
docker compose --profile with-db --profile cloud --profile auth up -d
```

### Profile design principles

1. **One concern per profile** — `with-db` adds a database, `cloud` adds a
   proxy, `auth` adds an auth service. Do not bundle unrelated services
   into one profile ("prod" that adds db + proxy + auth). Composing
   single-concern profiles gives every topology without a combinatorial
   explosion of profile names.
2. **The core service has no profile** — the app service always starts.
   Optional infrastructure is layered on top via profiles.
3. **Document the profiles in the compose file header** — a comment block
   at the top lists each profile and what it adds, so a new team member can
   pick the right `--profile` flags without reading every service
   definition.
4. **Cross-profile dependencies use `depends_on`** — if an optional service
   depends on the core app, use `depends_on` with `condition:
   service_healthy` (see
   [compose-service-dependency-ordering](/compose-service-dependency-ordering.md)).
   Compose resolves dependencies across profiles correctly: if both the
   dependency and the dependent are started, the ordering is enforced.

### When not to use profiles

- **If every deployment needs the same services** — profiles add
  complexity for no benefit. Use a single compose file with no profiles.
- **If the topologies are radically different** — if production uses
  Kubernetes and dev uses Compose, profiles will not bridge that gap. Use
  separate files or a different orchestration tool.

## Concrete Instances

### Docker Compose profiles

The native Docker Compose feature. Services tagged with `profiles:
["<name>"]` are only started when `--profile <name>` is passed to `docker
compose up`. Services without a `profiles` key always start. Multiple
profiles can be combined on a single `up` command. This is the primary
instance and the one the practice above describes in detail.

### NixOS modules

NixOS modules serve a similar purpose at the OS level: optional system
services are declared as modules that can be enabled or disabled via
`services.<name>.enable = true;`. A NixOS configuration composes modules
the way Compose composes profiles — the base system always runs, and
optional services (PostgreSQL, Caddy, auth) are enabled per deployment
without duplicating the base configuration. The module system enforces
the same single-concern principle: each module manages one service and
declares its dependencies on other modules.

## Related

- [compose-service-dependency-ordering](/compose-service-dependency-ordering.md)
  — profiles control *which* services start; `depends_on` with
  `condition: service_healthy` controls *when* they start relative to each
  other. Use both together.
- [base-image-selection](/base-image-selection.md) — the database and
  proxy services in a profile still need a well-chosen base image.
- [container-runtime-hardening](/container-runtime-hardening.md) —
  optional services started via profiles should still run non-root with
  cap-drop and no-new-privileges.
