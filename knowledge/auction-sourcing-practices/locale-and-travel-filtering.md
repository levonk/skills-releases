---
type: Practice
title: Locale and Travel Filtering
description: Auction locale determines whether a user can participate; filter by travel radius and pickup requirements.
tags: [auctions, locale, travel, pickup, filtering]
date:
  created: "2026-08-07"
  knowledge-basis: "2026-08-07"
  last-used: "2026-08-07"
sources:
  - id: auction-constraints-reference
    resource: skills/commerce/deal-intelligence/references/auction-constraints.md
    title: auction-constraints.md
  - id: sourcing-sources-toml
    resource: skills/commerce/deal-intelligence/references/sourcing-sources.toml
    title: sourcing-sources.toml
---

# Locale and Travel Filtering

## Failure Mode

A buyer in San Francisco wins a vehicle at an auction in Miami. The
price was great, but now they need to get the vehicle 3,000 miles.
Transport costs $1,500 — wiping out the savings. Or worse: the
buyer didn't realize the auction required in-person attendance at
a courthouse 200 miles away, and they missed the auction entirely.

## Practice

**Classify every auction by locale requirement. Filter by the
user's travel radius. Always state the pickup location and distance.**

### Locale Types

| Locale type | Description | User action |
|-------------|-------------|-------------|
| **Remote bidding + shipping** | Online bidding; item ships to buyer | No travel; factor shipping cost |
| **Remote bidding + local pickup** | Online bidding; buyer must pick up in person | Travel to pickup or arrange transport |
| **In-person only** | Bidding on-site (courthouse, live auction) | Travel required |
| **Hybrid (live + online)** | Live auction with online simulcast | Remote possible but in-person often cheaper |

### When the User Specifies a Travel Radius

1. Filter out remote-bidding + local-pickup auctions where the
   pickup location exceeds the radius (unless the user is willing
   to travel or arrange transport)
2. Include remote bidding + shipping auctions regardless of radius
3. Include in-person auctions within the radius only
4. Always state the pickup location and distance in the Deal
   Intelligence Report

### When the User Does NOT Specify a Travel Radius

1. Ask whether they're willing to travel for pickup, and if so,
   how far
2. Default to remote-bidding + shipping auctions only, then expand
   based on the user's answer

### Transport Cost Estimation

When an auction requires local pickup and the user is not local,
estimate transport cost:
- **Drivable vehicle**: $0.50–$1.00/mile for a hired driver
- **Non-drivable vehicle**: $1.00–$2.00/mile for towing
- **Professional auto transport**: $0.50–$1.50/mile depending on
  distance, vehicle size, and enclosed vs. open trailer
- **Minimum charge**: Most transport services have a $200–$500
  minimum

Add the transport cost to the total acquisition cost (see
[Total Acquisition Cost](total-acquisition-cost.md)).

## Why

Auction locale is a hard constraint — if the user cannot physically
reach the pickup location, they cannot complete the purchase. Unlike
retail purchases (which ship to the buyer), most auction vehicles
and equipment require local pickup. The transport cost can easily
wipe out the savings from buying at auction.

In-person auctions (courthouse steps, some tax deed sales, some
police auctions) require the buyer to attend in person, often with
a cashier's check. This is a hard travel requirement that cannot be
worked around.

## Context

- `auction-constraints.md` has a "Locale & Travel" table with the
  four locale types
- `sourcing-sources.toml` has `online`, `in_person`, `local_pickup`,
  and `ships` fields for each source
- The `needs-discovery` skill's `domains/automobiles/index.md` flags
  locale/travel as a key question for auction vehicle buyers
- The `needs-discovery` skill's `domains/real-estate/index.md` flags
  locale/travel as a key question for auction property buyers
