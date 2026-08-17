# Part Supplier Catalog — Reference

Parts suppliers that carry fuel cell components. Use with OEM part numbers
from `references/fcev-part-numbers.md` to search by part number (cheaper
than model-name searches).

Referenced by `INSTRUCTIONS.md` section "Search Parts Suppliers by OEM Part
Number" and by `scripts/search_part_suppliers.py`.

## Search Method: Part Number vs Model Name

| Method | Example | Typical Result | Price |
|--------|---------|----------------|-------|
| Model name | "Toyota Mirai fuel cell stack" | Pre-packaged repair kit | High (30–150% markup) |
| Part number | "1A100-77040" | Raw OEM component | Low (no convenience tax) |

**Always search by part number first.** Only fall back to model-name
searches if part-number searches yield no results.

## Supplier Directory

### eBay

| Field | Value |
|-------|-------|
| URL | `https://www.ebay.com` |
| Search URL | `https://www.ebay.com/sch/i.html?_nkw={query}&_sop=15` |
| Search method | Quoted part number: `"PART_NUMBER"` |
| Sort | `_sop=15` (price + shipping, lowest first) |
| Strength | Used pulls, surplus, new old stock (NOS) |
| Condition filter | Filter by condition: Used, For parts or not working |
| Tips | Search both hyphenated and unhyphenated forms (e.g., `1A100-77040` and `1A10077040`). Save searches for email alerts. |

### Google Shopping

| Field | Value |
|-------|-------|
| URL | `https://shopping.google.com` |
| Search URL | `https://www.google.com/search?q={query}&tbm=shop` |
| Search method | Quoted part number: `"PART_NUMBER"` |
| Strength | Cross-retailer comparison |
| Tips | Google Shopping aggregates listings from multiple retailers — good for finding the cheapest source for a specific part number. |

### Partsouq

| Field | Value |
|-------|-------|
| URL | `https://www.partsouq.com` |
| Search URL | `https://www.partsouq.com/parts?q={query}` |
| Search method | Part number lookup |
| Strength | Automotive OEM cross-reference — shows which vehicles use the same part |
| Tips | Partsouq is a catalog, not a store — use it to find cross-references and equivalent part numbers, then buy from eBay or the OEM dealer. |

### RockAuto

| Field | Value |
|-------|-------|
| URL | `https://www.rockauto.com` |
| Search URL | `https://www.rockauto.com/en/search/?partsearch={query}` |
| Search method | Part number or cross-reference |
| Strength | Aftermarket + OEM side by side |
| Tips | RockAuto carries aftermarket parts for common vehicles. Fuel cell components are specialized — RockAuto may not carry them, but it is worth checking for related components (coolant, sensors, mounts). |

### Toyota Parts (parts.toyota.com)

| Field | Value |
|-------|-------|
| URL | `https://parts.toyota.com` |
| Search method | Part number or VIN lookup |
| Strength | OEM Toyota Mirai parts — guaranteed compatibility |
| Tips | Some fuel cell components are "controlled parts" requiring VIN verification. If the dealer refuses to sell without a VIN, try eBay or independent resellers. Highest price but guaranteed genuine. |

### Hyundai Parts (hyundaipartsdeal.com)

| Field | Value |
|-------|-------|
| URL | `https://www.hyundaipartsdeal.com` |
| Search method | Part number or VIN lookup |
| Strength | OEM Hyundai Nexo parts — guaranteed compatibility |
| Tips | Same controlled-parts caveat as Toyota. Hyundai parts are generally cheaper than Toyota parts for equivalent components. |

### Honda Parts (hondapartsnow.com)

| Field | Value |
|-------|-------|
| URL | `https://www.hondapartsnow.com` |
| Search method | Part number or VIN lookup |
| Strength | OEM Honda Clarity Fuel Cell parts — guaranteed compatibility |
| Tips | Honda Clarity Fuel Cell is discontinued (2017–2019). Parts availability is limited — some components may be out of stock. Check eBay for NOS (new old stock) and used pulls. |

### AliExpress / Alibaba

| Field | Value |
|-------|-------|
| URL | `https://www.aliexpress.com` / `https://www.alibaba.com` |
| Search method | Part number: `"PART_NUMBER"` |
| Strength | Often the OEM factory or their direct distributor — lowest price |
| Tips | Long shipping times (2–6 weeks). Verify the seller has the exact part number — many listings are for "compatible" parts that may not match. Use Alibaba for bulk orders, AliExpress for single units. |

### Specialist Forums / Reddit

| Field | Value |
|-------|-------|
| URLs | `https://www.reddit.com/r/Mirai/`, `https://www.reddit.com/r/hydrogencars/` |
| Search method | `"PART_NUMBER" site:reddit.com` or forum search |
| Strength | Community-verified suppliers, group buys, known-good sellers |
| Tips | FCEV communities are small but knowledgeable. Post a "looking for" thread with the part number — owners and mechanics may have leads on parts or entire donor vehicles. |

## Search Strategy by Component Type

### Fuel Cell Stack

1. Search eBay first — used pulls from salvage vehicles are the most
   likely source. Search by part number (`1A100-77040`, `1A1H0-77012`,
   `35605-M5000`, `3A100-5WM-A30`)
2. Check AliExpress — some Chinese manufacturers produce compatible
   stacks at lower cost (verify compatibility before buying)
3. Check OEM parts catalogs — for guaranteed genuine parts (highest
   price, may require VIN)
4. Post on FCEV forums — owners may have donor vehicles or know of
   salvage yards with FCEVs

### Hydrogen Tanks

1. Search eBay — used pulls from salvage vehicles
2. Check OEM parts catalogs — hydrogen tanks are safety-critical; OEM
   is the safest source
3. **Do not buy used tanks from unknown sources** — tank integrity is
   critical for safety. A damaged tank can explode.
4. Check the tank's inspection date — tanks past their inspection
   interval must be recertified before use

### Controllers and Electronics

1. Search eBay — used pulls are common
2. Check OEM parts catalogs — controllers may be VIN-locked (require
   programming to the vehicle)
3. Check Partsouq for cross-references — the same controller may be
   used across multiple model years

### Cooling System Components

1. Search RockAuto — aftermarket cooling parts are more common
2. Search eBay — used pulls
3. Check OEM parts catalogs — coolant and ion exchangers are
   consumables, usually in stock

## Price Expectations

| Component | OEM New | Used Pull (eBay) | Salvage Yard |
|-----------|---------|------------------|--------------|
| Fuel cell stack (complete) | $8,000–$15,000 | $1,000–$4,000 | $500–$2,000 |
| Hydrogen tank (each) | $2,000–$5,000 | $500–$1,500 | $200–$800 |
| FC control module | $1,500–$3,000 | $300–$800 | $100–$400 |
| Ion exchanger | $200–$400 | $50–$150 | $25–$75 |
| FC coolant | $50–$100/gal | $20–$40/gal | N/A (consumable) |

Prices are approximate and vary by vehicle, generation, and condition.
Salvage yard prices are negotiable — fuel cell components are not in PYP's
standard price catalog, so the cashier will typically price them as
"modules" or negotiate.

## Monitoring Strategy

Set up saved searches on eBay for each part number:

1. Search for `"PART_NUMBER"` on eBay
2. Click "Save this search"
3. Enable email notifications
4. eBay will email when a new listing matches

This catches new listings without running the script manually. The script
complements this by checking multiple suppliers in one run.
