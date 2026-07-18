---
type: Practice
title: Webhook Idempotency
description: Stripe webhook handler with signature verification, idempotent processing (handle duplicate deliveries), audit logging without tokens, subscription sync logic.
tags: [stripe, webhooks, idempotency, audit-logging, subscriptions, saas]
timestamp: 2026-07-17T00:00:00Z
---

# Webhook Idempotency

## Failure Mode

Duplicate webhook deliveries cause double-processing (e.g., double subscription
creation). Missing signature verification allows forged webhooks. Logging
webhook events with token values leaks credentials.

## Practice

### Webhook Handler Route

`/api/webhooks/stripe` — handles all Stripe webhook events.

### Signature Verification

- Verify Stripe webhook signature before processing
- Reject unverified requests with 401

### Idempotent Processing

- Handle duplicate webhook deliveries safely
- Track processed event IDs to skip duplicates
- Database upserts (not inserts) for subscription sync

### Subscription Sync

Stripe webhook events that upsert the `subscriptions` row:
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `invoice.payment_succeeded`
- `invoice.payment_failed`

Map Stripe status → internal status: `trialing`, `active`, `past_due`,
`canceled`, `incomplete`.

Update `tenants.tier` and `tenants.billing_cycle` from subscription data.

### Audit Logging

- Log all webhook events for audit
- **Never log Stripe tokens** in webhook events
- Log event type, tenant ID, subscription ID, timestamp

## Related Concepts

- [Payment Provider Interface](payment-provider-interface.md) —
  `handleWebhook()` method
- [Encrypted Token Storage](encrypted-token-storage.md) — No tokens in logs
- [Tier Feature Gating](tier-feature-gating.md) — Dunning triggers tier downgrade

## Citations

[1] `internal-docs/feature/2026/07/bookkeeping-saas-mvp/tasks/tasks-bookkeeping-saas-mvp-09-001-billing-tiers-trial.md` — bookkeep-saas
