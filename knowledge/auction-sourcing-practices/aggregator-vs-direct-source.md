---
type: Practice
title: Aggregator vs Direct Source
description: Aggregators are tracked but not actively searched; use the underlying platforms directly; keep both when a government site redirects to an auctioneer.
tags: [auctions, sourcing, aggregators, government-surplus]
date:
  created: "2026-08-07"
  knowledge-basis: "2026-08-07"
  last-used: "2026-08-07"
sources:
  - id: sourcing-sources-toml
    resource: skills/commerce/deal-intelligence/references/sourcing-sources.toml
    title: sourcing-sources.toml
---

# Aggregator vs Direct Source

## Failure Mode

Searching an aggregator site (GovernmentAuctions.org, Gov-Auctions.org)
instead of the underlying auction platform wastes time — the aggregator
only shows listings that are already available on the primary platform,
often with a delay. Some aggregators charge a membership fee for
information that is freely available on the source platforms.

## Practice

**Classify every auction source as direct, aggregator, or redirect.**

1. **Direct sources** (type = "auction" in `sourcing-sources.toml`):
   Search these actively. Examples: GSA Auctions, GovDeals, Copart,
   IAAI, PropertyRoom, Bid4Assets.

2. **Aggregators** (type = "aggregator", `aggregator = true`):
   Track but do not actively search. Use for discovery and price
   comparison only. Bid on the underlying platform directly.
   Examples: GovAuctions.app, BidProwl, GovernmentAuctions.org,
   Gov-Auctions.org.

3. **Redirects** (type = "directory" or "auction" with `redirects_to`):
   Government sites that index to auctioneer contractors. **Keep both
   as sources** — the government site is the index/portal, the
   contractor platform is where you actually bid.
   Examples: Seattle Fleet → James G. Murphy Co., Iowa DOT → GovDeals,
   NY State Store → GovDeals, Norfolk VA → GovDeals + BidWrangler.

## Why

Aggregators add a layer of indirection without adding inventory. They
may show stale listings, charge fees for free information, or bury the
actual platform's search features. Direct sources have the most
current listings, the full search/filter capabilities, and the actual
bidding interface.

Redirects are different from aggregators — a government site that
redirects to an auctioneer is a legitimate source chain. The
government site tells you what's being sold (and may have inspection
information or terms not on the auctioneer's site); the auctioneer
is where you register and bid. Keeping both ensures you don't lose
the government-side context.

## Context

- `sourcing-sources.toml` uses `aggregator = true` and `redirects_to`
  fields to classify sources
- The `shopping-deal-intelligence` INSTRUCTIONS.md.tmpl section 2.2
  documents the aggregator and redirect handling rules
- `sourcing-guide.md` has an "Aggregators (Do Not Actively Search)"
  section listing all known aggregators
