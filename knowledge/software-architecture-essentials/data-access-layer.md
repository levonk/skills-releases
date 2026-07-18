---
type: Practice
title: Data Access Layer
description: Centralized data access layer that abstracts data sources, provides a single source of truth, and enforces authorization.
tags: [architecture, data-access, dal, security, abstraction]
timestamp: 2026-07-18T00:00:00Z
---

# Data Access Layer (DAL)

A Data Access Layer (DAL) is a dedicated, centralized part of your application responsible for all data-related operations. It abstracts the underlying data source (e.g., database, API) from your business logic.

- **Centralize Logic**: Consolidate all data fetching, caching, and mutation logic into a single location (e.g., a `src/data/` or `src/lib/data` directory).
- **Single Source of Truth**: By centralizing data access, you create a single source of truth for how data is retrieved and modified. This simplifies debugging and maintenance.
- **Security Checkpoint**: The DAL provides a natural and effective checkpoint to enforce authorization and validate user permissions before any data is accessed or returned.

## Sources

- Migrated from src/current/rules/software-dev/general/architecture/data-access-layer.md
