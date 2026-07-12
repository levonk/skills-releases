<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **commerce** · Status: ready · Version: 1.0.0

Research pricing, sourcing channels, and optimal purchase timing for products and services. Use after needs-discovery has identified candidate products, or when the user already knows what they want and needs help finding the best deal. Covers: (1) historical price research via CamelCamelCamel, Wayback Machine, closed auctions, and deal sites, (2) sourcing across retail, auctions, government surplus, neighborhood giveaways, and secondhand shops, (3) market timing based on seasonality, weather, economic indicators, search traffic, and regulatory changes, (4) purchase optimization via credit card benefits, affiliate cashback programs, gift card discounts, and extended warranty stacking.

## Metadata

| Field | Value |
|-------|-------|
| Name | `shopping-deal-intelligence` |
| Category | `commerce` |
| Version | `1.0.0` |
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
- **Generated**: 2026-07-12T00:51:35Z
