---
type: Synthesis
title: Auction Sourcing Practices Overview
description: Synthesis of auction sourcing practices — aggregator handling, vehicle constraints (smog, export-only, salvage, dealer license), property constraints (buildability, title risks), total acquisition cost, and locale filtering.
tags: [auctions, government-surplus, sourcing, commerce, overview, synthesis]
date:
  created: "2026-08-07"
  knowledge-basis: "2026-08-07"
  last-used: "2026-08-07"
sources:
  - id: shopping-deal-intelligence-skill-v1.6.0
    resource: skills/commerce/deal-intelligence/SKILL.md.tmpl
    title: shopping-deal-intelligence v1.6.0
  - id: auction-constraints-reference
    resource: skills/commerce/deal-intelligence/references/auction-constraints.md
    title: auction-constraints.md
  - id: auction-participation-reference
    resource: skills/commerce/deal-intelligence/references/auction-participation.md
    title: auction-participation.md
  - id: sourcing-sources-toml
    resource: skills/commerce/deal-intelligence/references/sourcing-sources.toml
    title: sourcing-sources.toml
---

---
description: STE100-inspired Simplified Technical English guidelines for technical prose output — active voice, short sentences, one-word-one-meaning, imperative for instructions
---

### Simplified Technical English (STE100-Inspired)

This artifact produces technical English (instructions, procedures, descriptions,
reference documentation). Apply these STE100-inspired guidelines to all technical
prose output so the result is unambiguous, translatable, and easy to read for
non-native speakers and for AI agents that must execute the steps precisely.

These are **STE-inspired guidelines**, not the full ASD-STE100 vocabulary
restriction. Domain terms (Dockerfile, pnpm, devbox, Nx, etc.) are permitted
when they are the correct technical term — STE100's 1000-word approved
vocabulary is too narrow for this domain. The goal is the *clarity discipline*
of STE100, not its word list.

For the full writing rules, before/after examples, and the approved-words
reference, see the
[Simplified Technical English](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/simplified-technical-english.md)
and
[Detailed Guide](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/detailed-guide.md)
concept pages in the `simplified-technical-english` knowledge bundle. The
bundle is the canonical, publicly-reachable home for these guidelines; this
include is the build-time gist that gets inlined into skills and other
bundles.

#### Core Principles

1. **One word, one meaning.** Pick one term for each concept and use it
   everywhere. Do not alternate between "image" and "container image" and
   "docker image" for the same thing. Pick one, define it once, reuse it.

2. **Short sentences.** Keep procedural sentences under 20 words. Keep
   descriptive sentences under 25 words. Split long sentences into two.

3. **Active voice.** Write "The build copies the file" not "The file is copied
   by the build." The actor does the action. Passive voice hides who does what
   and is the single largest source of ambiguity in technical prose.

4. **Imperative mood for instructions.** Write "Run the tests" not "You should
   run the tests" or "The tests should be run." Instructions tell the reader
   (or agent) what to do, directly.

5. **One topic per sentence.** One idea per sentence. Do not chain unrelated
   clauses with "and" or "while." If a sentence has two ideas, split it.

6. **Consistent verb forms.** Use the same verb for the same action across the
   document. If you "run" a script in section 1, do not "execute" it in
   section 2. Pick one verb per action and keep it.

7. **Approved modifiers only.** Avoid decorative adjectives and adverbs
   ("very", "extremely", "simply", "just"). Keep modifiers that carry
   information ("non-root", "read-only", "idempotent"). Drop modifiers that
   carry only emphasis.

8. **Define every acronym on first use.** Write "Continuous Integration (CI)"
   on first use, then "CI" thereafter. Never assume the reader knows the
   acronym.

#### What Counts as Technical English

Apply these guidelines to:

- Procedural instructions ("Run `just build`", "Add the user to the group")
- Descriptions of failure modes, symptoms, and practices
- Reference documentation and concept pages
- Checklists and review guidance
- Synthesis and overview prose in knowledge bundles

Do **not** apply these guidelines to:

- Code, commands, and file paths (those have their own syntax)
- Frontmatter and structured data (YAML, JSON)
- Diagrams and their source syntax (Mermaid, PlantUML)
- Business communication, marketing copy, or creative content
- Log entries and change logs (those are append-only records)

#### Quick Self-Check

Before finishing a piece of technical prose, run this checklist:

- [ ] Is every sentence under 25 words? (Procedural: under 20.)
- [ ] Is every sentence active voice? (Or is the passive voice intentional and
      necessary?)
- [ ] Are instructions in imperative mood?
- [ ] Does each technical term have one and only one form in this document?
- [ ] Is every acronym defined on first use?
- [ ] Are decorative modifiers removed?
- [ ] Does each sentence carry one topic?

If any answer is "no," revise before publishing.


# Auction Sourcing Practices Overview

This bundle documents practices for sourcing through auction channels.
Each concept was extracted from the `shopping-deal-intelligence` skill's
auction references — the structured sourcing catalog, constraint
checklists, and platform-specific participation guides. The practices
prevent specific failure modes that are unique to auctions and do not
arise in retail transactions.

## The Auction Sourcing Flow

```
identify channels → filter by locale → check registration gating →
evaluate constraints → calculate total cost → bid → pay & pick up
```

Each phase has practices that prevent specific failure modes:

| Phase | Practice | Prevents |
|-------|---------|----------|
| Channel identification | [Aggregator vs Direct Source](aggregator-vs-direct-source.md) | Wasting time searching aggregators instead of underlying platforms; losing track of redirect chains |
| Locale filtering | [Locale and Travel Filtering](locale-and-travel-filtering.md) | Recommending auctions the user cannot physically reach for pickup |
| Registration gating | [Dealer License Gating](dealer-license-gating.md) | Recommending dealer-only auctions to public buyers without flagging the credential requirement |
| Vehicle constraints | [Vehicle Smog and CARB Compliance](vehicle-smog-carb-compliance.md) | Buying a vehicle that cannot be registered in the user's state |
| Vehicle constraints | [Export-Only Vehicle Restrictions](export-only-vehicle-restrictions.md) | Buying an export-only vehicle for domestic use |
| Vehicle constraints | [Salvage and Rebuilt Title Brands](salvage-rebuilt-title-brands.md) | Unknowingly buying a branded-title vehicle with financing/insurance/resale implications |
| Vehicle constraints | [Damage Level Opt-In](damage-level-opt-in.md) | Buying a flood-damaged or biohazard vehicle without informed consent |
| Property constraints | [Property Buildability Checklist](property-buildability-checklist.md) | Buying unbuildable raw land at auction |
| Property constraints | [Auction Title Risks](auction-title-risks.md) | Buying property with surviving liens, occupants, or redemption rights |
| Cost calculation | [Total Acquisition Cost](total-acquisition-cost.md) | Underestimating the true cost by ignoring buyer's premium, fees, transport, and repairs |

## How These Practices Connect

The practices form a layered defense:

1. **Channel layer** — Aggregator vs Direct Source ensures we search the
   right platforms
2. **Access layer** — Locale filtering and dealer license gating ensure
   the user can physically and legally participate
3. **Product layer** — Smog, export-only, salvage, and damage constraints
   ensure the product is suitable for the user's intended use
4. **Property layer** — Buildability and title risk checks ensure auction
   property is actually usable and ownable
5. **Cost layer** — Total acquisition cost ensures the user's budget covers
   the true cost, not just the winning bid

## Relationship to the shopping-deal-intelligence Skill

This knowledge bundle is the compounding knowledge base for the auction
sourcing subset of the `shopping-deal-intelligence` skill. The skill's
`references/auction-constraints.md` and `references/auction-participation.md`
are the operational references; this bundle is where lessons learned from
real auction sourcing engagements are recorded and refined over time.

## Future Concept Candidates

- **Auction timing strategy** — When to bid (end of fiscal year, holiday
  weekends, weather events) for lower competition. Deferred until
  sufficient real-world data is collected.
- **Auction platform fee comparison** — Detailed fee structure comparison
  across all platforms. Deferred until platform fee structures are
  verified against current published rates.
- **International auction sourcing** — Practices for buying from
  non-US auction platforms (GovDeals Canada, European government
  surplus). Deferred until international sourcing engagements occur.

---

## Content Ordering

This artifact is optimized for machine consumption. Generic framework content
(shared includes, knowledge bundles) appears before the skill-specific body.
This ordering maximizes cross-skill prefix caching: skills that share the same
includes produce identical byte prefixes, so an LLM context cache warmed by one
skill serves all skills that share the same preamble.

This is sub-optimal for human reading — the skill-specific content starts deep
in the file, after the generic preamble. Human readers can jump to the
skill-specific body by searching for the first `# ` heading that follows the
generic sections. Each section is self-contained and documented with its own
heading hierarchy.

