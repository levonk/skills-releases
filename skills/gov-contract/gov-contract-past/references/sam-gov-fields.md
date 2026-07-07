# SAM.gov Field Extraction Guide

## Key Fields to Extract from Solicitations

### Required Fields

| Field | Description | Example |
|-------|-------------|---------|
| Solicitation Number | Unique identifier for the solicitation | W91CRB18R0023 |
| NAICS Code | North American Industry Classification System | 722310 |
| PSC Code | Product/Service Code | S203 |
| Place of Performance | Where work will be performed | Fort Hood, TX 76544 |
| Agency | Issuing federal agency | Dept of Defense |

### Where to Find Each Field on SAM.gov

**Solicitation Number**
- Location: Top of solicitation page, usually in header
- Format: Agency-specific (e.g., W91CRB = Army Contracting Command)

**NAICS Code**
- Location: "Contract Information" or "General Information" section
- May list multiple codes if the solicitation is multi-code
- Primary NAICS is usually listed first

**PSC Code**
- Location: Often near NAICS, under "Product/Service Code" or "PSC"
- Format: Letter + 3 digits (e.g., S203 = Food Services)

**Place of Performance**
- Location: "Place of Performance" or "Performance Location" section
- May include: city, county, state, ZIP, congressional district
- Note: Sometimes listed as "Place of Manufacture" for supply contracts

**Agency**
- Location: "Agency" or "Office" field
- Usually shows hierarchy: Toptier > Subtier > Office

## Common PSC Codes for Services

| PSC | Description |
|-----|-------------|
| S201 | Administrative Services |
| S202 | Technical Representative Services |
| S203 | Food Services |
| S204 | Household/Commercial Furnishings |
| S205 | Laundry/Dry Cleaning |
| S206 | Fueling Services |
| S207 | Refuse/Garbage Collection |
| S208 | Custodial/Janitorial |
| S209 | Guard/Protective |
| S210 | Recreational/Fitness |

## Extracting with agent-browser

When pulling a SAM.gov solicitation page:
1. Navigate to the solicitation URL
2. Scroll to "Contract Information" or "General Information" section
3. Extract the four key fields (NAICS, PSC, Place of Performance, Agency)
4. Note any set-aside indicators (e.g., "Small Business")
5. Record the estimated value if shown

## URL Pattern

Solicitation pages follow this pattern:
```
https://sam.gov/opp/[solicitation-id]/view
```

Search results:
```
https://sam.gov/search/?index=opp&page=1&sort=-relevance&search_type=[search-term]
```
