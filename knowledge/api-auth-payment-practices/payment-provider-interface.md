---
type: Practice
title: Payment Provider Interface
description: Abstract Stripe behind PaymentProvider interface with createSubscription, cancelSubscription, upgradeTier, getInvoices, handleWebhook methods. Enables future Paddle/Razorpay/MercadoPago without billing rewrite.
tags: [stripe, payment, provider-interface, abstraction, billing, subscriptions]
timestamp: 2026-07-17T00:00:00Z
---

# Payment Provider Interface

## Failure Mode

Hardcoding Stripe directly into billing logic makes it impossible to switch
providers without a full billing rewrite. Different regions may require
different providers (Paddle for EU, Razorpay for India, MercadoPago for LATAM).

## Practice

Abstract payment processing behind a **`PaymentProvider` interface**.

### Interface Methods

```typescript
interface PaymentProvider {
  createSubscription(tenantId, tier, billingCycle): Promise<Subscription>
  cancelSubscription(subscriptionId): Promise<void>
  upgradeTier(subscriptionId, newTier): Promise<Subscription>
  getInvoices(tenantId): Promise<Invoice[]>
  handleWebhook(event: WebhookEvent): Promise<void>
}
```

### Stripe Implementation

- `StripePaymentProvider` in `apps/saas/src/lib/payments/stripe.ts`
- Stripe secret key loaded from env, encrypted at rest
- All Stripe API calls server-side only
- Never log Stripe tokens

### Future Providers

The interface is built to support:
- Paddle (EU compliance)
- Razorpay (India)
- MercadoPago (LATAM)

Only Stripe is implemented now; interface allows adding others without
rewriting billing logic.

## Related Concepts

- [Encrypted Token Storage](encrypted-token-storage.md) — Stripe key security
- [Webhook Idempotency](webhook-idempotency.md) — Webhook handling via interface
- [Tier Feature Gating](tier-feature-gating.md) — Tiers managed through provider

## Citations

[1] `internal-docs/feature/2026/07/bookkeeping-saas-mvp/tasks/tasks-bookkeeping-saas-mvp-09-001-billing-tiers-trial.md` — bookkeep-saas
