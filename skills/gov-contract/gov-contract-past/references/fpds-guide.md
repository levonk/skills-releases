# FPDS.gov Research Guide

## What FPDS Contains

FPDS (Federal Procurement Data System) is the authoritative source for:
- Unit pricing and quantities
- Contract modifications and option exercises
- Detailed contract type information
- Vendor name and address
- Competition details
- All transactions (base award + modifications)

## Navigation

### Searching by PIID

1. Navigate to: https://www.fpds.gov/ezsearch/fpdsportal
2. Enter PIID in the search box (e.g., `PIID:"W91CRB18C0012"`)
3. Click "Search"

### Understanding Results

Each contract appears as a list of transactions:

| Transaction Type | Meaning |
|-----------------|---------|
| Base Award | Original contract award |
| Modification | Change to existing contract |
| Option Exercised | Option year activated |
| Termination | Contract ended early |
| Close Out | Final contract close |

### Key Fields to Extract

**Pricing Information**
- Unit Price: Price per unit
- Quantity: Number of units
- Unit of Measure: Each, Meal, Day, etc.
- Estimated Total Contract Value: Ceiling amount

**Contract Structure**
- Type of Contract: FFP, T&M, Cost-Plus, etc.
- Pricing Arrangement: Fixed Price, Incentive, etc.
- Contract Financing: Progress payments, advance, etc.

**Competition**
- Extent Competed: Full & Open, Sole Source, etc.
- Number of Offers Received
- Statutory Exception: 8(a), HUBZone, etc.

**Dates**
- Signed Date: When action was approved
- Effective Date: When obligation begins
- Completion Date: When work should finish

## Reading Modification History

Modifications tell the story of the contract:

- **P00001, P00002, etc.**: Standard modifications
- **Option Exercised**: Year 2, 3, 4, etc. activated
- **Funding Only**: Additional money, no scope change
- **Scope Change**: Work added or removed
- **Administrative**: Contact info, address changes

Look for patterns:
- Multiple option exercises = incumbent held contract for years
- Bridge contracts = short extensions between recompetes
- Funding increases = scope growth or cost escalation

## URL Patterns

**Search by PIID:**
```
https://www.fpds.gov/ezsearch/fpdsportal?q=PIID:"[PIID]"&s=FPDS.GOV
```

**Search by Vendor:**
```
https://www.fpds.gov/ezsearch/fpdsportal?q=VENDOR:"[Vendor Name]"&s=FPDS.GOV
```

**Search by Place of Performance:**
```
https://www.fpds.gov/ezsearch/fpdsportal?q=POP:"[City, ST]"&s=FPDS.GOV
```

## Using agent-browser

When pulling FPDS contract pages:
1. Use scripts/build-fpds-url.ts to construct the URL from PIID
2. Pull with agent-browser
3. Extract the base award details first
4. Then extract each modification in sequence
5. Look for unit pricing in the "Pricing" or "Clause" sections
6. Note the "Description of Requirement" for scope details

## Important Notes

- FPDS data may lag 30-90 days behind real-time
- Some older contracts (pre-2000) may have incomplete data
- Classified contracts will not appear in FPDS
- Subcontractor data is not in FPDS (use SAM for subcontracting reports)
- The "Obligated Amount" on modifications shows incremental funding, not total

## Contract Type Codes

| Code | Description |
|------|-------------|
| A | Fixed Price with Economic Price Adjustment |
| B | Fixed Price Incentive |
| J | Firm Fixed Price |
| K | Fixed Price with Redetermination |
| L | Fixed Price Level of Effort |
| M | Fixed Price Award Fee |
| R | Cost Plus Fixed Fee |
| S | Cost Plus Incentive Fee |
| T | Cost Plus Award Fee |
| U | Time and Materials |
| V | Labor Hours |
| Y | Commercial Item |
