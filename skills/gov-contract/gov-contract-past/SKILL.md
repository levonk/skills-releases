---
name: gov-contract-past
description: Research past government contract vendors, pricing, and contract structures for a specific service at a specific location. Use this skill whenever the user asks about government procurement history, past federal contract vendors, previous contract pricing, contract renewal history, incumbent contractors, or wants to analyze how the government previously paid for a service at a specific place. Also use when users mention SAM.gov, USAspending.gov, or FPDS.gov research workflows.
version: 1.0.0
date:
  created: "2026-06-02"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "government", "procurement", "contract-research", "sam-gov", "usaspending", "fpds"]
see-also:
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
---

{{{ include "includes/base-ai-guidance.md" . }}}

# Government Contract Past Vendor & Pricing Research

Research past vendors, pricing, and contract structures for federal contracts. This skill orchestrates three government systems to build a complete picture of procurement history.

## Systems Used

| System | Purpose | What It Shows |
|--------|---------|---------------|
| SAM.gov | Current solicitations | Solicitation number, NAICS, PSC, place of performance, agency |
| USAspending.gov | Past awards | All vendors, award amounts, period of performance, competition type |
| FPDS.gov | Pricing structure | Unit prices, quantities, contract type, modifications, options exercised |

## Quick Start

Given a service need (e.g., "3 meals/day for 500 people at Location Y"):

1. **Extract key fields** from the current or anticipated solicitation
2. [fork] **Query USAspending** for all past awards matching those fields
3. [fork] **Drill into FPDS** for pricing details and contract modifications
4. **Synthesize** the full timeline: who, what, how much, and why it rebid

## Detailed Workflow

### Step 1 — Extract Key Fields

Identify these four fields. If the user provides a solicitation, extract them. If not, ask the user:

- **PSC code** (e.g., S203 — Food Services)
- **NAICS code** (e.g., 722310 — Food Service Contractors)
- **Place of performance** (city, county, ZIP, or state)
- **Agency** (issuing federal agency)

Optional but helpful:
- Solicitation number (if available)
- Estimated value range
- Contract duration

### Step 2 — Query USAspending.gov for Past Awards

Use the `scripts/build-usaspending-url.ts` script or construct the search manually:

**Search parameters:**
- PSC code: exact match
- NAICS code: exact match
- Place of performance: city/state/ZIP
- Agency: select from dropdown
- Time period: last 10 years (or relevant range)

**What to extract from results:**
- Recipient (vendor) name
- Award amount
- Period of performance (start/end dates)
- Contract type (fixed price, cost-plus, IDIQ, etc.)
- Competition type (full & open, small business set-aside, sole source)
- Award ID / PIID

Use the agent-browser tool to pull the search results page, then extract structured data.

### Step 3 — Query FPDS.gov for Pricing Details

For each past award of interest, use the `scripts/build-fpds-url.ts` script to construct the FPDS query using the PIID from USAspending.

**What to extract from FPDS:**
- Unit prices (e.g., "$8.92 per meal")
- Quantities (e.g., "547,500 meals")
- Contract type detail (FFP, T&M, cost-plus)
- All modifications (options exercised, funding increases, extensions)
- Whether the contract ended normally or was bridged
- Whether the incumbent bid again

Use the agent-browser tool to pull each contract's detail page from FPDS.

### Step 4 — Synthesize Findings

Organize the output as a timeline:

```
## Procurement History: [Service] at [Location]

### Current Solicitation
- Solicitation #: [number]
- Agency: [agency]
- PSC: [code] | NAICS: [code]
- Place of Performance: [location]

### Past Contract Timeline

#### [Vendor A] ([start year]–[end year])
- Total value: $[amount]
- Pricing: $[X] per [unit] / [structure]
- Contract type: [FFP/T&M/cost-plus]
- Competition: [full & open / set-aside / sole source]
- End reason: [options expired / scope changed / bridge contract / etc.]
- Modifications: [list key mods]

#### [Vendor B] ([start year]–[end year])
- ...

### Key Insights
- [Pricing trend: increased/decreased/stable]
- [Incumbent behavior: rebid / no-bid / won again]
- [Contract structure pattern: per-meal vs per-head vs fixed]
- [Competition level: many bidders / few / sole source]
```

## Important Limitations

- **SAM.gov does NOT show past pricing** — it only shows current solicitations and award notices with basic amounts
- **USAspending shows totals** — not unit pricing or detailed structure
- **FPDS is the only source** for unit prices, quantities, and modification history
- **Bridge contracts** may appear in FPDS but not always in USAspending
- **Option year renewals** are visible in FPDS as modifications

## When to Use Each System

| Question | System |
|----------|--------|
| Who is the current/incumbent vendor? | SAM.gov or USAspending |
| How much was the total award? | USAspending |
| What was the unit price? | FPDS |
| Was it competitively bid? | USAspending |
| Were options exercised? | FPDS |
| Was there a bridge contract? | FPDS |
| Why is there a new solicitation? | FPDS (modification history) |

## Script Reference

- `scripts/build-usaspending-url.ts` — Generate USAspending search URLs from extracted fields
- `scripts/build-fpds-url.ts` — Generate FPDS contract detail URLs from PIID
- `scripts/extract-award-timeline.ts` — Synthesize timeline data from USAspending + FPDS results

## References

- `references/sam-gov-fields.md` — Field definitions and extraction guide
- `references/usaspending-guide.md` — Search strategies and filter options
- `references/fpds-guide.md` — Navigation, report types, and data extraction

## Evaluation

See `evals/evals.json` for test cases covering typical research scenarios.

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/gov-contract/gov-contract-past/SKILL.md`
- Scripts: `scripts/build-usaspending-url.ts`, `scripts/build-fpds-url.ts`, `scripts/extract-award-timeline.ts`
- References: `references/sam-gov-fields.md`, `references/usaspending-guide.md`, `references/fpds-guide.md`

### Related Skills
- base-ai-guidance (base-framework)

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
