<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **commerce** · Status: ready · Version: 1.8.0

Research pricing, sourcing channels, and optimal purchase timing for products and services. Use after needs-discovery has identified candidate products, or when the user already knows what they want and needs help finding the best deal. Covers: (1) historical price research via CamelCamelCamel, Wayback Machine, closed auctions, and deal sites, (2) sourcing across retail, auctions, government surplus, neighborhood giveaways, and secondhand shops, (3) market timing based on seasonality, weather, economic indicators, search traffic, and regulatory changes, (4) purchase optimization via credit card benefits, affiliate cashback programs, gift card discounts, and extended warranty stacking, (5) part-number sourcing — when the Needs Discovery Brief includes a replacement part number, searches by the specific OEM part number across suppliers and cross-brand equivalents to avoid the convenience tax of model-name searches, (5a) salvage yard sourcing — searches Pick Your Part (pyp.com) inventory across all California yards for any vehicle make/model via `search_pyp_inventory.py`, sorted by distance from user zip code, with yard visit protocol and part removal safety guidance, including fuel cell vehicle reference data (Toyota Mirai, Hyundai Nexo, Honda Clarity Fuel Cell part numbers and vehicle catalog), (6) warranty comparison across suppliers, brands, and conditions with risk-adjusted cost analysis before the final recommendation, (7) cross-brand identical product identification — detects when differently-branded products are the same OEM product (Kenmore = Whirlpool, Acer GB10 = NVIDIA DGX Spark) via model prefix decoding, reference design matching, and FCC ID lookup, and compares them so the user can buy the cheaper rebrand when differences don't matter, including brand premium assessment for luxury and status goods (Rolex vs Grand Seiko, Le Creuset vs Lodge) to advise the user when similar quality is available for significantly less, (8) auction-specific constraints and participation — when sourcing through auction channels (Copart, IAAI, GSA Auctions, GovDeals, GovPlanet, US Marshals, Treasury/IRS, county tax deed, state surplus, and 40+ other platforms), loads vehicle auction constraints (smog/CARB compliance for California and strict-emissions states, export-only restrictions, salvage/rebuilt title brands, damage level opt-in, dealer license requirements), property auction constraints (buildability checklist: ingress, topography, zoning, lot dimensions, airspace/underground easements, water, electricity, sewage, trash, roads; title risks at auction; risk levels by auction type), universal auction constraints (locale/travel, registration gating, total acquisition cost calculation), and detailed step-by-step participation instructions for each platform. For services, includes vendor tier verification (comparing quotes across CPA vs bookkeeper, licensed electrician vs handyman) before quote gathering. (9) acquisition-strategy analysis — compares lease vs finance (incl. 0% APR) vs buy-new vs buy-refurbished vs buy-used/liquidation on a tax-adjusted NPV basis, factoring Section 179 / MACRS depreciation at an effective tax rate, sales-tax avoidance on used (e.g., California private-party), residual/resale value, upgrade-cycle frequency, and "new version imminent" depreciation cliffs. Includes a deterministic calculator (`scripts/acquisition_strategy.py`) and a worked MacBook Pro M5 Max vs Mac Studio M3 Ultra vs wait-for-M5-Ultra example covering Apple's full acquisition stack (buy/finance/lease/refurbished/trade-in + 3% Apple Card). Cross-links lock-verification for used Macs/phones (Activation Lock, MDM/ABM, firmware, carrier IMEI blacklist). Do NOT trigger on general shopping questions, product recommendations without research, or one-off price checks under $50 — this skill is for structured deal research after needs-discovery has identified candidates (or the user already knows what they want and needs the best deal).

## Metadata

| Field | Value |
|-------|-------|
| Name | `shopping-deal-intelligence` |
| Category | `commerce` |
| Version | `1.8.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `commerce`
- `pricing`
- `deal-hunting`
- `market-timing`
- `cashback`
- `auctions`
- `government-surplus`
- `salvage-yards`
- `part-number-sourcing`
- `acquisition-strategy`
- `lease-vs-buy`
- `tax-adjusted-tco`

## Related Skills
- **shopping-needs-discovery** (skill, dependency) — Discovers and refines purchasing requirements — feeds deal-intelligence with candidate products/services
- **shopping-acquisition** (skill, dependent) — Final execution layer — consumes the Deal Intelligence Report to negotiate, monitor, and complete purchases
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/commerce/deal-intelligence/SKILL.md`](skills/commerce/deal-intelligence/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-20T21:56:40Z
