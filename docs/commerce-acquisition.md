<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **commerce** · Status: ready · Version: 1.0.0

Execute the final purchase of a product or hiring of a service after research is complete. Use when the user knows what to buy/hire and at what price, and needs help with: (1) negotiation on behalf of the user for products or services that require it (luxury watches, cars, used goods, bulk purchases, contractors, service providers) — always disclosing agent status, (2) stock monitoring and rare-opportunity alerts for out-of-stock or scarce items, (3) auto-purchase execution when the user has pre-authorized conditions using their payment methods (credit cards and gift cards), (4) purchase notification with exact instructions when auto-buy is not enabled, (5) service provider booking with scope-of-work verification, deposit negotiation, and payment protection. This skill acts as the final execution layer of the personal shopper pipeline.

## Metadata

| Field | Value |
|-------|-------|
| Name | `shopping-acquisition` |
| Category | `commerce` |
| Version | `1.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `commerce`
- `negotiation`
- `purchasing`
- `stock-monitoring`
- `auto-buy`

## Related Skills
- **shopping-needs-discovery** (skill, dependency) — Discovers and refines purchasing requirements — feeds acquisition with product/service candidates
- **shopping-deal-intelligence** (skill, dependency) — Researches pricing, sourcing, and timing — produces the Deal Intelligence Report acquisition executes on
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/commerce/acquisition/SKILL.md`](skills/commerce/acquisition/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-12T19:44:04Z
