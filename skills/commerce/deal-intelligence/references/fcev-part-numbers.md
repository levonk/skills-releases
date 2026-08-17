# FCEV Part Numbers — Reference

OEM part numbers for fuel cell stacks, hydrogen tanks, and related components
by vehicle and generation. Use these part numbers to search suppliers directly
— part-number searches avoid the "convenience tax" of model-name searches
(30–150% markup for pre-packaged repair kits).

Referenced by `INSTRUCTIONS.md` section "Search Parts Suppliers by OEM Part
Number" and by `scripts/search_part_suppliers.py`.

## The Convenience Tax Problem

Searching `Toyota Mirai fuel cell stack` surfaces pre-packaged repair kits and
model-specific "compatible" parts that carry a convenience markup of 30–150%
over the raw OEM component. Searching the actual part number (e.g.,
`1A100-77040` instead of `Mirai fuel cell stack`) surfaces the raw OEM
component from parts resellers and international marketplaces at a fraction
of the cost.

**Rule**: Always search by part number first. Only fall back to model-name
searches if part-number searches yield no results.

## Toyota Mirai — Generation 1 (2016–2020)

### Fuel Cell Stack

| Part Number | Component | Years | Notes |
|-------------|-----------|-------|-------|
| `1A100-77040` | FC Stack Assembly (main) | 2016–2020 | Primary stack assembly |
| `041A1-77011` | FC Stack Kit | 2020 | Stack rebuild kit |
| `1A1A1-77020` | Label, FC Stack Caution | 2016–2020 | Identification label |
| `0416A-56010` | Ion Exchanger Element Kit | 2016–2020 | Coolant ion filtration |
| `08889-01502` | FC Stack Coolant | 2016–2020 | Deionized coolant fluid |
| `08887-02909` | FC Grease | 2016–2020 | Assembly grease |

### Fuel Cell Control Module (FCM)

| Part Number | Component | Years |
|-------------|-----------|-------|
| `898A1-62020` | Fuel Cell Control Module | 2016 |
| `898A1-62021` | Fuel Cell Control Module | 2016–2017 |
| `898A1-62022` | Fuel Cell Control Module | 2017 |
| `898A1-62023` | Fuel Cell Control Module | 2017 |
| `898A1-62024` | Fuel Cell Control Module | 2017–2018 |
| `898A1-62025` | Fuel Cell Control Module | 2018–2019 |

### Hydrogen Tanks (Type IV, 70 MPa) — 2 Tanks

| Part Number | Component | Years | Notes |
|-------------|-----------|-------|-------|
| `77A10-62081` | Hydrogen Tank Assembly #1 | 2020–2023 | Main tank |
| `77A20-62081` | Hydrogen Tank Assembly #2 | 2020–2023 | Secondary tank |
| `77A30-62031` | Hydrogen Tank Assembly #3 | 2016–2020 | Smaller tank |
| `77B45-62020` | Hydrogen Tank Tube | 2016–2020 | Connecting tube |

### O-Rings and Seals

| Part Number | Component |
|-------------|-----------|
| `90301-10026` | O-Ring |
| `90301-09037` | O-Ring |
| `90301-99207` | O-Ring |
| `90301-11036` | O-Ring |

## Toyota Mirai — Generation 2 (2021+)

### Fuel Cell Stack

| Part Number | Component | Years | Notes |
|-------------|-----------|-------|-------|
| `1A1H0-77012` | FC Stack Assembly (main) | 2023–2024 | Primary stack assembly |
| `041A1-77011` | FC Stack Kit | 2023–2024 | Shared with Gen 1 |
| `898B1-62020` | Fuel Cell Control Computer | 2021–2024 | New ECU for Gen 2 |

### Hydrogen Tanks (Type IV, 70 MPa) — 3 Tanks

| Part Number | Component | Years | Notes |
|-------------|-----------|-------|-------|
| `77A10-62081` | Hydrogen Tank Assembly #1 | 2021–2025 | Shared with Gen 1 |
| `77A20-62081` | Hydrogen Tank Assembly #2 | 2021–2025 | Shared with Gen 1 |
| `77A30-62032` | Hydrogen Tank Assembly #3 | 2024–2025 | Updated design |
| `77A30-62082` | Hydrogen Tank Assembly #3 (variant) | 2021–2023 | Earlier variant |
| `77B45-62020` | Hydrogen Tank Tube | 2021–2025 | Shared with Gen 1 |

## Hyundai Nexo (2019+)

### Fuel Cell Stack

| Part Number | Component | Years | Notes |
|-------------|-----------|-------|-------|
| `35605-M5000` | FC Stack Complete | 2019–2025 | Full stack assembly |
| `39860-M5100` | FC Stack Voltage Monitor | 2019–2025 | Cell voltage monitoring |
| `356B1-M5000` | FC Cross Member Assembly (center) | 2019–2025 | Structural mount |

### Hydrogen Tanks

| Part Number | Component | Years | Notes |
|-------------|-----------|-------|-------|
| `35910-M5100` | Hydrogen Tank Assembly | 2019–2025 | Main tank |
| `35910-M5110` | Hydrogen Tank Assembly (variant) | 2019–2025 | Variant part number |
| `35928-M5000` | Front Hydrogen Tank Band | 2019–2025 | Mounting band |
| `35929-M5000` | Front Hydrogen Tank Band | 2019–2025 | Mounting band |
| `35949-M5000` | Rear Hydrogen Tank Band | 2019–2025 | Mounting band |
| `35925-M5000` | Front Hydrogen Tank Frame | 2019–2025 | Mounting frame |
| `35927-M5000` | Rear Hydrogen Tank Frame | 2019–2025 | Mounting frame |
| `35971-M5000` | Hydrogen Tank Cover (front) | 2019–2025 | Protective cover |
| `35972-M5000` | Hydrogen Tank Cover (rear) | 2019–2025 | Protective cover |
| `35947-M5000` | Hydrogen Tank Frame Mounting Bolt | 2019–2025 | Hardware |
| `359H3-M5020` | TPRD Cap (Thermal Pressure Relief Device) | 2019–2025 | Safety device |

## Hyundai Tucson FCEV / ix35 FCEV (2015–2017)

### Fuel Cell Stack

| Part Number | Component | Years | Notes |
|-------------|-----------|-------|-------|
| `35605-4W000` | FC Stack Complete | 2015–2017 | Original part number |
| `35605-4WAS3` | FC Stack Complete (superseded) | 2015–2017 | Superseded `35605-4W000` |

### Hydrogen Tanks

| Part Number | Component | Years | Notes |
|-------------|-----------|-------|-------|
| `35900-4W010` | Hydrogen Tank Complete | 2015–2017 | Tank option 1 |
| `35900-4W011` | Hydrogen Tank Complete | 2015–2017 | Tank option 2 |
| `35900-4W012` | Hydrogen Tank Complete | 2015–2017 | Tank option 3 |
| `35900-4W013` | Hydrogen Tank Complete | 2015–2017 | Tank option 4 |

## Honda Clarity Fuel Cell (2017–2019)

### Fuel Cell Stack

| Part Number | Component | Years | Notes |
|-------------|-----------|-------|-------|
| `3A100-5WM-A30` | FC Unit Kit (Stack) | 2017–2021 | Primary stack kit |
| `063A0-5WM-305` | FC Stack Kit | 2017–2021 | Rebuild kit |
| `3A100-5WM-A50` | FC Stack | 2019 | 2019 model year stack |
| `3A100-5WM-A61` | FC Stack | 2020–2021 | 2020+ stack revision |
| `3H450-5WM-A01` | Ion Filter | 2017–2021 | Coolant ion filtration |
| `3H300-5WM-A04` | Electric Water Pump Assembly | 2017–2021 | Stack cooling pump |

### Stack-Related Components

| Part Number | Component | Years |
|-------------|-----------|-------|
| `1F861-5WM-A00` | Stack DC Negative Shield Bracket | 2017–2021 |
| `1F871-5WM-A01` | Stack DC Connector Cover Assembly | 2017–2021 |
| `3B841-5WM-A01` | Stack Air Outlet Joint | 2017–2021 |

### Hydrogen Tank System Components

Honda does not list individual hydrogen tank assembly part numbers in
publicly accessible parts catalogs. The tanks are likely sold as part of
larger assemblies or are controlled parts requiring VIN verification.

| Part Number | Component | Years | Notes |
|-------------|-----------|-------|-------|
| `3H211-5WM-A01` | FC Expansion Tank Comp | 2017–2021 | Coolant expansion |
| `3H231-5WM-A11` | FC Sub Reserve Tank | 2017–2021 | Insulating fluid reservoir |
| `19102-R2H-M00` | Reserve Tank Cap | 2017–2021 | Cap |
| `3J872-5WM-A11` | Sub Reserve Tank Joint | 2017–2021 | Fitting |
| `3J873-5WM-A13` | Sub Reserve Tank Hose B | 2017–2021 | Hose |
| `3J874-5WM-A11` | Sub Reserve Hose Bracket | 2017–2021 | Bracket |
| `3J925-5WM-A10` | Sub Reserve Tank Bracket (lower) | 2017–2021 | Bracket |

### Fluids

| Part Number | Component | Years |
|-------------|-----------|-------|
| `OL999-9014` | FC Insulating Fluid (50% Prediluted) | 2017–2021 |
| `OL999-9011` | Antifreeze/Coolant | 2017–2021 |

## Cross-Reference Databases

When a part number search yields no results, try cross-referencing:

| Database | URL | Method |
|----------|-----|--------|
| Partsouq | `https://www.partsouq.com` | Part number lookup — automotive OEM cross-reference |
| RockAuto | `https://www.rockauto.com` | Part number or cross-reference — aftermarket + OEM |
| Toyota Parts | `https://parts.toyota.com` | VIN or part number lookup |
| Hyundai Parts | `https://www.hyundaipartsdeal.com` | VIN or part number lookup |
| Honda Parts | `https://www.hondapartsnow.com` | VIN or part number lookup |

## Controlled Parts Warning

Some fuel cell components are "controlled parts" requiring VIN verification
to purchase from OEM dealers. This is common for:

- Complete fuel cell stack assemblies
- High-pressure hydrogen tanks
- Fuel cell control modules (paired to the vehicle VIN)

Salvage yards do not enforce VIN matching — but OEM parts catalogs may
refuse to sell these parts without a matching VIN. Part-number searches
on eBay, AliExpress, and independent resellers bypass this restriction.

## Part Number Format Guide

| Manufacturer | Format | Example |
|--------------|--------|---------|
| Toyota | `NNNNA-NNNNN` or `NNNNN-NNNNN` | `1A100-77040` |
| Hyundai | `NNNNN-NNNNN` | `35605-M5000` |
| Honda | `NNNNN-NNN-NNN` | `3A100-5WM-A30` |

When searching, try both the hyphenated and unhyphenated forms
(e.g., `1A100-77040` and `1A10077040`) — some suppliers strip hyphens.
