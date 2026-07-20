<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **commerce** · Status: ready · Version: 1.8.0

Discover and refine purchasing requirements through structured interviewing. Use when a user needs help figuring out what product or service to buy, needs to hire a service provider (plumber, electrician, contractor, tutor, etc.), has a problem that requires a purchase to solve, or has a vague idea of what they want but needs help narrowing it down. Covers: (1) timeline elicitation (nice-to-have vs essential deadlines), (2) product-vs-service classification, (3) intelligent numbered questions with lettered answer choices and pre-filled best-guess defaults, (4) problem-to-product/service mapping when the user describes a problem rather than a product, (5) alternative discovery when the user names a specific product, (6) product/service recommendation with comparative rationale, (7) constraint identification including known defects, version pitfalls, reliability issues, seller reputation, licensing/insurance requirements for services, and environmental hazards, (8) replacement part identification — when the user has a broken item, determines whether a specific replacement part is viable and researches the exact manufacturer part number for cheaper sourcing than model-name searches, including a repairability check that warns when components are soldered, glued, or cryptographically paired and cannot be user-replaced, including repair cost vs replacement cost analysis. (9) comprehensive constraint identification covering obsolescence risks (OS update horizon, company viability, cloud dependency death, ecosystem lock-in), used-specific risks (hidden damage, counterfeit, battery degradation, non-transferable warranty, recall non-compliance), total cost of ownership (subscription lock-in, cheap-to-buy-expensive-to-own, maintenance burden, disposal cost), environmental and situational mismatches, financial traps, safety/legal issues, and real estate constraints (zoning, terrain, access, utilities, title, toxicity, market risks). Uses progressive disclosure — an attribute index with applicability matrix so only relevant constraint files are loaded (e.g., a watch purchase loads repairability and TCO but not real estate or consumables; a property purchase loads real estate but not obsolescence). Includes service vendor tier differentiation (CPA vs bookkeeper, licensed electrician vs handyman) and consumables-specific constraints (shelf life, bulk economics, storage). Real estate is split into generic constraints plus sub-domains: residential (owner-occupied), investment (flip/hold/develop), rental (landlord), commercial (retail/ office/industrial), and leasee (tenant-side leasing). Product-specific domain files cover automobiles (EV/PHEV, hybrid, exotic, truck, RV), major appliances (HVAC, water heater, laundry, kitchen, refrigeration, spa, commercial vs consumer), small appliances, cameras, mobile phones, collectibles, yard tools, computer parts (CPU/motherboard, GPU, RAM/ storage, PSU/case/cooling, monitor/peripherals), and tools (woodworking, metalworking, welding, gardening, pottery). Leasee (tenant) is split into generic tenant constraints plus home rental, apartment rental, and commercial lease sub-domains. Section 5 documents the 3-level progressive disclosure chain (attribute index → attribute files → domain files) with worked examples.

## Metadata

| Field | Value |
|-------|-------|
| Name | `shopping-needs-discovery` |
| Category | `commerce` |
| Version | `1.8.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `commerce`
- `shopping`
- `needs-assessment`
- `product-research`

## Core Workflow

### 1. Timeline Elicitation

Establish two dates immediately:

| Date | Meaning | Example prompt |
|------|---------|----------------|
| **Nice-to-have** | When life would be easier with the solution | "When would it be *nice* to have this?" |
| **Essential** | Hard deadline after which the need becomes critical | "When is it *essential* — what breaks if you don't have it?" |

Use these dates to gate urgency throughout all downstream skills (deal-intelligence timing, acquisition auto-buy thresholds).

### 2. Intelligent Questioning

Present questions in numbered format with lettered answer choices. Pre-fill best-guess answers based on context so the user can confirm or override. Limit to 3–5 questions per round; follow up if needed.

For the full questioning format example, rules, and product-vs-service classification table, see `references/questioning-examples.md`.

### 2.5. Product vs Service Classification

Before deep questioning, classify the request as **Product**, **Service**, or **Both**. For services, add scope-of-work, urgency, previous-provider, and license/insurance questions to the intelligent questioning round.

For the full classification table and service-specific questions, see `references/questioning-examples.md`.

### 2.6. Replacement Part vs Full Product

When the user describes a **broken or malfunctioning item** they already own,
determine whether they need a specific replacement part or a whole new
product. If a replacement part is viable, identify the **exact manufacturer
part number** — not just the product model number. Searching by part number
yields dramatically cheaper sourcing than searching by model name (model
searches surface pre-packaged repair kits with a convenience markup; part
number searches surface the raw OEM component from multiple suppliers).

For the part-vs-product decision matrix, **repairability check** (verifying
the component is actually user-replaceable — some modern devices have
soldered, glued, or cryptographically paired components that cannot be
swapped), part-number identification workflow, and part number sources
(service manuals, iFixit, parts diagrams, device labels, FCC ID lookup), see
`references/part-identification.md`.

When part identification succeeds, include a `Replacement Part` section in the
Needs Discovery Brief (see the reference for the format) so deal-intelligence
can search by part number instead of model number.

### 2.7. Spec Interpretation — Floors vs Ceilings

Numeric specs the user states (range, capacity, mileage, RAM, storage, power,
runtime, MPG, towing, resolution, etc.) are **minimums (floors)**, not target
values. A product that exceeds a stated spec at equal or better value is a
**benefit**, not a mismatch — surface it and flag the upgrade. Do not narrow
the candidate pool to items that merely match the spec; rank by value
(price ÷ delivered capability), not by closeness to the number the user said.

**Treat a spec as a ceiling (maximum) only when the user explicitly caps it**,
using language like "only", "at most", "no more than", "exactly", "ceiling",
"don't need more than", or "keep it under". Absent an explicit cap, assume floor.

This rule exists because reading a spec as a target produces bad outcomes: a
request for "a BEV with ~90 miles of range" is a request for *at least* enough
range to cover the user's daily driving at a good price — a 200-mile EV priced
below a rare 90-mile model is the better recommendation, not a miss. The user's
number reflects a *need*, not a *limit*.

When the floor interpretation would surprise the user (e.g., the best-value
candidate far exceeds the stated spec), state the assumption explicitly in the
brief and let the user correct it: "Treating 90 mi as a minimum; the best value
is a 220-mi EV at $X — say 'only ~90 mi' if you want a hard cap."

Record every numeric spec in the Needs Discovery Brief as either `min: <value>`
(default) or `ceiling: <value>` (only when the user capped it) so downstream
deal-intelligence cannot misread the intent.

### 3. Problem-to-Product/Service Mapping

When the user describes a **problem** rather than a product or service: restate the problem, identify 2–5 solution categories (both "buy a thing" and "hire someone" where applicable), rank by fit/cost/timeline, and present as a decision table.

For the decision table format example, see `references/questioning-examples.md`.

### 3.5. Alternative Discovery

When the user **names a specific product** (e.g., "I want to buy a Dyson V15"): acknowledge the pick, research alternatives from authoritative sources (Consumer Reports, Wirecutter, Reddit, YouTube reviewers), and present as a comparison table.

For the comparison table format example and skip conditions, see `references/questioning-examples.md`.

### 4. Product/Service Recommendation with Rationale

Once the category is locked, recommend 2–4 specific products or service providers:

- **Why chosen**: 2–3 sentences per pick linking back to user requirements
- **Why not alternatives**: Brief explanation of why each major alternative was rejected (e.g., "Brand X has a known firmware issue on v3.2 that causes overheating", "Brand Y discontinued support in 2025")
- **Comparison matrix** using the standard iconography:

---
description: Shared commerce rating icons for product/service comparison and deal assessment — ⭐ best in class, ☑️ good/acceptable, ⚠️ caution/trade-off, ❌ deal-breaker. Use in needs-discovery, deal-intelligence, and acquisition skills.
---

# Commerce Rating Icons

Use these icons when rating products, services, or deals in commerce skills.
The 4-level scale captures purchase-relevant distinctions from best-in-class
to deal-breaker.

| Icon | Meaning | Criteria |
|---|---|---|
| ⭐ | **Best in class** | Top recommendation — excels on the user's priority requirements |
| ☑️ | **Good / acceptable** | Meets requirements adequately — solid choice, no standout advantage |
| ⚠️ | **Caution / trade-off** | Usable but has a known trade-off, risk, or caveat — proceed with eyes open |
| ❌ | **Deal-breaker** | Fails a hard requirement — disqualify or reject |

## Related Skills
- **shopping-deal-intelligence** (skill, dependent) — Consumes the Needs Discovery Brief to research pricing, sourcing, and timing
- **shopping-acquisition** (skill, dependent) — Final execution layer — completes purchases or service bookings identified by needs-discovery
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/commerce/needs-discovery/SKILL.md`](skills/commerce/needs-discovery/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-07-20T22:00:35Z
