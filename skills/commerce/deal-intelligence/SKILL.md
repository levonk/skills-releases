---
name: shopping-deal-intelligence
description: >
  Research pricing, sourcing channels, and optimal purchase timing for products
  and services. Use after needs-discovery has identified candidate products, or
  when the user already knows what they want and needs help finding the best
  deal. Covers: (1) historical price research via CamelCamelCamel, Wayback
  Machine, closed auctions, and deal sites, (2) sourcing across retail,
  auctions, government surplus, neighborhood giveaways, and secondhand shops,
  (3) market timing based on seasonality, weather, economic indicators, search
  traffic, and regulatory changes, (4) purchase optimization via credit card
  benefits, affiliate cashback programs, gift card discounts, and extended
  warranty stacking.
version: 1.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2026-03-24"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "commerce", "pricing", "deal-hunting", "market-timing", "cashback"]
see-also:
  - skill: "shopping-needs-discovery"
    relationship: "dependency"
    description: "Discovers and refines purchasing requirements — feeds deal-intelligence with candidate products/services"
  - skill: "shopping-acquisition"
    relationship: "dependent"
    description: "Final execution layer — consumes the Deal Intelligence Report to negotiate, monitor, and complete purchases"
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
dependencies:
  - type: skill
    name: shopping-needs-discovery
  - type: skill
    name: shopping-acquisition
  - type: url
    name: CamelCamelCamel
    url: https://camelcamelcamel.com/
  - type: url
    name: Slickdeals
    url: https://slickdeals.net/
  - type: url
    name: Wayback Machine
    url: https://web.archive.org/
  - type: url
    name: Google Shopping
    url: https://shopping.google.com/
  - type: url
    name: Rakuten
    url: https://www.rakuten.com/
  - type: url
    name: Capital One Shopping
    url: https://capitaloneshopping.com/
  - type: url
    name: Chase Offers
    url: https://www.chase.com/personal/chase-offers
  - type: url
    name: Bing Shopping Cashback
    url: https://www.bing.com/shop
  - type: url
    name: GovPlanet (Gov Surplus)
    url: https://www.govplanet.com/
  - type: url
    name: GSA Auctions
    url: https://gsaauctions.gov/
  - type: url
    name: GovDeals
    url: https://www.govdeals.com/
---

{{{ include "includes/base-ai-guidance.md" . }}}

# Shopping Deal Intelligence

Comprehensive pricing research, sourcing, timing analysis, and purchase optimization engine. Operates on the output of the needs-discovery skill.

## Effort Tier Awareness

This skill respects the effort tier from Phase 0:

| Tier | What to run | What to skip |
|------|-----------|---------------|
| **Quick** (under $50) | Current price from 2–3 sources, obvious coupon/cashback, best card from `payment_methods` | Historical pricing, market timing, deep sourcing, negotiation |
| **Standard** ($50–$500) | All 4 sections; moderate depth | Deep market timing signals (macro-economic, ad cost) |
| **Major** ($500–$5k) | Full depth on all sections | Nothing |
| **High-value** ($5k+) | Full depth + legal/warranty deep-dive | Nothing |

## Core Workflow — Products

### 1. Historical Price Research

For each candidate product, build a **price history profile** using CamelCamelCamel, Wayback Machine, Slickdeals, closed auction data, Google Shopping, and supplementary trackers (Honey/Keepa).

For the full source comparison table and price summary output format, see `references/price-research.md`.

### 2. Sourcing Channels

Search across all viable channels, ranked by price advantage:

- **Retail**: Amazon, Walmart, Target, Best Buy, Costco, B&H Photo, manufacturer direct
- **Auctions**: eBay, Catawiki, Heritage Auctions, Sotheby's (luxury), Bonhams
- **Government surplus**: [GSA Auctions](https://gsaauctions.gov/), [GovDeals](https://www.govdeals.com/), [GovPlanet](https://www.govplanet.com/), local municipality surplus sales
- **Neighborhood / local**: Facebook Marketplace, Craigslist, Nextdoor, OfferUp, local buy-nothing groups, estate sales, garage sales
- **Secondhand / refurbished**: [Back Market](https://www.backmarket.com/), [Swappa](https://swappa.com/), Goodwill, Habitat for Humanity ReStore, manufacturer refurbished programs
- **Wholesale / bulk**: Alibaba (MOQ items), restaurant supply stores, industrial surplus
- **Specialty**: Manufacturer outlet stores, B-stock liquidation, open-box deals at retailers

For detailed sourcing strategies by product category, see `references/sourcing-guide.md`.

### 3. Market Timing Analysis

Determine optimal purchase window based on multiple signals: seasonality, upcoming weather, economic cycle, search traffic, ad cost signals, product lifecycle, retail calendar, regulatory changes, and inventory signals.

For the full signal-to-action matrix, timing recommendation output format, and monthly buying calendar, see `references/market-timing.md`.

### 4. Purchase Optimization Stack

Layer savings mechanisms (gift card discounts, cashback portals, credit card category bonuses, card benefits, coupon stacking, price matching) to minimize total out-of-pocket cost.

For the step-by-step optimization procedure, savings stack output format, and card selection logic from `payment_methods`, see `references/purchase-optimization.md`.

## Core Workflow — Services

When the Needs Discovery Brief indicates **Type: Service** or **Type: Both**:

### S1. Quote Gathering

Identify 3+ providers through multiple channels:

| Channel | Best for | Notes |
|---------|----------|-------|
| [Thumbtack](https://www.thumbtack.com/) | Home services, events, lessons | Instant quotes; pro profiles |
| [Angi](https://www.angi.com/) | Contractors, plumbing, electrical, HVAC | Background-checked pros |
| [Google Local Services](https://ads.google.com/local-services-ads/) | Emergency services, quick hires | Google Guaranteed badge |
| [Yelp](https://www.yelp.com/) | Restaurants, salons, niche services | Deep review history |
| [Nextdoor](https://nextdoor.com/) | Neighborhood recommendations | Hyper-local; word-of-mouth |
| [HomeAdvisor](https://www.homeadvisor.com/) | Large home projects | Cost guides by zip code |
| Direct referral | When user has a network | Often best quality; ask user |

### S2. Provider Vetting

For each candidate provider, verify:

- **License**: Active and valid for the jurisdiction; check state licensing board
- **Insurance**: General liability + workers' comp (request certificate of insurance)
- **Bonding**: Required for certain trades (plumbing, electrical, roofing)
- **Reviews**: Aggregate across Google, Yelp, Angi, BBB; look for patterns, not just stars
- **Complaint history**: BBB complaints, state AG complaints, Yelp filtered reviews
- **Tenure**: How long in business? Avoid fly-by-night operations for major work

**Red flag scoring:**

| Red Flag | Severity |
|----------|----------|
| No license when required by law | ❌ Disqualify |
| No insurance | ❌ Disqualify |
| Demands full payment upfront | ❌ Disqualify |
| No written estimate | ⚠️ Major concern |
| Reviews mention no-shows or ghosting | ⚠️ Major concern |
| Only cash, no receipt | ⚠️ Major concern |
| Very new with no reviews | ☑️ Caution — may be fine, get references |

### S3. Pricing Benchmarks

Research typical cost ranges for the service in the user's area:

- [HomeAdvisor Cost Guides](https://www.homeadvisor.com/cost/) — zip-code-level estimates
- [Thumbtack Price Estimates](https://www.thumbtack.com/costs/) — category-specific
- [Angi Cost Guides](https://www.angi.com/cost/) — project-specific breakdowns
- Local forum / Nextdoor posts — what neighbors actually paid

**Flag outlier quotes:**
- Too low (≥30% below average): Likely cutting corners, unlicensed, or bait-and-switch
- Too high (≥50% above average): Premium markup or emergency surcharge; ask why

### S4. Service Timing

| Factor | Impact |
|--------|--------|
| **Off-season** | HVAC in spring, roofing in winter, landscaping in late fall — 10–25% lower |
| **Emergency surcharge** | After-hours plumbing/electrical — 50–100% premium; schedule if possible |
| **Peak season** | Post-storm roofing, summer AC, winter heating — long waits, premium pricing |
| **End of week** | Some contractors offer Friday/Saturday discounts to fill schedule gaps |

### S5. Service Payment Optimization

- Use credit card with **purchase/dispute protection** (Amex is strongest for contractor disputes)
- Never pay full amount upfront; standard is 10–30% deposit, balance on completion
- Get **scope of work in writing** before payment
- Use credit card with **extended warranty** if the service includes equipment installation
- Some services qualify for cashback portals (e.g., Rakuten has home services partners)

## Output Format

Deliver a **Deal Intelligence Report**:

```markdown
## Deal Intelligence Report

### Effort Tier: [Quick | Standard | Major | High-value]

### Price Analysis (products)
[Price summary table]

### Quote Comparison (services)
| Provider | Quote | Licensed | Insured | Rating | Red Flags |
|----------|-------|----------|---------|--------|-----------|

### Best Sources / Providers
| Rank | Source/Provider | Price/Quote | Condition | Notes |
|------|----------------|-------------|-----------|-------|

### Timing
[Timing recommendation block]

### Optimization Stack
[Savings stack table — includes payment_methods card selection rationale]

### Total Effective Cost: $X.XX (Y% below retail/first-quote)

### Next Step
→ Hand off to shopping-acquisition skill for purchase execution
```

## Resources

- `references/price-research.md` — Price history source comparison and price summary output format
- `references/sourcing-guide.md` — Detailed sourcing strategies by product category
- `references/market-timing.md` — Timing signal matrix, monthly buying calendar, and signal interpretation
- `references/purchase-optimization.md` — Optimization stack steps, savings stack format, card selection logic, cashback portal comparison, credit card benefit matrices

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/commerce/deal-intelligence/SKILL.md`
- References: `references/price-research.md`, `references/sourcing-guide.md`, `references/market-timing.md`, `references/purchase-optimization.md`

### Related Skills
- `shopping-needs-discovery` (dependency) — discovers and refines purchasing requirements
- `shopping-acquisition` (dependent) — final execution layer that consumes the Deal Intelligence Report
- `base-ai-guidance` (base-framework) — shared framework for all AI guidance types

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles

<!-- vim: set ft=markdown -->
