# Pick Your Part California Locations — Reference

All California Pick Your Part (PYP) yards with addresses, location IDs, and
approximate driving distance from Glendale, CA 91204. Sorted nearest to
farthest.

Referenced by `INSTRUCTIONS.md` section "Search Pick Your Part Inventory"
and by `scripts/search_pyp_inventory.py`.

## Website

- Primary: `https://www.pyp.com`
- Alternate: `https://www.lkqpickyourpart.com` (same inventory, LKQ parent company)

Both domains serve the same inventory and location data. The script uses
`pyp.com` as the primary domain and falls back to `lkqpickyourpart.com`.

## Inventory URL Pattern

- Main inventory: `https://www.pyp.com/inventory/`
- Location-specific: `https://www.pyp.com/inventory/<yard-slug>-<yard-id>/`
- Example: `https://www.pyp.com/inventory/sun-valley-1292/`

Each yard's inventory page lists vehicles with:

- Stock number (e.g., `1292-70395` — prefix is the yard ID)
- Year, Make, Model
- VIN
- Color
- Section / Row / Space location within the yard

## California Yards (Sorted by Distance from 91204)

| Rank | Yard | ID | Address | City, ZIP | Distance |
|------|------|----|---------|-----------|----------|
| 1 | Sun Valley | 1292 | 11201 Pendleton Street | Sun Valley, CA 91352 | 10 mi |
| 2 | Monrovia | 1288 | 3333 S. Peck Rd. | Monrovia, CA 91016 | 18 mi |
| 3 | Santa Fe Springs | 1291 | 13780 Imperial Highway | Santa Fe Springs, CA 90670 | 20 mi |
| 4 | Wilmington | 1293 | 1232 Blinn Ave. | Wilmington, CA 90744 | 30 mi |
| 5 | Anaheim | 1285 | 1235 South Beach Blvd. | Anaheim, CA 92804 | 34 mi |
| 6 | Ontario | 1289 | 2025 S. Milliken Ave. | Ontario, CA 91761 | 41 mi |
| 7 | Fontana | 1286 | 15228 Boyle Avenue | Fontana, CA 92337 | 52 mi |
| 8 | Rialto | 1294 | 221 E. Santa Ana Avenue | Bloomington, CA 92316 | 55 mi |
| 9 | San Bernardino | 1295 | 434 6th St | San Bernardino, CA 92410 | 59 mi |
| 10 | Riverside | 1290 | 3760 Pyrite St. | Riverside, CA 92509 | 62 mi |
| 11 | Hesperia | 1287 | 11399 Santa Fe Ave. E. | Hesperia, CA 92345 | 77 mi |
| 12 | Victorville | 1296 | 17229 Gas Line Road | Victorville, CA 92394 | 83 mi |
| 13 | Bakersfield | 1284 | 5311 South Union Ave. | Bakersfield, CA 93307 | 107 mi |
| 14 | Chula Vista | 1283 | 880 Energy Way | Chula Vista, CA 91911 | 136 mi |

## Distance Notes

Distances are approximate driving miles from Glendale, CA 91204. The
`search_pyp_inventory.py` script uses these distances for sorting. When
the user provides a different zip code via `--zip`, the script still
sorts by the 91204 distances as a reasonable proxy for Southern California
ordering. For other regions (Northern California, etc.), pass
`--max-distance 0` to disable distance filtering and search all yards.

## Yard Phone Numbers

Call the yard to confirm a vehicle is still on the lot before visiting —
inventory moves fast. Phone numbers are listed at:

`https://www.pyp.com/locations/`

## Search Strategy by Distance

| Radius | Yards included | Strategy |
|--------|----------------|---------|
| 0–25 mi | Sun Valley, Monrovia, Santa Fe Springs | Daily check — close enough for same-day visit |
| 25–50 mi | + Wilmington, Anaheim, Ontario | Weekly check — day trip |
| 50–100 mi | + Fontana, Rialto, San Bernardino, Riverside, Hesperia | Weekly check — planned trip |
| 100+ mi | + Victorville, Bakersfield, Chula Vista | Monthly check — only for high-value matches |

## Other LKQ / Pick Your Part Brands

Pick Your Part is owned by LKQ Corporation. Other LKQ salvage brands may
have fuel cell vehicles in their inventory but are not covered by this
skill's search script:

- LKQ Self Service (lkqselfservice.com) — some locations overlap with PYP
- Pick-n-Pull (picknpull.com) — different brand, separate inventory

For broader coverage, search Pick-n-Pull California locations manually:
`https://www.picknpull.com/check-inventory/`
