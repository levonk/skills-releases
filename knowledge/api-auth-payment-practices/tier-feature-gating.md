---
type: Practice
title: Tier Feature Gating
description: Free/Starter/Pro/Premium tiers with feature flags, 14-day Pro trial (no credit card), dunning (3 retries over 14 days → downgrade), commitment terms (quarterly/annual), annual discount ~15%.
tags: [tiers, billing, feature-gating, trial, dunning, stripe, saas]
timestamp: 2026-07-17T00:00:00Z
---

# Tier Feature Gating

## Failure Mode

Without tier-based gating, all users access all features. No trial flow means
no conversion path. Missing dunning lets failed payments go unhandled. No
commitment terms allow month-to-month churn.

## Practice

### Tier Definitions

4 tiers with feature flags per tier:
- **Free** — limited features, receipt cap (50/mo)
- **Starter** — basic features, monthly/annual
- **Pro** — advanced features, AI, Plaid, multi-entity (cap: 3)
- **Premium** — all features, priority support

### Feature Gate Utility

```typescript
checkTier(tier, feature): boolean  // Returns whether tier has access
getTierLimits(tier): TierLimits    // Returns caps (receipts, entities, etc.)
```

### Trial Flow

- 14-day Pro trial, no credit card required
- `trial_ends_at = now + 14d` set on signup
- Countdown banner displays at day 7+ ("X days left in your Pro trial")
- Day 10 email with pricing + upgrade CTA
- At trial end: choose paid tier or downgrade to Free

### Dunning

- Subscription `past_due` → Stripe retries 3 times over 14 days
- If all retries fail → downgrade to Free tier
- Log downgrade in `audit_log`
- Send dunning emails via Stripe or app email provider

### Commitment Terms

- Paid tiers require minimum commitment: quarterly (3 months) or annual (12 months)
- Monthly billing available only during year 1 (configurable flag)
- Annual discount: ~15% vs. monthly equivalent
- Upgrade prorates immediately; downgrade applies at next renewal
- Cancel sets `cancel_at_period_end = true`

## Related Concepts

- [Payment Provider Interface](payment-provider-interface.md) — Provider manages
  subscriptions
- [Supabase Auth Pattern](supabase-auth-pattern.md) — Trial starts at signup

## Citations

[1] `internal-docs/feature/2026/07/bookkeeping-saas-mvp/tasks/tasks-bookkeeping-saas-mvp-09-001-billing-tiers-trial.md` — bookkeep-saas
