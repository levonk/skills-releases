---
okf_version: "0.1"
---

# API Auth Payment Practices

A compounding knowledge base documenting practices for authentication, payment
processing, and multi-tenant data isolation in SaaS applications. Each concept
captures specific architectural decisions sourced from the bookkeep-saas PRD and
task specifications.

## Concepts

* [Overview](overview.md) - Synthesis of the full API auth payment practice set
* [auth-provider-selection](auth-provider-selection.md) - better-auth as auth provider + Supabase Postgres for storage-engine RLS via session variables; passkey-first preference ordering; email always collected for recovery (supersedes supabase-auth-pattern)
* [supabase-auth-pattern](supabase-auth-pattern.md) - Historical: Supabase Auth with email/password + OAuth, cookie-based sessions, server actions (superseded by auth-provider-selection)
* [multi-tenant-rls](multi-tenant-rls.md) - Row-Level Security on every table, tenant_id isolation, no shared schemas
* [payment-provider-interface](payment-provider-interface.md) - Abstract Stripe behind PaymentProvider interface for future provider swaps
* [encrypted-token-storage](encrypted-token-storage.md) - Plaid/Stripe access tokens encrypted at rest, never logged, never exposed to client
* [tier-feature-gating](tier-feature-gating.md) - Free/Starter/Pro/Premium tiers with feature flags, 14-day trial, dunning, commitment terms
* [webhook-idempotency](webhook-idempotency.md) - Stripe webhook handler with signature verification, idempotent processing, audit logging
