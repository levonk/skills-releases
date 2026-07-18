---
type: Practice
title: Multi-Tenant RLS
description: Row-Level Security on every table with tenant_id isolation. No shared schemas. Every query scoped by tenant_id. Hard constraint from day one.
tags: [supabase, rls, multi-tenant, isolation, postgresql, security]
timestamp: 2026-07-17T00:00:00Z
---

# Multi-Tenant RLS

## Failure Mode

Without RLS, a bug in a query can return data from other tenants. Shared
schemas allow cross-tenant contamination. Missing tenant_id on any table
creates an isolation gap.

## Practice

**Multi-tenant from day one.** Supabase RLS on every table. No shared schemas.

### Rules

1. **Every table has `tenant_id`** — no exceptions
2. **RLS policy enforced** on every table — `WHERE tenant_id = current_tenant_id()`
3. **No shared schemas** — each tenant's data is isolated by RLS
4. **Every query scoped** by tenant_id — no unscoped reads

### Signup Creates Tenant

```
signup → auth user → tenants row (tenant_id) → owner users row (tenant_id)
```

### Lead Magnet Isolation

Lead magnet data is **not** mixed with paid tenant data:
- Separate storage namespace
- Separate RLS policies
- Explicit deletion after session

## Related Concepts

- [Supabase Auth Pattern](supabase-auth-pattern.md) — Auth establishes tenant_id
- [Encrypted Token Storage](encrypted-token-storage.md) — Tokens stored per-tenant

## Citations

[1] `internal-docs/feature/2026/07/bookkeeping-saas-mvp/feat-202607170936-bookkeeping-saas-mvp.md` — bookkeep-saas PRD NFR2
