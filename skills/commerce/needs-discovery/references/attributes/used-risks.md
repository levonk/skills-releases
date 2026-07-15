# Used & Refurbished-Specific Risks — Attribute Reference

Constraint attribute: applies when the user is considering a used or
refurbished purchase. Referenced by `references/constraint-attributes.md`.

## Buy-New vs Buy-Used Rules

**Never buy used** (safety or hygiene critical):

| Item | Why |
|------|-----|
| Car seats | Crash damage invisible; expiration date on plastic; standards change |
| Helmets (bike, motorcycle) | Impact damage invisible; foam degrades; one-crash rule |
| Mattresses | Bedbugs, bodily fluids, fire retardant standards change |
| Tires | Age-related rubber degradation (DOT code — avoid 6+ years old) |
| CPAP machines | Hygiene; internal contamination |
| Smoke / CO detectors | Sensor degradation; 10-year max lifespan |
| Safety razors with blades | Hygiene |

**Fine to buy used** (durable, no safety/hygiene concern):

| Item | Notes |
|------|-------|
| Cast iron cookware | Lasts forever; re-season if needed |
| Hand tools | Inspect for damage; quality brands last decades |
| Furniture (wood) | Check for bedbugs in upholstery; solid wood is fine |
| Books, media | Condition check only |
| Bicycles (frame) | Inspect frame for cracks; components may need replacing |
| Audio equipment | Capacitors degrade over 20+ years; otherwise fine |

## Hidden Damage

- **Water damage in phones/laptops**: Check LCI (liquid contact indicator).
  For phones: check in SIM slot (iPhone) or battery area (Android). For
  laptops: check under keyboard, around ports.
- **Flood damage in cars**: Check title brand (flood/salvage/rebuilt), smell
  for mildew, inspect for rust in unusual places (seat rails, under dash),
  check for moisture in headlights, look for water lines in trunk/engine bay.
  Run [NICB VINCheck](https://www.nicb.org/vincheck) for theft/flood history.
- **Structural damage in homes**: Foundation cracks (horizontal = serious),
  termite damage (mud tubes, hollow-sounding wood), water damage (stains,
  soft spots), roof sagging.

## Non-Transferable Warranty

Many warranties are tied to the original buyer. A used item "still under
warranty" may not be.

| Manufacturer | Transferable? | Notes |
|--------------|--------------|-------|
| AppleCare+ | ✅ Yes | Transfer to new owner via Apple Support |
| Most appliance warranties | ❌ No | Tied to original purchaser + address |
| Vehicle warranties | Varies | CPO warranties transfer; some new-car warranties transfer, others don't |
| Extended warranties (third-party) | Varies | Check the contract terms |

Verify the warranty transfer policy before counting on it.

## Counterfeit Risk

High for luxury goods, batteries, chargers, memory cards, brand-name
cosmetics, pharmaceuticals. Verify authenticity via:

- Serial number checks on manufacturer website
- Authorized dealer verification
- Authentication services: [Entrupy](https://www.entrupy.com/) (bags),
  LegitGrails (sneakers), [eBay Authenticity Guarantee](https://www.ebay.com//authenticity-guarantee)
- Physical inspection: stitching, weight, materials, packaging (compare to
  known-authentic examples)

Be especially cautious of "new in box" luxury goods on eBay and marketplace
platforms — counterfeits are often sold as "authentic, never opened."

## Battery Degradation

The most expensive wear component in EVs, phones, laptops, power tools:

| Device | How to check | Replace below |
|---------|-------------|---------------|
| Tesla | Service mode → battery health | 70% capacity |
| Nissan Leaf | SOH meter (dashboard or OBD2) | 70% capacity |
| Other EVs | OBD2 scan with EV-specific app | 70% capacity |
| iPhone | Settings → Battery → Battery Health | 80% capacity |
| Android | AccuBattery app or `*#*#4636#*#*` | 80% capacity |
| MacBook | System Information → Power → Cycle Count | 80% capacity (check cycle count vs rated max) |
| Power tools | Run time test | Noticeable drop in runtime |

Below the threshold, budget for replacement cost in the purchase price.

## Title & Ownership Issues

- **Salvage/rebuilt titles** (vehicles): Insurance may be hard to get,
  resale value crushed, financing may be refused. Check title brand via
  [NICB VINCheck](https://www.nicb.org/vincheck) and vehicle history report
  (Carfax, AutoCheck).
- **Liens**: A lien holder can repossess even after you buy. For vehicles,
  check for liens via DMV. For other goods, if the seller financed it, the
  lender may have a security interest.
- **Stolen goods**: Check [NICB VINCheck](https://www.nicb.org/vincheck) for
  vehicles, [StolenRegister](https://stolenregister.com/) for other items.
  If a deal is too good to be true, it may be stolen.

## Recall Non-Compliance

Used items may have unrepaired safety recalls. Check recall status by serial
number/VIN before buying:

- Vehicles: [NHTSA recalls](https://www.nhtsa.gov/recalls) by VIN
- Consumer products: [CPSC recalls](https://www.cpsc.gov/Recalls) by model
- Child products: especially critical — drop-side cribs, older car seats

A used car with an unrepaired Takata airbag recall is a literal explosive
hazard. Verify recalls were performed, not just that they exist.

## Banned Substances (Used Items)

- **Lead paint**: Pre-1978 furniture and toys (US). Test with a lead test
  kit ($10–$15).
- **Asbestos**: Pre-1980s homes (insulation, floor tiles, siding, popcorn
  ceilings) and some older appliances. Professional testing required.
- **Phthalates**: Older plastics, especially children's toys pre-2008 CPSIA.
- **Flame retardants**: Older furniture and electronics may contain banned
  PBDEs.

Research the manufacturing era for used items. For safety equipment (helmets,
car seats, electrical), buy new or verify the standard on the label is
current.

<!-- vim: set ft=markdown -->
