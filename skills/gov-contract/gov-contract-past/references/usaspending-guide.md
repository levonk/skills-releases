# USAspending.gov Research Guide

## Search Strategies

### Method 1: Web Interface (for manual/agent-browser extraction)

1. Navigate to: https://www.usaspending.gov/search
2. Select "Advanced Search"
3. Apply filters in this order:

**Time Period**
- Default: last 10 years
- Adjust based on research needs

**Award Type**
- Select: Contracts Only (IDV + Awards)
- This excludes grants, loans, and direct payments

**PSC Code**
- Enter exact PSC (e.g., S203)
- Can enter multiple, comma-separated

**NAICS Code**
- Enter exact NAICS (e.g., 722310)
- Can enter multiple

**Place of Performance**
- Select state from dropdown
- Optionally narrow to county or city
- ZIP code search available

**Agency**
- Select from agency dropdown
- Can filter to subtier agency

### Method 2: API (for deterministic queries)

**Endpoint:** `POST https://api.usaspending.gov/api/v2/search/spending_by_award/`

**Request body structure:**
```json
{
  "filters": {
    "award_type_codes": ["A", "B", "C", "D"],
    "time_period": [{"start_date": "2015-01-01", "end_date": "2026-01-01"}],
    "product_or_service_code": ["S203"],
    "naics_codes": ["722310"],
    "place_of_performance_locations": [{"country": "USA", "state": "TX"}],
    "agencies": [{"name": "Department of Defense", "tier": "toptier", "type": "awarding"}]
  },
  "fields": [
    "Award ID", "Recipient Name", "Start Date", "End Date",
    "Award Amount", "Awarding Agency", "Contract Award Type",
    "Place of Performance State Code", "generated_internal_id"
  ],
  "page": 1,
  "limit": 100,
  "sort": "Award Amount",
  "order": "desc"
}
```

**Award type code reference:**
| Code | Type |
|------|------|
| A | Blanket Purchase Agreements |
| B | Indefinite Delivery Contracts |
| C | Delivery Orders |
| D | Definitive Contracts |

## What to Extract from Results

For each award:
- **Award ID / PIID** (needed for FPDS lookup)
- **Recipient Name** (vendor)
- **Start Date** (period begin)
- **End Date** (period end)
- **Award Amount** (total obligated)
- **Awarding Agency** (who paid)
- **Contract Award Type** (FFP, T&M, etc.)
- **Competition** (full & open, sole source, etc.)
- **Number of Offers** (how many bidders)
- **generated_internal_id** (internal USAspending ID)

## Using agent-browser

When pulling USAspending search results:
1. Use the scripts/build-usaspending-url.ts to construct the query
2. Pull the page with agent-browser
3. Extract structured data from the table view
4. Paginate if results exceed one page (use `page` parameter in API)

## Common Issues

- **No results**: Try broader location (state instead of city) or remove agency filter
- **Too many results**: Narrow date range or add agency filter
- **Missing awards**: Some older contracts may not have full digital records
- **Bridge contracts**: May appear as separate awards with short durations
