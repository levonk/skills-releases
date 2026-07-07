---
name: shopping-acquisition
description: >
  Execute the final purchase of a product or hiring of a service after research
  is complete. Use when the user knows what to buy/hire and at what price, and
  needs help with: (1) negotiation on behalf of the user for products or services
  that require it (luxury watches, cars, used goods, bulk purchases, contractors,
  service providers) — always disclosing agent status, (2) stock monitoring and
  rare-opportunity alerts for out-of-stock or scarce items, (3) auto-purchase
  execution when the user has pre-authorized conditions using their payment
  methods (credit cards and gift cards), (4) purchase notification with exact
  instructions when auto-buy is not enabled, (5) service provider booking with
  scope-of-work verification, deposit negotiation, and payment protection.
  This skill acts as the final execution layer of the personal shopper pipeline.
version: 1.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2026-03-24"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "commerce", "negotiation", "purchasing", "stock-monitoring", "auto-buy"]
see-also:
  - skill: "shopping-needs-discovery"
    relationship: "dependency"
    description: "Discovers and refines purchasing requirements — feeds acquisition with product/service candidates"
  - skill: "shopping-deal-intelligence"
    relationship: "dependency"
    description: "Researches pricing, sourcing, and timing — produces the Deal Intelligence Report acquisition executes on"
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
dependencies:
  - type: skill
    name: shopping-needs-discovery
  - type: skill
    name: shopping-deal-intelligence
  - type: url
    name: Honey (price drop alerts)
    url: https://www.joinhoney.com/
  - type: url
    name: CamelCamelCamel (price alerts)
    url: https://camelcamelcamel.com/
  - type: url
    name: NowInStock
    url: https://www.nowinstock.net/
  - type: url
    name: HotStock
    url: https://www.hotstock.io/
  - type: url
    name: Distill.io (web monitoring)
    url: https://distill.io/
---

{{{ include "includes/base-ai-guidance.md" . }}}

# Shopping Acquisition

Final execution layer: negotiate, monitor, and complete purchases or service bookings. Operates on the Deal Intelligence Report from the deal-intelligence skill.

## Effort Tier Awareness

This skill respects the effort tier from Phase 0:

| Tier | What to run | What to skip |
|------|-----------|---------------|
| **Quick** (under $50) | Manual purchase notification only; skip negotiation, monitoring | Negotiation, stock monitoring, deep optimization |
| **Standard** ($50–$500) | Full workflow minus negotiation (unless used/marketplace) | Multi-source negotiation |
| **Major** ($500–$5k) | Full workflow including negotiation where applicable | Nothing |
| **High-value** ($5k+) | Full workflow + legal review of terms, multi-round negotiation | Nothing |

## Core Workflow — Products

### 1. Negotiation (When Applicable)

Determine if the item/service is negotiable. If yes, conduct negotiation on behalf of the user.

**Negotiable product categories:**
- Vehicles (new and used)
- Luxury watches, jewelry, designer goods
- Real estate and rental agreements
- Used items on marketplace platforms
- Bulk purchasing (10+ units)
- Furniture (especially at independent dealers)
- Enterprise software licenses

**Negotiable service categories:**
- Contractors (landscaping, HVAC, roofing, painting, remodeling)
- Internet, cable, phone service (retention departments)
- Insurance (auto, home, life, health)
- Medical procedures (elective, cosmetic, dental)
- Subscription services (gym, SaaS, storage)
- Professional services (legal, accounting, consulting — scope and rate)

**Mandatory disclosure**: Always identify as an agent acting on behalf of the purchaser at the start of any negotiation. Never misrepresent identity.

```
"I am acting as a purchasing agent on behalf of the buyer. I am authorized
to negotiate terms and pricing but final purchase approval rests with my
principal. [Continue with negotiation...]"
```

For detailed negotiation tactics by category, see `references/negotiation-playbook.md`.

**Negotiation workflow:**

1. **Prepare**: Gather market data from deal-intelligence report (fair market value, comparable sales, inventory levels)
2. **Open**: Start 15–25% below target price (varies by category — see playbook)
3. **Leverage**: Reference competing offers, cash payment, timing advantages, bundle opportunities
4. **Counter**: Respond to counteroffers with data-backed justification
5. **Close**: Confirm terms in writing; document agreed price, inclusions, warranty, timeline
6. **Report**: Deliver negotiation summary to user for approval before commitment

**Negotiation output:**

```markdown
## Negotiation Summary

- Item: [description]
- Seller: [name / platform]
- Opening ask: $X
- Our opening offer: $X
- Final agreed price: $X (Y% below ask)
- Inclusions: [what's included beyond the item]
- Warranty: [terms]
- Conditions: [any contingencies]
- Deadline to accept: [date/time]
- ⚠️ Agent disclosure: Provided at [timestamp]

### User Action Required
→ [ ] Approve purchase at $X
→ [ ] Counter at $X (provide reason)
→ [ ] Decline
```

### 2. Stock Monitoring & Rare Opportunity Alerts

For items that are out of stock, limited edition, or scarce, set up monitoring across specialized tools and classify alerts by priority (Critical / High / Informational).

For the full monitoring tool comparison, alert classification matrix, and output format template, see `references/stock-monitoring.md`.

### 3. Auto-Buy Execution

When the user has pre-authorized automatic purchases, execute based on defined conditions. Auto-buy requires a complete user-provided configuration (product, max price, condition, preferred retailers, payment priority, shipping limits, notification preference).

For the full configuration schema, execution steps, and safeguards, see `references/auto-buy-config.md`.

### 4. Manual Purchase Notification

When auto-buy is not enabled, deliver actionable purchase instructions:

```markdown
## Purchase Ready: [Product Name]

### What to Buy
- Product: [exact name, model, SKU]
- Condition: [New / Refurbished]
- Price: $X.XX

### Where to Buy
- Retailer: [Name] — [direct link to product page]
- Backup: [Alternative retailer] — [link]

### How to Buy (step-by-step)
1. Open [cashback portal URL] and click through to [retailer]
2. Add item to cart
3. Apply coupon code: `CODE123` at checkout
4. Pay with [recommended credit card] for [X% back + extended warranty]
5. Confirm order

### Optimization Applied
| Layer | Savings |
|-------|---------|
| Gift card (buy at [source]) | -$X.XX |
| Cashback ([portal] @ Y%) | -$X.XX |
| Card bonus ([card] @ Zx) | ~$X.XX |
| Coupon | -$X.XX |
| **Net cost** | **$X.XX** |

### Time Sensitivity
- ⏰ Deal expires: [date/time or "ongoing"]
- 📦 Delivery estimate: [X business days]
- ⚠️ Stock level: [X remaining / Limited]
```

## Core Workflow — Services

When the Deal Intelligence Report covers a **service**:

### S1. Service Negotiation

Most services are negotiable. Follow the same agent disclosure rules as product negotiation.

**What to negotiate:**
- **Price**: Reference competing quotes from deal-intelligence report
- **Scope**: Clarify exactly what's included vs extra charges
- **Timeline**: Preferred start date, estimated completion
- **Warranty/guarantee**: Workmanship warranty duration, callback policy
- **Payment terms**: Deposit percentage (push for 10–20% vs 50%), milestone payments for large jobs
- **Materials**: Who supplies materials? Markup on materials? Can user supply?

**Service negotiation output:**

```markdown
## Service Negotiation Summary

- Service: [description]
- Provider: [name / company]
- Their initial quote: $X
- Competing quotes: $Y (Provider B), $Z (Provider C)
- Negotiated price: $X (Y% below initial quote)
- Scope of work: [detailed description]
- Warranty: [terms — e.g., 1-year workmanship guarantee]
- Payment terms: [e.g., 15% deposit, balance on completion]
- Start date: [date]
- Estimated completion: [date]
- ⚠️ Agent disclosure: Provided at [timestamp]

### User Action Required
→ [ ] Approve and schedule
→ [ ] Request changes to scope/terms
→ [ ] Decline and try next provider
```

### S2. Service Booking

1. **Get scope in writing** — Written estimate or contract from provider; never proceed on verbal agreement alone
2. **Verify credentials one final time** — License number, insurance certificate, any required permits
3. **Schedule** — Coordinate start date with user's timeline
4. **Payment setup** — Use credit card with best dispute/purchase protection from `payment_methods`
5. **Document** — Save provider contact info, contract, payment receipts

### S3. Service Payment Protection

Select the best card from `payment_methods` for service payments:

| Protection Needed | Best Card Type | Why |
|------------------|---------------|-----|
| Contractor dispute risk | Amex (best chargeback protection) | Strongest buyer-friendly dispute resolution |
| Equipment installation | Card with extended warranty | Covers installed equipment beyond manufacturer warranty |
| Large project (>$5k) | Card with highest purchase protection | Covers damage/theft during project |
| Recurring service | Card with best general cashback | Ongoing payments benefit from steady rewards |

**Never pay services via:**
- Wire transfer (no recourse)
- Cash without receipt (no documentation)
- Zelle/Venmo for large amounts (limited dispute options)
- Full payment upfront (standard is deposit + balance on completion)

## Resources

- `references/negotiation-playbook.md` — Category-specific negotiation tactics, opening ranges, and leverage points
- `references/stock-monitoring.md` — Monitoring tool comparison, alert classification matrix, and output format
- `references/auto-buy-config.md` — Auto-buy configuration schema, execution steps, and safeguards
- `references/sourcing-guide.md` — (in deal-intelligence skill) Channel comparison by product type

## Error Handling

- **Payment failure**: Retry with next card in `payment_priority`; notify user
- **Out of stock during checkout**: Attempt next preferred retailer; alert user
- **Price changed above max**: Abort auto-buy; notify user with new price
- **Negotiation stalled**: Escalate to user with current best offer and recommendation
- **Service provider no-show**: Contact provider; if unresolved, move to next vetted provider from deal-intelligence report
- **Service quality dispute**: Initiate credit card chargeback process; document with photos/correspondence

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/commerce/acquisition/SKILL.md`
- References: `references/negotiation-playbook.md`

### Related Skills
- `shopping-needs-discovery` (dependency) — discovers and refines purchasing requirements
- `shopping-deal-intelligence` (dependency) — researches pricing, sourcing, and timing
- `base-ai-guidance` (base-framework) — shared framework for all AI guidance types

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles

<!-- vim: set ft=markdown -->
