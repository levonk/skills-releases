# Commerce Skills

Three skills that form a personal-shopper pipeline: discover what to buy,
find the best deal, then execute the purchase. Each skill is self-contained
and can be invoked standalone, but they are designed to hand off to each
other in sequence.

## Pipeline

```
shopping-needs-discovery  →  shopping-deal-intelligence  →  shopping-acquisition
   "What should I buy?"         "Where/when/how to buy?"        "Execute the buy"
```

| Stage | Skill | Input | Output | When to invoke |
|-------|-------|-------|--------|----------------|
| 1. Discover | `shopping-needs-discovery` | Vague need or problem | Needs Discovery Brief (candidate products/services + constraints) | User needs help figuring out what to buy or hire |
| 2. Research | `shopping-deal-intelligence` | Needs Discovery Brief (or known product) | Deal Intelligence Report (pricing, sourcing, timing, optimization, warranty, acquisition strategy) | User knows what they want; needs the best deal |
| 3. Execute | `shopping-acquisition` | Deal Intelligence Report | Completed purchase or booking | User is ready to buy; needs negotiation, monitoring, or handoff verification |

## Skill Summaries

### shopping-needs-discovery

Structured interviewing to refine purchasing requirements. Uses a 3-level
progressive-disclosure constraint system:

- **Level 1** — attribute index with applicability matrix
- **Level 2** — attribute files (obsolescence, repairability, TCO, used-risks,
  situational-fit)
- **Level 3** — domain files (computers, mobile-phones, automobiles, real
  estate, appliances, cameras, tools, services, consumables, etc.)

Domain files cover product-specific constraints including the critical
**lock-verification** content for used Apple devices (Activation Lock,
MDM/ABM, firmware/EFI) and carrier locks for phones (IMEI blacklist, AT&T
VoLTE whitelist, carrier-financed locks). The computers domain cross-links
to the deal-intelligence acquisition-strategy analysis for the
lease-vs-buy-vs-finance-vs-used math.

### shopping-deal-intelligence

Research pricing, sourcing, timing, and acquisition structure. Sections:

1. **Historical price research** — CamelCamelCamel, Wayback, Slickdeals,
   closed auctions
2. **Sourcing channels** — retail, auctions, government surplus, corporate
   liquidation, flash-sale (Whatnot), secondhand, salvage yards
3. **Market timing** — seasonality, lifecycle, inventory, regulatory signals
4. **Purchase optimization** — gift cards, cashback portals (Rakuten,
   Capital One Shopping, Bing Rewards), credit card bonuses (incl. Apple
   Card 3%), coupons, price matching
5. **Warranty comparison** — risk-adjusted cost across suppliers/conditions
6. **Acquisition strategy** — lease vs finance (incl. 0% APR) vs buy-new vs
   buy-refurbished vs buy-used/liquidation, tax-adjusted NPV (Section 179,
   MACRS, effective tax rate, sales-tax avoidance on used), residual value,
   upgrade-cycle frequency, "new version imminent" depreciation cliffs.
   Deterministic calculator: `scripts/acquisition_strategy.py`. Worked
   example: MacBook Pro M5 Max vs Mac Studio M3 Ultra vs wait-for-M5-Ultra.

### shopping-acquisition

Final execution layer. Negotiation (always disclosing agent status), stock
monitoring, auto-purchase, service booking, and in-person handoff
verification for used lockable devices (erase-and-reset test, Activation
Lock/MDM/firmware/BitLocker/carrier blacklist checks, receipt retention).

## Knowledge Bundles

The commerce skills do not have a dedicated commerce knowledge bundle —
their domain knowledge lives in the skills' own `references/` directories
(needs-discovery's attribute and domain files, deal-intelligence's
sourcing/timing/optimization/warranty/acquisition-strategy references).
This is intentional: the knowledge is tightly coupled to the skill
workflows and changes with the market, so it stays in the skills rather
than in a compounding best-practices bundle.

The skills reference these existing bundles where relevant:

- [`dev-environment-practices`](../../knowledge/dev-environment-practices/)
  — shell-scripting best practices (used by deal-intelligence scripts)
- [`simplified-technical-english`](../../knowledge/simplified-technical-english/)
  — writing rules for reference prose

## Handoff Points

| From | To | What passes |
|------|----|-------------|
| needs-discovery | deal-intelligence | Needs Discovery Brief (candidate products + constraints) |
| deal-intelligence | acquisition | Deal Intelligence Report (best source, price, timing, acquisition structure) |
| deal-intelligence (Section 6) | needs-discovery (computers.md) | Lock-verification content for used-device NPV input |
| acquisition | needs-discovery | If a deal falls through, loop back to discover alternatives |

## Created

- Date: 2026-08-17
- Skills: 3 (needs-discovery, deal-intelligence, acquisition)
- Pipeline: discover → research → execute

<!-- vim: set ft=markdown -->
