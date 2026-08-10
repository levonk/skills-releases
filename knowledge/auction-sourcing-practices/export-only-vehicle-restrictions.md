---
type: Practice
title: Export-Only Vehicle Restrictions
description: Some auction vehicles cannot be titled in the US; the buyer must export them within 30-90 days.
tags: [auctions, vehicles, export-only, title-restrictions]
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

# Export-Only Vehicle Restrictions

## Failure Mode

A buyer purchases a vehicle at Copart or IAAI, planning to register
and drive it domestically. After winning the auction, they discover
the vehicle is flagged "Export Only" — it cannot be titled or
registered in the US. The buyer must either export the vehicle
outside the country within 30–90 days or forfeit it. The auction
sale is final; there is no return.

## Practice

**Check for export-only restrictions before bidding. Flag
export-only vehicles in the Deal Intelligence Report.**

1. **Check the listing**: Copart and IAAI listings flag
   export-only vehicles with "Export Only" or "Export Only (Title
   Delayed)" in the title or sale terms section.

2. **Ask the user**: Before recommending an export-only vehicle,
   ask whether the user is buying for export or domestic use.

3. **If domestic use → exclude**: Export-only vehicles are a
   deal-breaker for domestic use. Exclude them from recommendations.

4. **If export → document the process**: The user must sign an
   export-only affidavit and provide proof of export within 30–90
   days. For "Title Delayed" sales, the title is held until proof
   of export is provided.

5. **Flag in `sourcing-sources.toml`**: Platforms with
   `export_only_sales = true` (Copart, IAAI) may have export-only
   inventory. Check each listing individually.

## Why

Export-only restrictions exist because some insurance companies and
government agencies require that certain vehicles (particularly
high-value or theft-recovery vehicles) leave the US to prevent
re-fraud or re-registration with a washed title. The restriction is
a legal condition of sale, not a mechanical issue — the vehicle may
be perfectly drivable, but it cannot be legally titled domestically.

## Context

- `auction-constraints.md` has an "Export-Only Vehicles" table with
  flag meanings and user actions
- `sourcing-sources.toml` uses `export_only_sales = true` to flag
  platforms that may have export-only inventory
- Copart and IAAI are the primary platforms with export-only sales
- The `needs-discovery` skill's `domains/automobiles/index.md` flags
  export-only as a key question for auction vehicle buyers
