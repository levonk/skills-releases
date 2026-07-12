<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **commerce** · Status: ready · Version: 1.0.0

Discover and refine purchasing requirements through structured interviewing. Use when a user needs help figuring out what product or service to buy, needs to hire a service provider (plumber, electrician, contractor, tutor, etc.), has a problem that requires a purchase to solve, or has a vague idea of what they want but needs help narrowing it down. Covers: (1) timeline elicitation (nice-to-have vs essential deadlines), (2) product-vs-service classification, (3) intelligent numbered questions with lettered answer choices and pre-filled best-guess defaults, (4) problem-to-product/service mapping when the user describes a problem rather than a product, (5) alternative discovery when the user names a specific product, (6) product/service recommendation with comparative rationale, (7) constraint identification including known defects, version pitfalls, reliability issues, seller reputation, licensing/insurance requirements for services, and environmental hazards.

## Metadata

| Field | Value |
|-------|-------|
| Name | `shopping-needs-discovery` |
| Category | `commerce` |
| Version | `1.0.0` |
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

Proactively research and surface constraints before the user asks. Cover product constraints (defects, version pitfalls, reliability, seller reputation, environmental hazards, buy-new vs buy-used rules, mileage/wear thresholds) and service constraints (licensing, insurance/bonding, permits, warranty, complaint history, seasonal availability, red flags).

For the full constraint checklist for products and services, see `references/constraint-checklist.md`.

## Related Skills
- **shopping-deal-intelligence** (skill, dependent) — Consumes the Needs Discovery Brief to research pricing, sourcing, and timing
- **shopping-acquisition** (skill, dependent) — Final execution layer — completes purchases or service bookings identified by needs-discovery
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/commerce/needs-discovery/SKILL.md`](skills/commerce/needs-discovery/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-12T01:27:53Z
