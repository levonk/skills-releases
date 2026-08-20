# Acquisition Strategy — Lease vs Finance vs Buy-New vs Refurbished vs Used

Detailed guidance for comparing acquisition *structures* (not just sticker
price) before making a purchase recommendation. Referenced by `INSTRUCTIONS.md`
Section 6. Acquisition Strategy. This reference sits **above** the other
deal-intelligence layers: sourcing (Section 2) decides *where* to buy,
purchase-optimization (Section 4) decides *how to pay* to reduce sticker price,
and this reference decides *the structure of the acquisition itself* — lease,
finance, buy-new, buy-refurbished, or buy-used/liquidation — with tax-adjusted
total cost of ownership (TCO) math.

## When to Run

Run acquisition-strategy analysis when **any** of these apply:

- The item has **lease options** (Apple Business Lease, equipment leasing,
  auto leasing) and the user may have a tax write-off path
- The item has **financing options** (0% APR promotions, installment plans,
  Apple Card Monthly Installments, manufacturer financing)
- The item has a **rich second-hand market** (Macs, iPhones, cameras, watches,
  cars, industrial equipment) where used/refurbished could deliver better
  price/performance
- The item is **high-value** (Effort Tier Major $500–$5k or High-value $5k+)
  and the structure decision materially changes TCO
- A **new version is imminent** (product lifecycle signal from market-timing)
  — this changes the residual value of buying now vs waiting
- The user **frequently upgrades** (every 1–3 years) and dislikes reselling —
  lease may make sense even without a tax write-off

**Skip for:** Quick tier (under $50), consumables, low-value items with no
lease/finance/used-market, or items where the structure decision cannot change
TCO by more than the analysis cost.

## The Five Acquisition Structures

| Structure | When it wins | When it loses | Key variables |
|-----------|--------------|---------------|---------------|
| **Buy new (cash/card)** | Long hold (4+ yr), no write-off, want full ownership & resale value | Short hold, frequent upgrades, cash flow constrained | Sticker price, residual value, sales tax |
| **Buy new (0% financing)** | Always wins vs cash if 0% APR and no surcharge — time value of money | When 0% APR requires giving up a cash discount that exceeds the financing benefit | APR, term, cash-discount forgone, opportunity cost rate |
| **Buy refurbished (manufacturer)** | Mid-hold (2–4 yr), want warranty at lower cost, acceptable cosmetic blemish | When refurb discount < 10% (not worth the risk), or model is too new to have refurbs | Refurb discount %, warranty length, cosmetic tolerance |
| **Buy used / liquidation** | Long hold, rich 2nd-hand market, new version imminent (depreciation cliff), tax write-off on used purchase, sales-tax avoidance | When used price > 80% of new (risk not worth savings), lock risk on tied devices (Macs, phones), no warranty | Used price, residual value, sales-tax avoidance, lock-verification cost, warranty gap |
| **Lease** | Short hold (1–3 yr), frequent upgrades, tax write-off (Section 179 / business lease), no resale hassle, predictable monthly cost | Long hold (lease total > buy + resell), no tax write-off, early-termination penalties, mileage/usage limits | Monthly payment, term, residual at end, buyout option, tax deductibility |

## Tax-Adjusted TCO Math

The core insight: **the same sticker price costs different net amounts
depending on acquisition structure, tax position, and residual value.** Run
the math for each candidate structure and compare on a tax-adjusted NPV basis.

### Inputs

| Variable | Symbol | Example (Mac Studio M3 Ultra 256GB) |
|-----------|--------|--------------------------------------|
| Sticker price (new) | `P_new` | $7,199 |
| Refurbished price | `P_refurb` | $6,119 (15% off) |
| Used price (2nd-hand) | `P_used` | $5,500 |
| Sales tax rate | `r_sales` | 10% (California) |
| Effective income tax rate | `r_tax` | 38% (federal + state blended) |
| Holding period (years) | `n` | 3 |
| Residual value at end of hold | `V_residual` | $2,500 (35% of new after 3 yr) |
| Opportunity cost rate (annual) | `r_opp` | 5% (T-bill / HYSA) |
| Lease monthly payment | `M_lease` | $199/mo |
| Lease term (months) | `t_lease` | 36 |
| Lease buyout at end | `B_lease` | $3,500 (fair market value) |
| Financing APR | `apr` | 0% (Apple Card Monthly Installments) |
| Financing term (months) | `t_fin` | 12 |
| Section 179 / depreciation eligible? | `sec179` | true (business use) |
| Sales tax avoidable on used? | `avoid_sales_tax_used` | true (private-party in CA) |

### Formulas

**1. Buy New (cash) — tax-adjusted NPV:**

```
Cost_new = P_new × (1 + r_sales)                    # if sales tax applies
         - [Section 179 deduction] × r_tax           # if business-eligible
         - V_residual / (1 + r_opp)^n                # PV of residual recovered at sale

# Section 179 deduction: full P_new in year 1 (if eligible, ≤ $1.16M limit 2024)
# Or MACRS: 5-yr property → 20% yr1, 32% yr2, 19.2% yr3, 11.52% yr4, 11.52% yr5, 5.76% yr6
# Bonus depreciation (phasing out): 60% 2024, 40% 2025, 20% 2026, 0% 2027
```

**2. Buy New (0% financing) — tax-adjusted NPV:**

```
Cost_fin = sum over months m=1..t_fin of:
             (P_new / t_fin) × (1 + r_sales if month 1)   # even split, sales tax upfront
           - [Section 179 deduction × r_tax] / (1 + r_opp)^0   # deduction taken year 1
           - V_residual / (1 + r_opp)^n

# 0% financing wins over cash when:
#   opportunity_cost_savings > cash_discount_forgone
# i.e., keeping P_new in a 5% HYSA for t_fin months earns more than any
# cash-discount you give up by financing. With 0% APR and no cash-discount
# forgone, financing ALWAYS wins vs cash (time value of money is free money).
```

**3. Buy Refurbished — tax-adjusted NPV:**

```
Cost_refurb = P_refurb × (1 + r_sales)
            - [Section 179 deduction × r_tax]    # refurbs qualify if business use
            - V_residual_refurb / (1 + r_opp)^n  # residual slightly lower than new

# Refurb wins when: P_new - P_refurb > warranty_risk_premium + residual_delta
# Typical refurb discount: 10–20% (Apple Certified Refurbished is 15% off)
# Warranty: Apple refurb = same 1-yr warranty as new
```

**4. Buy Used / Liquidation — tax-adjusted NPV:**

```
Cost_used = P_used × (1 + r_sales × (1 - avoid_sales_tax_used))   # sales tax may be avoidable
          - [Section 179 deduction × r_tax]                       # if business use & receipted
          - V_residual_used / (1 + r_opp)^n
          + lock_verification_cost                                 # time + risk of locked device
          + warranty_gap_risk                                      # (failure_prob × replacement_cost)

# Used wins when:
#   (P_new - P_used) + sales_tax_avoided > lock_risk + warranty_gap + residual_delta
# Sales tax avoidance (CA private-party): saves r_sales × P_used = 10% × $5,500 = $550
# Lock risk on Macs: see lock-verification section below — can total the device
```

**5. Lease — tax-adjusted NPV:**

```
Cost_lease = sum over months m=1..t_lease of:
               M_lease / (1 + r_opp)^(m/12)                        # PV of monthly payments
             - [M_lease × 12 × r_tax] / (1 + r_opp)^(year)         # lease payments fully deductible
                                                                    # as operating expense (business)
           + [buyout if purchasing at end] B_lease / (1 + r_opp)^(t_lease/12)
           - V_residual_lease / (1 + r_opp)^(t_lease/12)           # if bought out and resold

# Lease wins when:
#   - User upgrades every 1–3 yr AND dislikes reselling
#   - Business use → lease payments are fully deductible as operating expense
#     (no Section 179 needed; simpler than depreciation schedule)
#   - No large upfront cash outlay
# Lease loses when:
#   - Long hold (total lease payments > buy + resell)
#   - Early termination penalties apply
#   - Mileage/usage limits (autos) or return-condition penalties (equipment)
```

### Lease-vs-Buy Breakeven

The breakeven holding period is where `Cost_lease = Cost_buy_new`:

```
Breakeven_n = the year where:
  sum(M_lease × 12 × years) - tax_savings_lease
  = P_new + sales_tax - tax_savings_179 - V_residual(years)

# If the user's expected hold < breakeven_n → lease wins
# If the user's expected hold > breakeven_n → buy wins
```

### "New Version Imminent" Depreciation Cliff

When market-timing signals a new version within 6 months:

- **Buy now:** residual value drops sharply at the new-version release. A Mac
  bought 3 months before a refresh loses ~15–20% more residual than one bought
  3 months after.
- **Wait:** opportunity cost of not having the device for 3–6 months. If the
  user needs it now, this is a real cost (lost productivity).
- **Lease:** insulates from the depreciation cliff — return at lease end
  regardless of new-version timing.
- **Buy used (previous-gen):** the previous-gen model's used price drops when
  the new version launches — buy used *after* the launch to capture the cliff.

**Decision rule:**
- Need it now + new version imminent → **lease** (insulates from cliff) or
  **buy used previous-gen** (capture the cliff post-launch)
- Can wait 3–6 months + new version imminent → **wait, buy new or refurb**
  after launch (avoid the cliff, get the new model at same price)

## Worked Example — MacBook Pro M5 Max vs Mac Studio M3 Ultra vs Wait for M5 Ultra

### The Decision

The user needs an Apple Silicon Mac for large-model ML work. Requirements:
M-series chip, max memory, max CPU performance, minimum 2TB SSD. Three
candidates:

| Candidate | Memory | SSD | Est. New Price | Availability |
|-----------|--------|-----|----------------|--------------|
| MacBook Pro M5 Max 128GB | 128 GB | 2 TB | ~$6,499 | Available now |
| Mac Studio M3 Ultra 256GB | 256 GB | 2 TB | ~$7,199 | Available now |
| Mac Studio M5 Ultra 256GB+ | 256 GB+ | 2 TB | ~$7,499 (est.) | Unknown — wait 6–12 mo? |

### Assumptions (User-Specified)

- Effective tax rate: 38% (federal + California state blended)
- Sales tax: 10% (California)
- Business use: Section 179 eligible (assume yes — verify with CPA)
- Holding period: 3 years (frequent upgrader)
- Opportunity cost rate: 5% (HYSA / T-bill)
- Apple Card: 3% Daily Cash on Apple purchases
- Sales tax avoidable on private-party used (CA)

### Acquisition Structures Evaluated

For each candidate, run all five structures through the math. The script
`scripts/acquisition_strategy.py` computes these deterministically.

**Candidate A: MacBook Pro M5 Max 128GB / 2TB — $6,499 new**

| Structure | Calculation | Tax-Adjusted NPV (3 yr) |
|-----------|-------------|--------------------------|
| Buy new (Apple Card 3%) | $6,499 × 0.97 × 1.10 = $6,927 − $2,469 (Sec 179 × 38%) − $1,620 (residual PV, 25% of $6,499) | **$2,838** |
| Buy new (0% APR 12 mo) | Same net as cash (0% APR, no discount forgone) + opportunity cost savings of ~$160 (5% on $6,499 for 12 mo) | **$2,678** |
| Buy refurb (15% off) | $5,524 × 1.10 = $6,076 − $2,099 (Sec 179) − $1,380 (residual, 25% of $5,524) | **$2,597** |
| Buy used (if findable) | $4,800 × 1.00 (no sales tax, private party) − $1,824 (Sec 179) − $1,200 (residual) + $200 lock-risk | **$1,976** |
| Lease (Apple Business Lease, est. $189/mo × 36) | PV of 36 × $189 = $6,804 − $2,585 (lease deduction × 38%) − $0 (return, no residual) | **$4,219** |

**Candidate B: Mac Studio M3 Ultra 256GB / 2TB — $7,199 new**

| Structure | Calculation | Tax-Adjusted NPV (3 yr) |
|-----------|-------------|--------------------------|
| Buy new (Apple Card 3%) | $7,199 × 0.97 × 1.10 = $7,663 − $2,735 (Sec 179) − $1,800 (residual PV, 25%) | **$3,128** |
| Buy new (0% APR 12 mo) | Same + ~$180 opportunity savings | **$2,948** |
| Buy refurb (15% off) | $6,119 × 1.10 = $6,731 − $2,325 − $1,530 (residual) | **$2,876** |
| Buy used (if findable) | $5,500 × 1.00 − $2,090 − $1,375 + $200 lock-risk | **$2,235** |
| Lease (est. $209/mo × 36) | PV of 36 × $209 = $7,524 − $2,859 − $0 | **$4,665** |

**Candidate C: Wait for Mac Studio M5 Ultra 256GB+ — ~$7,499 (est., 6–12 mo out)**

| Structure | Calculation | Tax-Adjusted NPV (3 yr from acquisition) |
|-----------|-------------|------------------------------------------|
| Buy new (Apple Card 3%) | $7,499 × 0.97 × 1.10 = $8,014 − $2,850 − $2,000 (residual, higher gen holds value) | **$3,164** |
| Buy new (0% APR) | Same + ~$190 opportunity savings | **$2,974** |
| Opportunity cost of waiting | Lost productivity for 6–12 mo — user-defined (if ML work is blocked, this could be $1k–$10k+/mo) | **Subtract from all C rows** |

### Analysis

1. **Buy used wins on pure cost** for both available candidates — IF a
   findable, unlocked, receipted unit exists. Mac Studio M3 Ultra 256GB is a
   niche config; the used market is thin. MacBook Pro M5 Max 128GB is newer
   and even thinner. **Risk: low availability + lock risk.**

2. **0% financing always beats cash** when there's no cash-discount forgone
   (Apple Card Monthly Installments at 0% + keep the cash in a 5% HYSA). The
   3% Apple Cash on the sticker price is a separate benefit that stacks.

3. **Refurbished is the sweet spot** when used is unfindable: 15% off, same
   1-year warranty, qualifies for Section 179, lower lock risk than used
   (Apple-refurb units are clean-titled). Check
   `https://www.apple.com/shop/refurbished/mac/macbook-pro` and
   `https://www.apple.com/shop/refurbished/mac/mac-studio` — inventory rotates.

4. **Lease loses on pure 3-year cost** for both candidates — but wins if the
   user upgrades every 2 years instead of 3, or if Section 179 is unavailable
   (lease payments are fully deductible as operating expense without needing
   the Section 179 election).

5. **Waiting for M5 Ultra** only wins if (a) the user can tolerate the delay
   (opportunity cost of blocked ML work is the deciding factor) and (b) the
   M5 Ultra offers a meaningful performance/memory uplift over M3 Ultra 256GB.
   If the M3 Ultra 256GB already meets the "max memory" need, waiting is hard
   to justify unless the hold period extends to 4+ years (newer gen holds
   residual value longer).

### Recommendation Logic (Not a Hardcoded Answer)

The script produces the numbers; the agent applies the user's constraints:

- If **max memory is the binding constraint** and 128GB (M5 Max) is
  insufficient → Mac Studio M3 Ultra 256GB or wait for M5 Ultra 256GB+
- If **portability matters** → MacBook Pro M5 Max 128GB (only portable option)
- If **used findable + unlocked + receipted** → buy used (lowest NPV)
- If **used unfindable + risk-averse** → buy refurbished from Apple
- If **frequent upgrader (≤2 yr) + business use** → lease (insulates from
  depreciation cliff, simpler tax treatment)
- If **0% APR available** → always take it (free money) regardless of buy vs
  refurb; stack with Apple Card 3% if paying through Apple
- If **new version imminent + can wait** → wait, then buy new/refurb post-launch
- If **new version imminent + can't wait** → lease or buy used previous-gen
  post-launch

## Lock Verification — Critical for Used Macs

**Before buying any used Apple device, run the full lock-verification
procedure.** A locked Mac is a paperweight, not a discount. The lock types:

- **Activation Lock** (Apple Silicon + T2 Intel) — survives erasure
- **MDM / Remote Management / ABM** (Apple Business Manager) — survives wipe,
  re-enrolls on setup, can be remotely locked weeks later
- **Firmware / EFI password** — blocks boot from external media

The full in-person verification procedure (do-with-seller vs do-later steps)
is in:
- `needs-discovery/references/domains/computers.md` — lock types, receipt
  retention, used-computer quick reference
- `needs-discovery/references/domains/mobile-phones.md` — carrier locks,
  IMEI blacklist, activation verification (for iPhone/iPad)
- `acquisition/references/handoff-verification.md` — the full in-person
  handoff protocol with erase-and-reset test

**Never skip lock verification to close a "deal".** The $200–$500 saved on a
used Mac is worthless if the machine is ABM-enrolled and gets remote-locked
in month 2. The lock-verification cost (30–60 min at handoff) is a required
input to the used-acquisition NPV, not an optional step.

## Sourcing Channels for Used/Refurbished/Liquidation

Beyond Apple's own refurbished store, source used Macs from:

- **Apple Certified Refurbished** — `apple.com/shop/refurbished/mac/` — 15%
  off, same 1-yr warranty, clean-titled (no lock risk)
- **Authorized resellers** (B&H Photo, Adorama, Experimax) — refurbished,
  open-box, clearance
- **Flash-sale sites** (Whatnot, eBay auctions) — good for older models,
  verify lock status before bidding
- **Government surplus** (GovDeals, GSA Auctions, state surplus) — enterprise
  refresh cycles; **high ABM/MDM risk** — demand deaccession proof
- **Enterprise liquidation** (B-Stock, ITAD firms) — corporate refresh
  pallets; **highest ABM risk** — many "locked" used Macs came from companies
  that didn't deaccession properly
- **Second-hand marketplaces** (Swappa, Back Market, eBay, Facebook
  Marketplace, Craigslist) — widest selection, highest lock/scam risk

See `references/sourcing-guide.md` and `references/sourcing-sources.toml` for
the full channel inventory with buyer's premiums, condition, and risk notes.

## Apple-Specific Acquisition Stack

Apple offers the full acquisition stack on its own site — evaluate all of it:

| Option | Where | Notes |
|--------|-------|-------|
| Buy new (full price) | apple.com, Apple Store | 3% Apple Card Daily Cash |
| 0% financing | Apple Card Monthly Installments | 12–24 mo 0% APR, no surcharge; 3% Apple Cash still applies |
| Lease (business) | Apple Business Lease / Apple Financial Services | Business only; monthly payments, return or buyout at end |
| Refurbished | apple.com/shop/refurbished | 15% off, same 1-yr warranty, new shell + battery |
| Trade-in | apple.com/shop/trade-in | Credit toward new purchase; reduces net cost |

**Stacking:** Apple Card 3% + 0% APR financing + trade-in credit + Section 179
deduction (if business) can combine. The 3% Apple Cash applies to the
post-trade-in balance. Trade-in credit reduces the Section 179 basis (the
deduction is on the net purchase price, not the sticker).

## Output Format — Acquisition Strategy Report

```markdown
### Acquisition Strategy Analysis

#### Candidates
| Candidate | Config | New Price | Source |
|-----------|--------|-----------|--------|
| [name] | [chip/memory/SSD] | $X | [retailer] |

#### Tax-Adjusted NPV (n-year hold, 38% tax, 10% sales tax)
| Candidate | Buy New (cash) | Buy New (0% fin) | Refurb | Used | Lease |
|-----------|----------------|------------------|--------|------|-------|
| [name] | $X | $X | $X | $X | $X |

#### Sensitivity
- Hold period: 2 yr → [which structure wins]
- Hold period: 4 yr → [which structure wins]
- No Section 179 → [which structure wins]
- New version imminent → [depreciation cliff impact]

#### Recommendation
[Based on user constraints: max memory, portability, risk tolerance,
upgrade frequency, tax position, time-to-need]

#### Lock-Verification Requirement (if used/refurb from non-Apple source)
→ Follow `acquisition/references/handoff-verification.md` at handoff

#### Next Step
→ Hand off to shopping-acquisition skill for purchase execution
```

<!-- vim: set ft=markdown -->
