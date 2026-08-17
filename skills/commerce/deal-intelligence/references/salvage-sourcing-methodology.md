# Salvage Sourcing Methodology — Reference

Methodology for salvage yard fuel cell sourcing — search strategy, yard
visit protocol, part removal, and condition assessment.

Referenced by `INSTRUCTIONS.md` sections "Yard Visit Protocol" and
"Safety Warnings".

## Search Strategy

### Daily Monitoring

Fuel cell vehicles are rare in salvage yards. When one arrives, it goes
fast — often within 24–48 hours. Run `search_pyp_inventory.py` daily:

```bash
uv run --script scripts/search_pyp_inventory.py --zip 91204 --json >> pyp-log.jsonl
```

Append to a log file to track when vehicles appear and at which yards.
Over time, this reveals which yards get FCEVs most often.

### Multi-Yard Strategy

Do not limit searches to the nearest yard. Fuel cell vehicles can appear
at any California yard. Search all yards within a 100-mile radius:

```bash
uv run --script scripts/search_pyp_inventory.py --zip 91204 --max-distance 100
```

### Manual Fallback

If the script fails (PYP changes their page structure, rate limiting,
network issues), search manually:

1. Go to `https://www.pyp.com/inventory/`
2. Select each yard from the California list (see
   `references/pyp-california-locations.md`)
3. Filter by Make: Toyota, Hyundai, Honda
4. Look for models: Mirai, Nexo, Clarity, Tucson
5. Note the stock number, section/row/space, and yard name

### Pick-n-Pull (Manual)

Pick-n-Pull is a separate LKQ brand with its own inventory. Search
manually at `https://www.picknpull.com/check-inventory/` — filter by
Toyota Mirai, Hyundai Nexo, Honda Clarity.

## Yard Visit Protocol

### Before You Go

1. **Call the yard** — confirm the vehicle is still on the lot. Give the
   stock number. Inventory moves fast; a vehicle listed today may be
   crushed tomorrow.
2. **Check yard hours** — most PYP yards open at 8 AM. Arrive early for
   the best selection and to avoid heat (Southern California).
3. **Pay the admission fee** — typically $2–3 to enter the yard.
4. **Bring tools** — see the tool list below.

### Tools to Bring

| Tool | Purpose |
|------|---------|
| Wrench set (metric, 8–19mm) | Bolt removal for stack and tank mounts |
| Socket set (metric, deep + shallow) | Bolt removal in tight spaces |
| Ratchet + extensions | Reach bolts in engine bay |
| Pry bar | Separating sealed components |
| Screwdriver set (Phillips + flat) | Hose clamps, covers |
| Pliers (needle-nose + slip-joint) | Hose removal, clip removal |
| Wire cutters / strippers | Electrical disconnects |
| Multimeter | Verify high-voltage system is de-energized |
| Safety glasses | Eye protection |
| Heavy gloves (nitrile + leather) | Hand protection |
| Closed-toe boots | Foot protection |
| Flashlight / headlamp | Visibility under vehicle |
| Cooler with ice | Transport temperature-sensitive components |
| Bolt bag / ziplock bags | Organize small parts and bolts |

### Finding the Vehicle in the Yard

1. Note the section, row, and space from the inventory listing
2. Pick up a yard map at the entrance (or use the PYP app)
3. Navigate to the section — vehicles are arranged in rows
4. Verify the stock number on the vehicle's windshield tag matches

## Part Removal — Safety First

### CRITICAL: High-Voltage System Disconnect

Fuel cell vehicles operate at 300–650V DC. Before touching any
orange-cabled component:

1. **Remove the 12V auxiliary battery negative terminal** — this disables
   the contactors that connect the high-voltage system
2. **Wait 10 minutes** — allows residual charge in capacitors to dissipate
3. **Verify with a multimeter** — check across the high-voltage bus; must
   read <5V before proceeding
4. **Wear insulated gloves** — Class 0 rubber gloves rated for 1000V

Failure to follow this procedure can cause serious injury or death.

### CRITICAL: Hydrogen Tank Depressurization

Hydrogen tanks hold gas at 70 MPa (10,000 psi). Never remove a tank that
has not been depressurized.

1. **Do NOT attempt to depressurize a tank at the salvage yard** — this
   requires OEM service tooling and a safe venting procedure
2. **Only remove tanks that are already empty** — if the vehicle was
   crashed, the tanks may have auto-vented (TPRD triggered by heat)
3. **Check the tank pressure gauge** if accessible — must read 0
4. **If you cannot confirm the tank is empty, DO NOT remove it** —
   purchase it from a parts supplier instead (see
   `references/part-supplier-catalog.md`)

A pressurized hydrogen tank can explode if damaged. The energy release
from a 70 MPa tank rupture is comparable to a small explosive device.

### Fuel Cell Stack Removal

1. Disconnect the 12V battery (see above)
2. Drain the FC stack coolant — place a drain pan under the stack, remove
   the lower coolant hose, drain into a container (coolant is
   deionized — do not contaminate with tap water)
3. Disconnect the high-voltage cables from the stack (orange cables) —
   label each cable for reinstallation
4. Disconnect the hydrogen supply and return lines from the stack
5. Disconnect the air supply and exhaust lines from the stack
6. Disconnect the coolant supply and return lines from the stack
7. Remove the stack mounting bolts (typically 4–6 bolts securing the
   stack to its cradle)
8. Lift the stack out of the vehicle — fuel cell stacks weigh 50–100 kg
   (110–220 lbs); use a second person or a hoist
9. Cap all open ports to prevent contamination during transport

### Hydrogen Tank Removal (Only If Confirmed Empty)

1. Verify the tank is depressurized (see above)
2. Disconnect the hydrogen lines from the tank
3. Remove the tank mounting bands (typically 2–3 bands per tank)
4. Lift the tank out of the vehicle — hydrogen tanks weigh 20–40 kg
   (45–90 lbs) each
5. Cap all open ports
6. Transport carefully — do not drop or impact the tank

## Condition Assessment

### Fuel Cell Stack

| Check | Good | Bad |
|-------|------|-----|
| Exterior | Clean, no cracks | Cracked housing, coolant residue |
| Ports | Clean, no corrosion | Corroded, contaminated |
| Coolant | Clear, no debris | Cloudy, metallic particles |
| Labels | Intact, readable | Missing or damaged |
| Mounting points | Intact | Broken or stripped |

**Risk factors**:
- Vehicle was in a flood — stack is likely destroyed (water contamination)
- Vehicle was in a fire — stack seals may be compromised
- Vehicle has high mileage (>100k) — stack may be near end of life
- Stack was exposed to air with ports uncapped — membrane degradation

### Hydrogen Tank

| Check | Good | Bad |
|-------|------|-----|
| Exterior | No visible damage | Dents, cracks, scratches >2mm deep |
| Ports | Clean, no damage | Stripped threads, damaged seals |
| Labels | Intact, readable (pressure rating, date) | Missing or damaged |
| TPRD | Intact | Damaged or triggered (indicates fire exposure) |
| Mounting bands | Intact | Broken or bent |

**Risk factors**:
- Tank was in a fire — TPRD may have triggered; tank must be recertified
  before use (or scrapped)
- Tank has impact damage — carbon fiber overwrap damage compromises
  structural integrity; do not use
- Tank is past its inspection date — hydrogen tanks require periodic
  inspection (typically every 3–5 years); check the label

## Post-Removal

1. **Pay at the cashier** — fuel cell stacks and hydrogen tanks are
   high-value items; expect to negotiate price. PYP prices parts by
   category, not by part number — a fuel cell stack may be priced as a
   "module" or "engine" depending on the yard.
2. **Inspect the part before leaving the lot** — once you leave, returns
   are typically not accepted
3. **Store properly** —
   - Stack: keep ports capped, store in a dry environment, do not freeze
   - Tank: keep ports capped, store in a cool dry place away from direct
     sunlight
4. **Have the stack tested** before installation — a fuel cell stack
   test bench can verify output voltage and membrane condition. Contact
   a fuel cell service center (Toyota/Hyundai/Honda dealer with FCEV
   certification) for testing.

## Legal and Regulatory Notes

- **Salvage parts have no warranty** — sold as-is
- **Hydrogen tanks are regulated pressure vessels** — in California,
  tanks must be DOT-certified and within their inspection interval for
  legal use on public roads
- **Fuel cell stacks are not regulated** as pressure vessels, but
  high-voltage safety standards apply during installation and operation
- **Title brands** — salvage vehicles have branded titles; this does not
  affect the parts, but it indicates why the vehicle was totaled
