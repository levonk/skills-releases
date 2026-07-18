---
type: Practice
title: Encrypted Token Storage
description: Plaid and Stripe access_tokens encrypted at rest (AES-256), never logged, never exposed to client. Hard constraint from FTC Safeguards Rule and client trust.
tags: [encryption, tokens, plaid, stripe, security, aes-256, secrets]
timestamp: 2026-07-17T00:00:00Z
---

# Encrypted Token Storage

## Failure Mode

Plaid or Stripe access tokens stored in plaintext can be stolen via database
breach. Tokens in logs leak credentials. Tokens exposed to client-side code
allow unauthorized API access.

## Practice

**Hard constraint**: Plaid `access_token` and Stripe `access_token` are:

1. **Encrypted at rest** (AES-256)
2. **Never logged** — no token values in any log output
3. **Never exposed to client** — server-side only

### Implementation

- Tokens encrypted before database storage
- Decryption only in server-side code
- No token values in API responses to client
- No token values in structured logs
- Environment variables for encryption keys (not in code)

### FTC Safeguards Rule Compliance

This is a hard constraint from the FTC Safeguards Rule and client trust. The
WISP (Written Information Security Program) must document:
- Encryption method (AES-256)
- Key management procedures
- Access controls for encrypted data
- Audit trail for token access

## Related Concepts

- [Payment Provider Interface](payment-provider-interface.md) — Provider uses
  these tokens
- [Multi-Tenant RLS](multi-tenant-rls.md) — Tokens isolated per tenant
- [Webhook Idempotency](webhook-idempotency.md) — Webhook handler never logs
  tokens

## Citations

[1] `internal-docs/feature/2026/07/bookkeeping-saas-mvp/feat-202607170936-bookkeeping-saas-mvp.md` — bookkeep-saas PRD NFR3
