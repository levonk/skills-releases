---
type: Practice
title: Supabase Auth Pattern
description: Supabase Auth with email/password + OAuth (Google, Microsoft), cookie-based sessions via @supabase/ssr, server actions for login/signup, protected-route middleware.
tags: [supabase, auth, oauth, sessions, server-actions, middleware, saas]
timestamp: 2026-07-17T00:00:00Z
---

# Supabase Auth Pattern

## Failure Mode

Inconsistent authentication across apps, broken session management in App
Router edge middleware, OAuth redirect misconfiguration, and waitlist users
needing to re-signup.

## Practice

Use **Supabase Auth** with email/password + OAuth (Google, Microsoft) as the
shared authentication layer.

### Auth Helpers

- `apps/saas/src/lib/auth.ts` — Supabase server/client helpers
- Use `@supabase/ssr` for cookie-based sessions in App Router
- `getSession()`, `signOut()` functions

### Auth Context Provider

- `useSession()` hook exposing `{ user, tenant, role, loading }`
- Reads from server session + `users`/`tenants` rows

### Signup Transaction

1. `supabase.auth.signUp` creates auth user
2. Server action creates `tenants` row (tier `free`, `trial_ends_at` = now + 14d)
3. Creates owner `users` row linked to auth user + tenant
4. All in a database transaction

### Protected Routes

- Middleware reads session from cookies via `@supabase/ssr`
- Unauthenticated `/[locale]/(dashboard)/*` redirects to `/[locale]/login`
- `/[locale]/(auth)/*` and locale root allowed without session

### Security

- TLS in transit; sessions via httpOnly cookies
- Generic "invalid credentials" message (don't reveal if email exists)
- Log auth events at info level with user ID (not email in plaintext)

## Related Concepts

- [Multi-Tenant RLS](multi-tenant-rls.md) — RLS policies enforced after auth
- [Tier Feature Gating](tier-feature-gating.md) — Trial starts at signup

## Citations

[1] `internal-docs/feature/2026/07/bookkeeping-saas-mvp/tasks/tasks-bookkeeping-saas-mvp-06-002-auth.md` — bookkeep-saas
