---
name: shopping-needs-discovery
description: >
  Discover and refine purchasing requirements through structured interviewing.
  Use when a user needs help figuring out what product or service to buy, needs
  to hire a service provider (plumber, electrician, contractor, tutor, etc.),
  has a problem that requires a purchase to solve, or has a vague idea of what
  they want but needs help narrowing it down. Covers: (1) timeline elicitation
  (nice-to-have vs essential deadlines), (2) product-vs-service classification,
  (3) intelligent numbered questions with lettered answer choices and pre-filled
  best-guess defaults, (4) problem-to-product/service mapping when the user
  describes a problem rather than a product, (5) alternative discovery when the
  user names a specific product, (6) product/service recommendation with
  comparative rationale, (7) constraint identification including known defects,
  version pitfalls, reliability issues, seller reputation, licensing/insurance
  requirements for services, and environmental hazards.
version: 1.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2026-03-24"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "commerce", "shopping", "needs-assessment", "product-research"]
see-also:
  - skill: "shopping-deal-intelligence"
    relationship: "dependent"
    description: "Consumes the Needs Discovery Brief to research pricing, sourcing, and timing"
  - skill: "shopping-acquisition"
    relationship: "dependent"
    description: "Final execution layer — completes purchases or service bookings identified by needs-discovery"
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
dependencies:
  - type: skill
    name: shopping-deal-intelligence
  - type: skill
    name: shopping-acquisition
  - type: url
    name: Consumer Reports
    url: https://www.consumerreports.org/
  - type: url
    name: Wirecutter
    url: https://www.nytimes.com/wirecutter/
  - type: url
    name: NHTSA Recalls
    url: https://www.nhtsa.gov/recalls
  - type: url
    name: CPSC Recalls
    url: https://www.cpsc.gov/Recalls
  - type: url
    name: Thumbtack
    url: https://www.thumbtack.com/
  - type: url
    name: Angi
    url: https://www.angi.com/
  - type: url
    name: Google Local Services
    url: https://ads.google.com/local-services-ads/
  - type: url
    name: Yelp
    url: https://www.yelp.com/
---

{{{ include "includes/base-ai-guidance.md" . }}}

# Shopping Needs Discovery

Structured intake process that transforms a vague need or problem into a concrete, ranked list of candidate products or services with justified reasoning.

## Effort Tier Awareness

This skill respects the effort tier assigned by the agent in Phase 0. For **Quick** tier items (under $50), compress questioning to 1–2 essential questions and skip deep constraint research. For **Standard** and above, run the full workflow.

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

## Output Format

Deliver a **Needs Discovery Brief** containing:

```markdown
## Needs Discovery Brief

### Timeline
- Nice-to-have by: YYYY-MM-DD
- Essential by: YYYY-MM-DD

### Effort Tier: [Quick | Standard | Major | High-value]

### Requirements Summary
- Primary need: ...
- Type: [Product | Service | Both]
- Use case: ...
- Budget: ...
- Key constraints: ...

### Recommended Products/Services
| Rank | Product/Provider | Type | Why | Price Range |
|------|-----------------|------|-----|------------|
| 1 | ... | Product/Service | ... | ... |

### Alternatives Considered (if user named a specific product)
| # | Alternative | vs User's Pick | Verdict |
|---|------------|---------------|---------|

### Constraints & Warnings
- ...

### Next Step
→ Hand off to deal-intelligence skill for pricing research
```

## Handoff

Pass the Needs Discovery Brief to the **shopping-deal-intelligence** skill for pricing, sourcing, and timing analysis.

## Resources

- `references/questioning-examples.md` — Questioning format example, rules, product-vs-service classification table, problem-to-product decision table, alternative discovery comparison table
- `references/constraint-checklist.md` — Product and service constraint identification checklist

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/commerce/needs-discovery/SKILL.md`
- References: `references/questioning-examples.md`, `references/constraint-checklist.md`

### Related Skills
- `shopping-deal-intelligence` (dependent) — consumes the Needs Discovery Brief for pricing, sourcing, and timing
- `shopping-acquisition` (dependent) — final execution layer for purchases or service bookings
- `base-ai-guidance` (base-framework) — shared framework for all AI guidance types

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles

<!-- vim: set ft=markdown -->
