---
type: Practice
title: Damage Level Opt-In
description: Auction vehicles are sold with varying levels of disclosed damage; the user must explicitly opt into each level.
tags: [auctions, vehicles, damage-assessment, flood-damage]
date:
  created: "2026-08-07"
  knowledge-basis: "2026-08-07"
  last-used: "2026-08-07"
sources:
  - id: auction-constraints-reference
    resource: skills/commerce/deal-intelligence/references/auction-constraints.md
    title: auction-constraints.md
---

# Damage Level Opt-In

## Failure Mode

A buyer purchases a vehicle at auction without understanding the
damage level. The listing said "flood damage" but the buyer assumed
it was minor. After receiving the vehicle, they discover the
electrical system is completely destroyed — the car will never be
reliable. Flood-damaged vehicles are notoriously unreliable, with
intermittent electrical failures that can appear months or years
later.

## Practice

**Ask the user which damage levels they are willing to accept
before recommending auction vehicles.**

1. **Classify the damage level**: Auction platforms disclose damage
   levels: Run & Drive, Startable, Non-runable, Front end, Rear end,
   Side, Flood, Hail, Theft recovery, Vandalism, Biohazard.

2. **Ask the user**: Present the damage level options and ask which
   ones the user is willing to accept. Use the following guidance:
   - **Run & Drive**: Minimal repair; still get a PPI
   - **Startable**: May need transmission/suspension/brake work
   - **Non-runable**: May need engine replacement; user must say
     they're willing to repair or part out
   - **Front/Rear/Side damage**: Frame damage possible; user must
     be willing to repair
   - **Flood damage**: Major concern — strongly recommend against
     unless the user is an experienced mechanic or buying for parts
   - **Hail damage**: Often cosmetic only; drivable
   - **Theft recovery**: Varies widely; inspect carefully
   - **Vandalism**: Varies; inspect carefully
   - **Biohazard**: Requires professional biohazard remediation;
     user must explicitly opt in

3. **Filter by user preference**: Exclude vehicles with damage
   levels the user has not opted into.

4. **Add repair costs**: For damage levels the user accepts, add
   estimated repair costs to the total acquisition cost.

## Why

Auction vehicles are sold as-is with no return. The damage level
disclosed in the listing is the buyer's primary information about
the vehicle's condition. Unlike a dealership purchase, there is no
test drive, no inspection contingency, and no return policy.

Flood damage deserves special caution: water damage corrupts
electrical systems in ways that may not manifest immediately.
Corrosion continues after the vehicle appears dry, and intermittent
failures can appear months later. Flood cars are considered
notoriously unreliable by mechanics.

## Context

- `auction-constraints.md` has a "Damage Assessment" table with all
  damage levels and opt-in requirements
- Copart and IAAI disclose damage levels in their listings
- The `needs-discovery` skill's `domains/automobiles/index.md` flags
  damage level opt-in as a key question for auction vehicle buyers
- A pre-purchase inspection (PPI) at the auction yard is possible
  during posted inspection hours for most platforms
