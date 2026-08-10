---
type: Practice
title: Salvage and Rebuilt Title Brands
description: Auction vehicles frequently have branded titles with significant implications for financing, insurance, and resale.
tags: [auctions, vehicles, salvage-title, rebuilt-title, title-brands]
date:
  created: "2026-08-07"
  knowledge-basis: "2026-08-07"
  last-used: "2026-08-07"
sources:
  - id: auction-constraints-reference
    resource: skills/commerce/deal-intelligence/references/auction-constraints.md
    title: auction-constraints.md
---

# Salvage and Rebuilt Title Brands

## Failure Mode

A buyer purchases a vehicle at auction assuming it has a clean title.
After winning, they discover the vehicle has a salvage or rebuilt
title brand. This affects financing (banks won't finance salvage
titles), insurance (may be limited to liability only), and resale
value (drops 20–40%). Some title brands (junk, certificate of
destruction) mean the vehicle cannot be registered at all.

## Practice

**Check the title brand before bidding. Ask the user whether they
are willing to accept a branded title.**

1. **Identify the title brand**: Auction listings disclose the title
   brand. Know the types:
   - **Clean**: No major damage history; standard registration
   - **Salvage**: Declared a total loss; cannot be driven; must be
     rebuilt and pass state inspection to get a rebuilt title
   - **Rebuilt/Reconstructed**: Salvage vehicle repaired and
     inspected; can be registered but financing/insurance/resale
     are affected
   - **Junk**: Parts only; cannot be rebuilt or titled
   - **Certificate of destruction**: Destroyed; parts/scrap only
   - **Bill of sale only**: No title; common in tow yard/abandoned
     vehicle sales; user must apply for a title through the state's
     abandoned vehicle process (can take months)

2. **Ask the user**: Before recommending a branded-title vehicle,
   ask whether they are willing to repair and rebuild a salvage
   vehicle, or accept the financing/insurance/resale implications
   of a rebuilt title.

3. **If not → exclude**: Exclude salvage/rebuilt/junk title vehicles
   from recommendations if the user wants a clean title.

4. **If yes → add repair costs**: Add estimated repair costs to the
   total acquisition cost and note the state's rebuild inspection
   requirements.

5. **Always recommend a NICB VINCheck**: Use
   [vincheck.nicb.org](https://vincheck.nicb.org/) to verify title
   status and theft/total-loss history.

## Why

Title brands are permanent — once a vehicle is branded salvage, the
brand stays on the title forever (even after rebuilding). The
implications are significant:

- **Financing**: Most banks will not finance a salvage or rebuilt
  title vehicle. Buyers need cash or specialized lenders.
- **Insurance**: Many insurers will only write liability coverage
  for rebuilt titles, not comprehensive or collision.
- **Resale**: Rebuilt titles reduce resale value by 20–40%.
- **Safety**: Salvage vehicles may have hidden structural damage
  that was not properly repaired.

## Context

- `auction-constraints.md` has a "Salvage & Rebuild Titles" table
  with all title brand types and their implications
- `sourcing-sources.toml` uses `salvage_sales = true` to flag
  platforms that sell salvage vehicles (Copart, IAAI)
- The `needs-discovery` skill's `domains/automobiles/index.md` flags
  salvage/rebuilt titles as a key question for auction vehicle buyers
- NICB VINCheck is free and covers theft and total-loss records
