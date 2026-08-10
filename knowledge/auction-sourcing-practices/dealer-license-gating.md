---
type: Practice
title: Dealer License Gating
description: Some auction sales require a dealer license; public buyers can use a dealer agent/broker or stick to public-access sales.
tags: [auctions, vehicles, dealer-license, broker, registration-gating]
date:
  created: "2026-08-07"
  knowledge-basis: "2026-08-07"
  last-used: "2026-08-07"
sources:
  - id: auction-constraints-reference
    resource: skills/commerce/deal-intelligence/references/auction-constraints.md
    title: auction-constraints.md
  - id: auction-participation-reference
    resource: skills/commerce/deal-intelligence/references/auction-participation.md
    title: auction-participation.md
---

# Dealer License Gating

## Failure Mode

A public buyer finds a vehicle at Copart or IAAI that they want to
bid on. They register for an account, but discover that the specific
sale is "Dealer Only" — they cannot bid without a valid dealer
license. They either miss the opportunity or try to find a way to
bid after the fact, which is too late.

## Practice

**Check registration gating before recommending an auction. Flag
dealer-only sales and offer the dealer agent/broker workaround.**

1. **Classify the auction's registration tier**:
   - **Open to public**: Anyone can register and bid (GSA Auctions,
     GovDeals, GovPlanet, most state surplus)
   - **Dealer-only**: Requires a valid dealer license (some Copart
     and IAAI sales)
   - **Reseller-only**: Requires EIN/tax ID (B-Stock, some
     Liquidation.com storefronts)
   - **Export-only**: Vehicle must be exported (see
     [Export-Only Vehicle Restrictions](export-only-vehicle-restrictions.md))
   - **Salvage-only**: Vehicle is salvage; cannot be driven (see
     [Salvage and Rebuilt Title Brands](salvage-rebuilt-title-brands.md))

2. **Flag in the Deal Intelligence Report**: If an auction is
   dealer-only or reseller-only, flag it clearly.

3. **Ask the user**: Ask whether they have the required credential
   before proceeding.

4. **If the user lacks the credential**:
   - Exclude the auction from recommendations unless the user
     explicitly says they're willing to obtain the credential
   - For dealer-only sales, offer the dealer agent/broker workaround:
     - Find a licensed dealer who offers broker services
     - The dealer bids on the user's behalf ($300–$800 per vehicle)
     - The vehicle is titled in the dealer's name, then reassigned
     - Verify the dealer's license is active with the state DMV
     - Get the arrangement in writing

5. **Document in `sourcing-sources.toml`**: Use
   `requires_dealer_license = true` and `requires_reseller = true`
   to flag gated platforms.

## Why

Dealer-only sales exist because insurance companies and some
government agencies restrict certain inventory to licensed dealers
to ensure the vehicles are properly reconditioned, titled, and
sold through regulated channels. This protects the public from
unsafe vehicles but also blocks legitimate public buyers from
accessing inventory.

The dealer agent/broker workaround is a legal and common practice.
The dealer is the legal buyer of record; they then reassign the
title to the end user. The fee ($300–$800) is the cost of accessing
dealer-only inventory without obtaining a dealer license.

## Context

- `auction-constraints.md` has a "Registration Gating" table with
  all tiers and additional steps
- `auction-participation.md` has a "Copart / IAAI with a Dealer
  Agent (Broker)" section with the full broker process
- `sourcing-sources.toml` uses `requires_dealer_license` and
  `requires_reseller` fields
- Copart offers Basic (free) and Advanced ($59/year) public
  memberships with partial access; dealer license is only needed
  for dealer-only sales
