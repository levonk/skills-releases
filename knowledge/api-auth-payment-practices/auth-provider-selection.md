---
type: Practice
title: Auth Provider Selection
description: better-auth as the auth provider with Supabase Postgres for storage-engine RLS via session variables. Passkey-first preference ordering. Email always collected for account recovery.
tags: [auth, better-auth, supabase, passkey, webauthn, rls, multi-tenant, saas, decision]
timestamp: 2026-07-18T00:00:00Z
supersedes: supabase-auth-pattern.md
---

# Auth Provider Selection

## Failure Mode

Choosing an auth provider based on "it just works" DX alone, then facing a
wide-blast-radius migration on a live financial product when a missing feature
(passkey-first onboarding, custom WebAuthn extensions, per-tenant RP IDs)
becomes a product requirement. Auth migration on paying users means JWT
rotation invalidating every session, OAuth re-consent, MFA re-enrollment,
passkey re-enrollment if the RP ID changes, every RLS policy rewritten, every
Edge Function / Storage policy / Realtime subscription rewritten. That is an
unbounded tail risk for a small SaaS — users locked out during close period =
churn + support load + trust damage.

## Practice

Use **better-auth** as the auth provider, with **Supabase Postgres** as the
database. RLS is enforced at the storage engine via per-request session
variables, not via Supabase Auth's `auth.uid()` coupling.

### Why better-auth from day one (not "migrate later")

- **Passkey-first onboarding is a product value.** Supabase Auth passkeys
  (beta, April 2026) require an existing confirmed user before registering a
  passkey — no passkey-first signup. better-auth supports
  `registration.requireSession: false` + `resolveUser` for true passkey-first
  onboarding (sign up with Face ID / Touch ID, no password ever created).
- **Migration risk is unbounded; upfront cost is bounded.** Auth migration on
  a live financial product is wide-blast-radius (sessions, OAuth, MFA, RLS,
  Edge Functions, Storage, Realtime all rewritten). The upfront cost of
  better-auth + the session-variable RLS middleware is bounded and collapses
  further with AI-assisted dev. "Migrate later" is the classic anti-pattern —
  it never gets easier.
- **TypeScript-first, type-safe sessions.** `session.user.tenantId` is typed
  end-to-end. Drizzle + better-auth share the same TS type surface.
- **No MAU billing.** Self-hosted, you own it. Break-even vs. Supabase Auth
  paid tier is around 50k MAU.
- **Organization plugin** gives first-class primitives for organizations,
  members, roles, invitations — the multi-tenant substrate Supabase Auth
  leaves you to build on top of `auth.users` + a `tenants` table.
- **No vendor lock-in.** You can move DBs (Postgres → SQLite → MySQL) without
  ripping out auth.
- **Audit log of auth events is yours.** Every login / session / revocation is
  a row you control — useful for FTC Safeguards Rule audit trails. Supabase
  Auth logs exist but are limited and not queryable in your DB.

### Why Supabase Postgres stays (not Supabase Auth)

- **RLS at the storage engine is the non-negotiable.** Postgres RLS is
  enforced even when you bypass the app layer (via `psql`, a migration, or a
  bug in your API). This is the single strongest argument against leaving
  Postgres for a financial SaaS.
- **Supabase ecosystem.** Storage (receipts), pg_cron (recurring transaction
  posting), pgvector (AI embeddings), Realtime. These remain valuable even
  with auth decoupled.
- **Compliance posture.** Supabase is SOC2 Type II, GDPR, HIPAA-eligible.
  "We use a SOC2-compliant vendor for the database" is a defensible position
  in an audit.

### The session-variable RLS pattern

```sql
-- App middleware sets per-request context on a transaction-scoped connection
SELECT set_config('app.user_id', $1, true);
SELECT set_config('app.tenant_id', $2, true);

-- RLS policies reference the session variable, not auth.uid()
CREATE POLICY tenant_isolation ON transactions
  USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

```typescript
// CORRECT — transaction-scoped, RLS sees the variable
await db.transaction(async (tx) => {
  await tx.execute(sql`SELECT set_config('app.tenant_id', ${tenantId}, true)`);
  return tx.select().from(transactions);
});

// WRONG — set_config leaks to the next request on a pooled connection
await db.execute(sql`SELECT set_config('app.tenant_id', ${tenantId}, true)`);
await db.select().from(transactions); // different connection, no tenant set
```

The wrong version is **silent**: queries succeed, return data, but return the
**wrong tenant's data**. This is the same class of bug as a broken Supabase
RLS policy — except Supabase's `auth.uid()` is set per-request by their
infrastructure, while yours is set by your middleware.

### Required verification (not optional)

The session-variable pattern must be proven, not assumed:

- A test that opens two concurrent sessions for two tenants and asserts
  neither sees the other's rows.
- A test that runs without the middleware and asserts queries **fail**
  (proving RLS is actually enforced, not just present).
- A test that simulates connection pool reuse and asserts `set_config` is
  reset between requests.
- A Drizzle middleware that **refuses to run queries without a tenant context
  set** (fail-closed).

## Auth Method Preference Ordering

From most preferred to least preferred:

1. **Passkey-first** — sign up with a passkey, no password ever created.
   Phishing-resistant, best UX, best security. Requires
   `registration.requireSession: false` in better-auth.
2. **Passkey** — add a passkey to an existing account (second factor or
   convenience credential).
3. **Google / Apple OAuth** — social sign-in. Lower friction than passwords,
   but the user is dependent on the IdP.
4. **Local password + 2FA** — password with TOTP / WebAuthn second factor.
5. **Local password only** — last resort. Never the only option if a higher
   tier is available.

### Email is always collected

Regardless of which auth method the user picks, **always collect the user's
email address directly** so they can recover the account if they have a
problem with the upstream provider (lost passkey, lost OAuth provider access,
lost device). The email is the recovery root, not a sign-in method.

- Passkey-first onboarding still prompts for email before the WebAuthn
  ceremony completes.
- OAuth flows still record the email in the local `users` table, not just in
  the OAuth provider's profile.
- Email verification is required before the account is considered recoverable.

## When to reconsider Supabase Auth instead

Flip back to Supabase Auth only if **all** of these are true:

- Passkey-first onboarding is definitively not a product priority.
- The team has no capacity to own the session-variable RLS middleware and its
  verification tests.
- The compliance posture of "SOC2-compliant vendor for auth" is required by an
  enterprise customer or regulator and self-hosted auth is not acceptable.
- Supabase Auth passkeys graduate from beta and the API stabilizes.

## Related Concepts

- [Multi-Tenant RLS](multi-tenant-rls.md) — RLS policies enforced after auth
  sets the session variable
- [Encrypted Token Storage](encrypted-token-storage.md) — Tokens stored
  per-tenant, encrypted at rest
- [Tier Feature Gating](tier-feature-gating.md) — Trial starts at signup
- [Tech Decision Risk Assessment](https://github.com/levonk/skills-releases/blob/main/knowledge/software-architecture-essentials/tech-decision-risk-assessment.md)
  — The risk hierarchy that drove the "no migration" decision
- [AI + Human Timeline Estimates](https://github.com/levonk/skills-releases/blob/main/knowledge/software-architecture-essentials/ai-human-timeline-estimates.md)
  — Why upfront cost was reassessed as bounded

## Citations

[1] `internal-docs/feature/2026/07/bookkeeping-saas-mvp/feat-202607170936-bookkeeping-saas-mvp.md` — bookkeep-saas PRD (NFR3, NFR8)
[2] [better-auth passkey plugin](https://better-auth.com/docs/plugins/passkey)
[3] [Supabase Auth passkeys (beta)](https://supabase.com/docs/guides/auth/passkeys)
[4] [Supabase Auth passkeys beta changelog](https://supabase.com/changelog/46458-passkeys-for-supabase-auth-beta)
