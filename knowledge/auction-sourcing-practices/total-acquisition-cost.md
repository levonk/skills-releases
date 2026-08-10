---
type: Practice
title: Total Acquisition Cost
description: The winning bid is rarely the final price; always calculate bid + buyer's premium + tax + fees + transport + repairs.
tags: [auctions, cost-calculation, buyers-premium, total-cost]
date:
  created: "2026-08-07"
  knowledge-basis: "2026-08-07"
  last-used: "2026-08-07"
sources:
  - id: auction-constraints-reference
    resource: skills/commerce/deal-intelligence/references/auction-constraints.md
    title: auction-constraints.md
  - id: sourcing-sources-toml
    resource: skills/commerce/deal-intelligence/references/sourcing-sources.toml
    title: sourcing-sources.toml
---

# Total Acquisition Cost

## Failure Mode

A buyer sets a maximum bid of $5,000 for a vehicle at auction. They
win the auction at $4,500 — under budget! But then the fees add up:
10% buyer's premium ($450), sales tax on the bid + premium ($341),
title/registration fees ($300), gate fee ($50), virtual bid fee
($75), transport ($800), and smog repairs ($600). The true cost is
$7,116 — 42% over the winning bid and 58% over what the buyer
thought they were paying.

## Practice

**Always calculate the total acquisition cost, not just the winning
bid. Present the total in the Deal Intelligence Report.**

```
Total = Winning Bid
      + Buyer's Premium
      + Sales Tax (on bid + premium in some states)
      + Title/Registration Fees
      + Documentation Fee
      + Gate/Environmental/Virtual Bid Fees
      + Inspection/Transport Costs
      + Any Required Repairs
```

### Buyer's Premium by Platform

| Platform | Buyer's premium |
|----------|----------------|
| GSA Auctions | 0% |
| GSA Fleet | 0% |
| IRS Auctions | 0% |
| Apple Towing / RBEX | 0% |
| Municibid | 0% (seller pays) |
| Michigan DTMB | 3% |
| GovDeals | 7.5–12.5% (tiered) |
| NY State Store | 8% |
| Public Surplus | 0–10% |
| GovLiquidation | 10% |
| Seattle Fleet | 10% + 3% credit card |
| Cook County | ~10% |
| Sierra Auction | 12% + 2% online |
| GovPlanet | 10–15% |
| Ritchie Bros. | 12–15% |
| PropertyRoom | 16.5% |

### Additional Fees to Check

- **Sales tax**: May apply on the buyer's premium portion in some
  states
- **Internet buyer's fee**: Some platforms charge separately for
  online bids vs. in-person bids
- **Documentation fee**: Dealer-style doc fees at some platforms
- **Storage fee**: If the vehicle isn't picked up within the free
  period (typically 3–7 days), daily storage charges accrue
  ($25–$75/day)
- **Gate fee**: Flat fee charged by some auction yards
- **Environmental fee**: Charged by some platforms for hazardous
  materials handling
- **Title processing fee**: For title transfer paperwork

### Transport Costs

- **Local pickup**: Buyer arranges their own transport; cost varies
  by distance and vehicle size
- **Towing for non-drivable vehicles**: $100–$500+ depending on
  distance
- **Shipping**: Some platforms (PropertyRoom, B-Stock) ship to the
  buyer; most auction vehicles require local pickup

## Why

Auction platforms are required to disclose fees, but the fees are
often scattered across multiple pages of terms and conditions. The
buyer's premium alone can add 10–16.5% to the winning bid. When
combined with taxes, title fees, transport, and repairs, the total
can be 30–60% higher than the winning bid.

Presenting only the winning bid in the Deal Intelligence Report
would mislead the user into thinking they can buy the item for that
price. The total acquisition cost is the number that matters for
budget comparison against retail and other sourcing channels.

## Context

- `auction-constraints.md` has a "Buyer's Premium & Total Cost"
  section with the full calculation formula
- `sourcing-sources.toml` has `buyer_premium` field for each source
- The Deal Intelligence Report template in `INSTRUCTIONS.md.tmpl`
  requires "Total Effective Cost" in the output
- Storage fees begin after the free pickup period — always state
  the pickup deadline in the report
