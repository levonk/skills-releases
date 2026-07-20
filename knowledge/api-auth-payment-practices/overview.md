---
type: Synthesis
title: API Auth Payment Practices Overview
description: Synthesis of SaaS authentication, payment processing, multi-tenant isolation, encrypted token storage, tier-based feature gating, and webhook handling practices.
tags: [auth, payment, stripe, supabase, multi-tenant, rls, saas, overview, synthesis]
timestamp: 2026-07-17T00:00:00Z
---

# API Auth Payment Practices Overview

This bundle documents practices for SaaS authentication, payment processing, and
multi-tenant data isolation. Each concept was extracted from the bookkeep-saas
PRD and task specifications — the hard constraints and architectural decisions
that ensure secure auth, reliable billing, and tenant data isolation.

## The Auth-Payment Stack

```
auth-provider-selection → multi-tenant-rls → payment-provider → token-storage → tier-gating → webhooks
```

| Phase | Practice | Prevents |
|-------|----------|----------|
| Auth | [Auth Provider Selection](auth-provider-selection.md) | Auth migration on paying users, missing passkey-first onboarding, vendor lock-in |
| Isolation | [Multi-Tenant RLS](multi-tenant-rls.md) | Cross-tenant data leakage, shared schema contamination |
| Payment | [Payment Provider Interface](payment-provider-interface.md) | Stripe lock-in, billing rewrite for new providers |
| Secrets | [Encrypted Token Storage](encrypted-token-storage.md) | Token leakage, credential exposure in logs/client |
| Tiers | [Tier Feature Gating](tier-feature-gating.md) | Ungated features, no trial flow, missing dunning |
| Webhooks | [Webhook Idempotency](webhook-idempotency.md) | Duplicate processing, missing audit trail, unverified signatures |

> **Note**: [supabase-auth-pattern.md](supabase-auth-pattern.md) is the
> historical auth pattern. It has been superseded by
> [auth-provider-selection.md](auth-provider-selection.md), which chooses
> better-auth as the auth provider while keeping Supabase Postgres for
> storage-engine RLS via session variables. The historical page is retained
> for context on why the original PRD specified Supabase Auth.

## Hard Constraints

- **No third-party AI APIs** for client financial data (FTC Safeguards Rule)
- **Multi-tenant from day one** — Postgres RLS on every table, enforced at the
  storage engine via session variables (see
  [Auth Provider Selection](auth-provider-selection.md))
- **Plaid/Stripe access_tokens encrypted at rest**, never logged, never exposed to client
- **No CPA-reserved activities** — no audited/certified financial statements
- **Passkey-first auth preference** — passkey-first > passkey > Google/Apple
  OAuth > local password + 2FA > local password only; email always collected
  for recovery (see [Auth Provider Selection](auth-provider-selection.md))

## Scope

This bundle covers **SaaS auth, payment, and tenant isolation**. It does **not**
cover:

- Frontend stack conventions — see
  [frontend-stack-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/frontend-stack-practices/overview.md).
- Dev environment setup — see
  [dev-environment-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/dev-environment-practices/overview.md).
- Secret management infrastructure — see
  [secrets-egress-security](https://github.com/levonk/skills-releases/blob/main/knowledge/secrets-egress-security/overview.md).

## Sources

- `internal-docs/feature/2026/07/bookkeeping-saas-mvp/feat-202607170936-bookkeeping-saas-mvp.md` — bookkeep-saas PRD (1325 lines)
- `internal-docs/feature/2026/07/bookkeeping-saas-mvp/tasks/tasks-bookkeeping-saas-mvp-06-002-auth.md` — auth story (174 lines)
- `internal-docs/feature/2026/07/bookkeeping-saas-mvp/tasks/tasks-bookkeeping-saas-mvp-09-001-billing-tiers-trial.md` — billing story (236 lines)

## Related Knowledge Bundles

- [secrets-egress-security](https://github.com/levonk/skills-releases/blob/main/knowledge/secrets-egress-security/overview.md) —
  Infrastructure-level secret management
- [frontend-stack-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/frontend-stack-practices/overview.md) —
  Frontend conventions for auth/payment UI
- [devsecops-codeguard](https://github.com/levonk/skills-releases/blob/main/knowledge/devsecops-codeguard/overview.md) — Security audit
  practices for auth/payment code
- [software-architecture-essentials](https://github.com/levonk/skills-releases/blob/main/knowledge/software-architecture-essentials/overview.md)
  — Tech decision risk hierarchy and AI + human timeline estimates that
  drove the auth-provider-selection decision

## Citations

[1] `internal-docs/feature/2026/07/bookkeeping-saas-mvp/feat-202607170936-bookkeeping-saas-mvp.md` — bookkeep-saas
[2] `internal-docs/feature/2026/07/bookkeeping-saas-mvp/tasks/tasks-bookkeeping-saas-mvp-06-002-auth.md` — bookkeep-saas
[3] `internal-docs/feature/2026/07/bookkeeping-saas-mvp/tasks/tasks-bookkeeping-saas-mvp-09-001-billing-tiers-trial.md` — bookkeep-saas
