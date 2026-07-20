# Directory Update Log

## 2026-07-18

* **Ingest**: Added [auth-provider-selection.md](auth-provider-selection.md) —
  the canonical auth provider decision: better-auth as auth provider + Supabase
  Postgres for storage-engine RLS via session variables. Documents the
  passkey-first preference ordering (passkey-first > passkey > Google/Apple
  OAuth > local password + 2FA > local password only) and the email-always-
  collected-for-recovery requirement. Supersedes supabase-auth-pattern.md
  (which is retained as historical context for why the original PRD specified
  Supabase Auth).
* **Update**: Marked [supabase-auth-pattern.md](supabase-auth-pattern.md) as
  superseded by auth-provider-selection.md in [index.md](index.md) and
  [overview.md](overview.md).
* **Cross-link**: Added bidirectional links to
  [software-architecture-essentials/tech-decision-risk-assessment.md](https://github.com/levonk/skills-releases/blob/main/knowledge/software-architecture-essentials/tech-decision-risk-assessment.md)
  and
  [software-architecture-essentials/ai-human-timeline-estimates.md](https://github.com/levonk/skills-releases/blob/main/knowledge/software-architecture-essentials/ai-human-timeline-estimates.md)
  — the risk hierarchy and AI + human estimate format that drove the
  "better-auth from day one, do not migrate later" decision.
* **Source**: Decision dialogue in
  `internal-docs/feature/2026/07/bookkeeping-saas-mvp/` covering PocketBase
  evaluation, Supabase Auth vs. better-auth, passkey-first onboarding, and
  the cost-of-migration risk analysis.

## 2026-07-17

* **Initialization**: Created the `api-auth-payment-practices` knowledge bundle to consolidate SaaS authentication, payment processing, and multi-tenant isolation practices from the bookkeep-saas PRD and task specs.
* **Creation**: Authored 6 concept pages covering the auth-payment stack.
  - [supabase-auth-pattern.md](supabase-auth-pattern.md) — Supabase Auth with OAuth, cookie sessions, server actions
  - [multi-tenant-rls.md](multi-tenant-rls.md) — RLS on every table, tenant_id isolation, no shared schemas
  - [payment-provider-interface.md](payment-provider-interface.md) — Abstract Stripe behind PaymentProvider interface
  - [encrypted-token-storage.md](encrypted-token-storage.md) — AES-256 at rest, never logged, never exposed to client
  - [tier-feature-gating.md](tier-feature-gating.md) — Free/Starter/Pro/Premium tiers, trial, dunning, commitment terms
  - [webhook-idempotency.md](webhook-idempotency.md) — Signature verification, idempotent processing, audit logging
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
* **Note**: Concepts extracted from bookkeep-saas PRD (1325 lines), auth story (174 lines), and billing story (236 lines).
