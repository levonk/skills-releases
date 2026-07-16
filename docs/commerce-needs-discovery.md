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
  - ⭐ Best in class
  - ☑️ Good / acceptable
  - ⚠️ Caution / trade-off
  - ❌ Deal-breaker

### 5. Constraint Identification

Proactively research and surface constraints before the user asks. The
constraint system uses **3-level progressive disclosure**:

1. **Level 1 — Attribute index** (`references/constraint-attributes.md`):
   Always loaded. Contains an applicability matrix mapping purchase types
   to relevant attributes and domain files. The AI reads this to determine
   which files to load next.
2. **Level 2 — Attribute files** (`references/attributes/*.md`): Loaded
   when the attribute applies to the purchase type. Each file covers one
   cross-cutting constraint (obsolescence, repairability, TCO, used risks,
   situational fit).
3. **Level 3 — Domain files** (`references/domains/*.md` or
   `references/domains/<category>/index.md` + sub-domains): Loaded when the
   purchase matches a product domain. Domain files contain
   product-specific constraints that don't apply elsewhere. Some domains
   have their own sub-domain index (e.g., real-estate, automobiles,
   appliances, computer-parts, tools, leasee) — load the domain index first,
   then the specific sub-domain.

**Load only the files that apply to the current purchase type.** Examples:

- A **watch** purchase: Level 1 index → Level 2 repairability + TCO → Level
  3 collectibles (if luxury). No real estate, no consumables, no
  obsolescence (mechanical).
- A **property purchase**: Level 1 index → Level 2 (none needed for raw
  land) → Level 3 `real-estate/index.md` (generic) → `real-estate/
  residential.md` (if buying a home). No obsolescence, no consumables.
- **Renting an apartment**: Level 1 index → Level 3 `real-estate/index.md`
  (generic) → `real-estate/leasee/index.md` (generic tenant) →
  `real-estate/leasee/apartment.md` (apartment-specific). No repairability,
  no obsolescence.
- A **food/consumable** purchase: Level 1 index → Level 3 `consumables.md`.
  No repairability, no obsolescence, no warranty.
- A **service** hire: Level 1 index → Level 3 `services.md` (including
  vendor tier differentiation — CPA vs bookkeeper, licensed electrician vs
  handyman). No repairability or obsolescence.
- A **used laptop**: Level 1 index → Level 2 obsolescence + repairability +
  TCO + used-risks → Level 3 `computer-parts/` (if building). No real
  estate, no consumables.
- An **EV purchase**: Level 1 index → Level 2 obsolescence + repairability
  + TCO + used-risks (if used) + situational-fit (charging infra) → Level 3
  `automobiles/index.md` + `automobiles/ev-phev.md`.

The index file contains an applicability matrix showing which attributes
apply to common purchase types. Attribute and domain reference files:

- `attributes/obsolescence.md` — OS/firmware update horizon, company
  viability (cloud device bricking), ecosystem lock-in, right-to-repair
  hostility
- `attributes/repairability.md` — iFixit scores, parts availability,
  service network, soldered/paired/glued components, repairability tiers
- `attributes/total-cost-of-ownership.md` — subscription lock-in,
  cheap-to-buy-expensive-to-own, maintenance burden, disposal cost,
  depreciation cliff, TCO calculation
- `attributes/used-risks.md` — buy-new-vs-used rules, hidden damage,
  non-transferable warranty, counterfeit risk, battery degradation,
  title/ownership issues, recall non-compliance, banned substances
- `attributes/situational-fit.md` — climate mismatch, infrastructure
  dependency, space/installation constraints, financial traps
- `domains/real-estate/index.md` — generic real estate constraints (zoning,
  terrain, soil, flood, wetlands, access, utilities, HOA/CC&Rs, mineral
  rights, easements, toxicity, market risks) + sub-domain index
- `domains/real-estate/residential.md` — owner-occupied: schools, commute,
  neighborhood, property condition, HOA livability, financing, resale
- `domains/real-estate/investment.md` — appreciation/ROI: cap rate, cash
  flow, market analysis, exit strategy, risk factors
- `domains/real-estate/rental.md` — landlord: tenant law, rent control,
  eviction, vacancy, property management, tenant screening, insurance, tax
- `domains/real-estate/commercial.md` — commercial: property types, Phase
  I/II environmental, zoning/use, lease types (NNN/gross), tenant credit,
  ADA, TI, financing
- `domains/real-estate/leasee/index.md` — generic tenant constraints: lease
  terms, rent escalation, key provisions, hidden costs, tenant rights,
  negotiation leverage + sub-domain index
- `domains/real-estate/leasee/home.md` — house rental: maintenance
  responsibility split, higher utilities, driveway/garage parking, private
  landlord vs property management, privacy, HOA considerations, neighborhood
- `domains/real-estate/leasee/apartment.md` — apartment rental: noise
  (shared walls, upstairs, hallway), parking scarcity, amenities, building
  management quality, move-in logistics, unit-specific checks, renewal
- `domains/real-estate/leasee/commercial.md` — commercial lease: NNN/gross/
  modified gross, TI negotiation, exclusive use, co-tenancy, personal
  guarantee, percentage rent, customer parking
- `domains/services.md` — vendor tier differentiation (CPA vs bookkeeper,
  electrician vs handyman), licensing, insurance/bonding, permits,
  complaint history, seasonal availability, red flags
- `domains/consumables.md` — shelf life, bulk economics, quality/sourcing,
  storage requirements
- `domains/automobiles/index.md` — generic vehicle constraints (title, VIN,
  recalls, PPI, insurance, financing, depreciation) + sub-domain index
- `domains/automobiles/ev-phev.md` — EV/PHEV: charging, battery health, range,
  tax credits, software horizon
- `domains/automobiles/hybrid.md` — hybrid battery, regen braking, inverter,
  CVT, warranty
- `domains/automobiles/exotic.md` — specialist mechanic, parts, maintenance
  costs, insurance, storage
- `domains/automobiles/truck.md` — payload, towing, diesel vs gas, bed/cab
  configurations
- `domains/automobiles/rv.md` — Class A/B/C, systems, winterization, storage,
  depreciation, roof/tire maintenance
- `domains/appliances/index.md` — generic appliance constraints (energy,
  sizing, delivery, warranty, reliability) + sub-domain index
- `domains/appliances/hvac.md` — SEER2, sizing, refrigerant, ductwork, heat
  pump cold climate
- `domains/appliances/water-heater.md` — tank vs tankless, fuel types, sizing,
  venting
- `domains/appliances/laundry.md` — washer/dryer/combo, front vs top load, gas
  vs electric vs heat pump
- `domains/appliances/kitchen.md` — dishwasher, range/oven, pizza oven, gas vs
  induction
- `domains/appliances/refrigeration.md` — fridge configs, freezer, compressor,
  warranty
- `domains/appliances/spa.md` — sauna (traditional vs infrared), hot tub
  electrical/chemistry/permits
- `domains/appliances/commercial-vs-consumer.md` — durability, NSF, electrical,
  warranty, when to buy commercial
- `domains/small-appliances.md` — blender, food processor, pressure cooker,
  fryer, mixer, meat grinder
- `domains/cameras.md` — DSLR/mirrorless/compact/action, sensor, lens
  ecosystem, used checks
- `domains/mobile-phones.md` — OS horizon, battery health, carrier
  compatibility, repairability, used red flags
- `domains/collectibles.md` — authentication, grading, provenance, storage,
  insurance, liquidity, fakes
- `domains/yard-tools.md` — mowers, trimmers, blowers, chainsaws, gas vs
  battery vs corded, yard size matching
- `domains/computer-parts/index.md` — compatibility, bottleneck analysis, used
  market, warranty + sub-domain index
- `domains/computer-parts/cpu-motherboard.md` — socket, chipset, VRM, BIOS,
  form factor, PCIe
- `domains/computer-parts/gpu.md` — PSU, case clearance, VRAM, driver horizon,
  used mining risks
- `domains/computer-parts/ram-storage.md` — speed/timing, capacity, NVMe vs
  SATA, TBW, CMR vs SMR
- `domains/computer-parts/psu-case-cooling.md` — wattage, efficiency, quality
  tiers, airflow, CPU cooling
- `domains/computer-parts/monitor-peripherals.md` — panel types, resolution,
  HDR, color accuracy, keyboard/mouse
- `domains/tools/index.md` — power source, battery ecosystem, quality tiers,
  safety, used market + sub-domain index
- `domains/tools/woodworking.md` — table saw, miter saw, router, planer,
  jointer, bandsaw, dust collection
- `domains/tools/metalworking.md` — lathe, mill, bandsaw, grinder, measuring,
  workholding
- `domains/tools/welding.md` — MIG/TIG/stick/flux-cored, duty cycle, input
  power, gas, safety
- `domains/tools/gardening.md` — hand tools, long-handle, pruning, soil prep,
  ergonomics
- `domains/tools/pottery.md` — wheel, kiln, clay, glazes, safety (silica,
  ventilation)

## Related Skills
- **shopping-deal-intelligence** (skill, dependent) — Consumes the Needs Discovery Brief to research pricing, sourcing, and timing
- **shopping-acquisition** (skill, dependent) — Final execution layer — completes purchases or service bookings identified by needs-discovery
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/commerce/needs-discovery/SKILL.md`](skills/commerce/needs-discovery/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-16T08:35:31Z
