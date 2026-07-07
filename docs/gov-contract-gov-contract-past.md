<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Government Contract Past Vendor & Pricing Research

> Category: **gov-contract** · Status:  · Version: 1.0.0

Research past government contract vendors, pricing, and contract structures for a specific service at a specific location. Use this skill whenever the user asks about government procurement history, past federal contract vendors, previous contract pricing, contract renewal history, incumbent contractors, or wants to analyze how the government previously paid for a service at a specific place. Also use when users mention SAM.gov, USAspending.gov, or FPDS.gov research workflows.

## Metadata

| Field | Value |
|-------|-------|
| Name | `gov-contract-past` |
| Category | `gov-contract` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## Tags
- `ai/skill`
- `government`
- `procurement`
- `contract-research`
- `sam-gov`
- `usaspending`
- `fpds`

## Quick Start

Given a service need (e.g., "3 meals/day for 500 people at Location Y"):

1. **Extract key fields** from the current or anticipated solicitation
2. [fork] **Query USAspending** for all past awards matching those fields
3. [fork] **Drill into FPDS** for pricing details and contract modifications
4. **Synthesize** the full timeline: who, what, how much, and why it rebid

## References

- `references/sam-gov-fields.md` — Field definitions and extraction guide
- `references/usaspending-guide.md` — Search strategies and filter options
- `references/fpds-guide.md` — Navigation, report types, and data extraction

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/gov-contract/gov-contract-past/SKILL.md`](skills/gov-contract/gov-contract-past/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-07T22:59:26Z
