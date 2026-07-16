<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **commerce** · Status: ready · Version: 1.5.0

Research pricing, sourcing channels, and optimal purchase timing for products and services. Use after needs-discovery has identified candidate products, or when the user already knows what they want and needs help finding the best deal. Covers: (1) historical price research via CamelCamelCamel, Wayback Machine, closed auctions, and deal sites, (2) sourcing across retail, auctions, government surplus, neighborhood giveaways, and secondhand shops, (3) market timing based on seasonality, weather, economic indicators, search traffic, and regulatory changes, (4) purchase optimization via credit card benefits, affiliate cashback programs, gift card discounts, and extended warranty stacking, (5) part-number sourcing — when the Needs Discovery Brief includes a replacement part number, searches by the specific OEM part number across suppliers and cross-brand equivalents to avoid the convenience tax of model-name searches, (6) warranty comparison across suppliers, brands, and conditions with risk-adjusted cost analysis before the final recommendation, (7) cross-brand identical product identification — detects when differently-branded products are the same OEM product (Kenmore = Whirlpool, Acer GB10 = NVIDIA DGX Spark) via model prefix decoding, reference design matching, and FCC ID lookup, and compares them so the user can buy the cheaper rebrand when differences don't matter, including brand premium assessment for luxury and status goods (Rolex vs Grand Seiko, Le Creuset vs Lodge) to advise the user when similar quality is available for significantly less. For services, includes vendor tier verification (comparing quotes across CPA vs bookkeeper, licensed electrician vs handyman) before quote gathering.

## Metadata

| Field | Value |
|-------|-------|
| Name | `shopping-deal-intelligence` |
| Category | `commerce` |
| Version | `1.5.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `commerce`
- `pricing`
- `deal-hunting`
- `market-timing`
- `cashback`

## Related Skills
- **shopping-needs-discovery** (skill, dependency) — Discovers and refines purchasing requirements — feeds deal-intelligence with candidate products/services
- **shopping-acquisition** (skill, dependent) — Final execution layer — consumes the Deal Intelligence Report to negotiate, monitor, and complete purchases
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/commerce/deal-intelligence/SKILL.md`](skills/commerce/deal-intelligence/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-16T08:39:39Z
