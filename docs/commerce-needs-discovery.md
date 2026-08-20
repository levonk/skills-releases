<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **commerce** · Status: ready · Version: 1.9.0

Discover and refine purchasing requirements through structured interviewing. Use when a user needs help figuring out what product or service to buy, needs to hire a service provider (plumber, electrician, contractor, tutor, etc.), has a problem that requires a purchase to solve, or has a vague idea of what they want but needs help narrowing it down. Covers: (1) timeline elicitation (nice-to-have vs essential deadlines), (2) product-vs-service classification, (3) intelligent numbered questions with lettered answer choices and pre-filled best-guess defaults, (4) problem-to-product/service mapping when the user describes a problem rather than a product, (5) alternative discovery when the user names a specific product, (6) product/service recommendation with comparative rationale, (7) constraint identification including known defects, version pitfalls, reliability issues, seller reputation, licensing/insurance requirements for services, and environmental hazards, (8) replacement part identification — when the user has a broken item, determines whether a specific replacement part is viable and researches the exact manufacturer part number for cheaper sourcing than model-name searches, including a repairability check that warns when components are soldered, glued, or cryptographically paired and cannot be user-replaced, including repair cost vs replacement cost analysis. (9) comprehensive constraint identification covering obsolescence risks (OS update horizon, company viability, cloud dependency death, ecosystem lock-in), used-specific risks (hidden damage, counterfeit, battery degradation, non-transferable warranty, recall non-compliance), total cost of ownership (subscription lock-in, cheap-to-buy-expensive-to-own, maintenance burden, disposal cost), environmental and situational mismatches, financial traps, safety/legal issues, and real estate constraints (zoning, terrain, access, utilities, title, toxicity, market risks). Uses progressive disclosure — an attribute index with applicability matrix so only relevant constraint files are loaded (e.g., a watch purchase loads repairability and TCO but not real estate or consumables; a property purchase loads real estate but not obsolescence). Includes service vendor tier differentiation (CPA vs bookkeeper, licensed electrician vs handyman) and consumables-specific constraints (shelf life, bulk economics, storage). Real estate is split into generic constraints plus sub-domains: residential (owner-occupied), investment (flip/hold/develop), rental (landlord), commercial (retail/ office/industrial), and leasee (tenant-side leasing). Product-specific domain files cover automobiles (EV/PHEV, hybrid, exotic, truck, RV), major appliances (HVAC, water heater, laundry, kitchen, refrigeration, spa, commercial vs consumer), small appliances, cameras, mobile phones, computers (laptops, desktops, Macs — including Activation Lock, MDM/ABM, firmware locks, and receipt retention for lock removal), collectibles, yard tools, computer parts (CPU/motherboard, GPU, RAM/storage, PSU/case/ cooling, monitor/peripherals), and tools (woodworking, metalworking, welding, gardening, pottery). Used-device lock verification (Activation Lock, iCloud, Find My, MDM/Remote Management, firmware/EFI, BitLocker, carrier IMEI blacklist) is covered with do-with-seller vs do-later in-person handoff steps. Leasee (tenant) is split into generic tenant constraints plus home rental, apartment rental, and commercial lease sub-domains. Section 5 documents the 3-level progressive disclosure chain (attribute index → attribute files → domain files) with worked examples.

## Metadata

| Field | Value |
|-------|-------|
| Name | `shopping-needs-discovery` |
| Category | `commerce` |
| Version | `1.9.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `commerce`
- `shopping`
- `needs-assessment`
- `product-research`

## Related Skills
- **shopping-deal-intelligence** (skill, dependent) — Consumes the Needs Discovery Brief to research pricing, sourcing, and timing
- **shopping-acquisition** (skill, dependent) — Final execution layer — completes purchases or service bookings identified by needs-discovery
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/commerce/needs-discovery/SKILL.md`](skills/commerce/needs-discovery/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-20T21:38:06Z
