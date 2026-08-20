#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
Acquisition Strategy Calculator — compare lease vs finance vs buy-new vs
refurbished vs used on a tax-adjusted NPV basis.

Computes the tax-adjusted net present value (NPV) of each acquisition structure
so the deal-intelligence skill can recommend the lowest-net-cost path. The math
lives in `references/acquisition-strategy.md`; this script is the deterministic
implementation.

Inputs are per-candidate: sticker price, refurbished price, used price, lease
terms, financing terms, residual value, holding period, tax rates, and
eligibility flags (Section 179, sales-tax avoidance on used).

Usage:
    # Single candidate, defaults (38% tax, 10% sales tax, 3-yr hold, 5% opp cost)
    uv run --script scripts/acquisition_strategy.py \
        --name "Mac Studio M3 Ultra 256GB" --new-price 7199 --residual 2500

    # Full candidate with all structures
    uv run --script scripts/acquisition_strategy.py \
        --name "MacBook Pro M5 Max 128GB" \
        --new-price 6499 --refurb-price 5524 --used-price 4800 \
        --residual-new 1620 --residual-refurb 1380 --residual-used 1200 \
        --lease-monthly 189 --lease-term 36 \
        --fin-apr 0 --fin-term 12 \
        --apple-card-pct 3 \
        --sec179 --sales-tax-avoidable-used

    # Compare multiple candidates (JSON for piping)
    uv run --script scripts/acquisition_strategy.py --json \
        --name "MacBook Pro M5 Max" --new-price 6499 --residual 1620 \
        --name "Mac Studio M3 Ultra" --new-price 7199 --residual 2500

    # Sensitivity analysis across hold periods
    uv run --script scripts/acquisition_strategy.py \
        --name "Mac Studio M3 Ultra" --new-price 7199 --residual 2500 \
        --sensitivity hold:2,3,4

    # No Section 179 scenario
    uv run --script scripts/acquisition_strategy.py \
        --name "Mac Studio M3 Ultra" --new-price 7199 --residual 2500 --no-sec179

Output:
    Text: a per-candidate table of NPV by structure, with the winner flagged.
    JSON: machine-readable results for piping into the Deal Intelligence Report.

Exit codes:
    0 — success
    1 — argument error
    2 — no candidates provided
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from dataclasses import dataclass, field, asdict
from typing import Optional


# ---------------------------------------------------------------------------
# Data model
# ---------------------------------------------------------------------------

@dataclass
class Candidate:
    """One acquisition candidate (e.g., a specific Mac config)."""
    name: str
    new_price: float
    residual_new: float = 0.0
    refurb_price: Optional[float] = None
    residual_refurb: Optional[float] = None
    used_price: Optional[float] = None
    residual_used: Optional[float] = None
    lease_monthly: Optional[float] = None
    lease_term_months: Optional[int] = None
    lease_buyout: float = 0.0
    fin_apr: float = 0.0
    fin_term_months: int = 0
    apple_card_pct: float = 0.0
    sec179: bool = False
    sales_tax_avoidable_used: bool = False
    lock_verification_cost: float = 0.0
    warranty_gap_risk: float = 0.0


@dataclass
class Assumptions:
    """Global tax and financial assumptions applied to all candidates."""
    sales_tax_rate: float = 0.10       # California
    effective_tax_rate: float = 0.38   # federal + state blended
    hold_years: int = 3
    opportunity_rate: float = 0.05     # HYSA / T-bill


@dataclass
class StructureResult:
    """NPV result for one acquisition structure."""
    structure: str
    npv: float
    notes: str = ""


@dataclass
class CandidateResult:
    """Full result for one candidate across all structures."""
    name: str
    structures: list[StructureResult] = field(default_factory=list)
    winner: str = ""
    winner_npv: float = 0.0


# ---------------------------------------------------------------------------
# Math — each structure's tax-adjusted NPV
# ---------------------------------------------------------------------------

def _pv(amount: float, years: float, rate: float) -> float:
    """Present value of `amount` received `years` from now at `rate`."""
    return amount / math.pow(1 + rate, years)


def _sec179_deduction(price: float, tax_rate: float) -> float:
    """Section 179: full price deducted in year 1, multiplied by tax rate."""
    return price * tax_rate


def _lease_tax_savings(monthly: float, term_months: int, tax_rate: float,
                       opp_rate: float) -> float:
    """PV of tax savings from lease payments (fully deductible as operating
    expense). Payments are spread monthly; tax savings realized annually."""
    annual_payment = monthly * 12
    total_years = term_months / 12
    savings = 0.0
    for yr in range(int(total_years) + 1):
        fraction = 1.0 if yr < int(total_years) else (total_years - int(total_years))
        if fraction <= 0:
            break
        savings += _pv(annual_payment * fraction * tax_rate, yr, opp_rate)
    return savings


def npv_buy_new_cash(c: Candidate, a: Assumptions) -> StructureResult:
    """Buy new with cash/card. Includes Apple Card cashback if specified."""
    price = c.new_price
    if c.apple_card_pct > 0:
        price *= (1 - c.apple_card_pct / 100)
    sales_tax = price * a.sales_tax_rate
    upfront = price + sales_tax
    tax_savings = _sec179_deduction(price, a.effective_tax_rate) if c.sec179 else 0.0
    residual_pv = _pv(c.residual_new, a.hold_years, a.opportunity_rate)
    npv = upfront - tax_savings - residual_pv
    notes = []
    if c.apple_card_pct > 0:
        notes.append(f"{c.apple_card_pct}% card cashback applied")
    if c.sec179:
        notes.append("Section 179 deduction (year 1)")
    notes.append(f"residual ${c.residual_new:.0f} at {a.hold_years}yr")
    return StructureResult("Buy New (cash)", npv, "; ".join(notes))


def npv_buy_new_finance(c: Candidate, a: Assumptions) -> StructureResult:
    """Buy new with financing (e.g., 0% APR Apple Card Monthly Installments).

    At 0% APR with no cash-discount forgone, financing saves the opportunity
    cost of keeping the cash invested for the financing term. Sales tax is
    due upfront (month 1). Section 179 deduction still applies (cost basis is
    the full purchase price regardless of financing).
    """
    if c.fin_term_months <= 0 or c.fin_apr < 0:
        return StructureResult("Buy New (finance)", float("inf"),
                                "financing not configured")
    price = c.new_price
    if c.apple_card_pct > 0:
        price *= (1 - c.apple_card_pct / 100)
    sales_tax = price * a.sales_tax_rate
    # Sales tax upfront, principal split evenly across months
    monthly_principal = price / c.fin_term_months
    # PV of all monthly payments + upfront sales tax
    payment_pv = sales_tax  # month 0
    for m in range(1, c.fin_term_months + 1):
        interest = 0.0 if c.fin_apr == 0 else (price * (c.fin_apr / 100) / 12)
        payment = monthly_principal + interest
        payment_pv += _pv(payment, m / 12, a.opportunity_rate)
        price -= monthly_principal  # declining balance for interest calc
    tax_savings = _sec179_deduction(c.new_price * (1 - c.apple_card_pct / 100),
                                     a.effective_tax_rate) if c.sec179 else 0.0
    residual_pv = _pv(c.residual_new, a.hold_years, a.opportunity_rate)
    npv = payment_pv - tax_savings - residual_pv
    notes = f"{c.fin_apr}% APR, {c.fin_term_months}mo"
    if c.fin_apr == 0:
        notes += " (0% → opportunity savings vs cash)"
    if c.sec179:
        notes += "; Section 179"
    return StructureResult("Buy New (finance)", npv, notes)


def npv_buy_refurb(c: Candidate, a: Assumptions) -> StructureResult:
    """Buy manufacturer-refurbished (e.g., Apple Certified Refurbished, 15% off)."""
    if c.refurb_price is None:
        return StructureResult("Buy Refurbished", float("inf"),
                                "no refurb price provided")
    price = c.refurb_price
    if c.apple_card_pct > 0:
        price *= (1 - c.apple_card_pct / 100)
    sales_tax = price * a.sales_tax_rate
    upfront = price + sales_tax
    tax_savings = _sec179_deduction(price, a.effective_tax_rate) if c.sec179 else 0.0
    residual = c.residual_refurb if c.residual_refurb is not None else c.residual_new * 0.85
    residual_pv = _pv(residual, a.hold_years, a.opportunity_rate)
    npv = upfront - tax_savings - residual_pv
    discount_pct = (1 - c.refurb_price / c.new_price) * 100 if c.new_price > 0 else 0
    return StructureResult(
        "Buy Refurbished", npv,
        f"{discount_pct:.0f}% off new; residual ${residual:.0f}",
    )


def npv_buy_used(c: Candidate, a: Assumptions) -> StructureResult:
    """Buy used / liquidation. Sales tax may be avoidable (private party).
    Includes lock-verification cost and warranty-gap risk."""
    if c.used_price is None:
        return StructureResult("Buy Used", float("inf"),
                                "no used price provided")
    price = c.used_price
    # Sales tax: avoidable if private-party in some states (CA)
    sales_tax = price * a.sales_tax_rate * (0.0 if c.sales_tax_avoidable_used else 1.0)
    upfront = price + sales_tax
    tax_savings = _sec179_deduction(price, a.effective_tax_rate) if c.sec179 else 0.0
    residual = c.residual_used if c.residual_used is not None else c.residual_new * 0.70
    residual_pv = _pv(residual, a.hold_years, a.opportunity_rate)
    npv = upfront - tax_savings - residual_pv + c.lock_verification_cost + c.warranty_gap_risk
    notes = []
    if c.sales_tax_avoidable_used:
        notes.append(f"sales tax avoided (${price * a.sales_tax_rate:.0f})")
    if c.lock_verification_cost > 0:
        notes.append(f"lock-risk ${c.lock_verification_cost:.0f}")
    if c.warranty_gap_risk > 0:
        notes.append(f"warranty-gap ${c.warranty_gap_risk:.0f}")
    notes.append(f"residual ${residual:.0f}")
    return StructureResult("Buy Used", npv, "; ".join(notes) or "no adjustments")


def npv_lease(c: Candidate, a: Assumptions) -> StructureResult:
    """Lease — monthly payments, fully deductible as operating expense (no
    Section 179 needed). Optional buyout at end."""
    if c.lease_monthly is None or c.lease_term_months is None:
        return StructureResult("Lease", float("inf"),
                                "no lease terms provided")
    monthly = c.lease_monthly
    term = c.lease_term_months
    # PV of monthly payments
    payment_pv = 0.0
    for m in range(1, term + 1):
        payment_pv += _pv(monthly, m / 12, a.opportunity_rate)
    # Tax savings: lease payments fully deductible as operating expense
    tax_savings = _lease_tax_savings(monthly, term, a.effective_tax_rate,
                                      a.opportunity_rate)
    # Buyout at end (if user purchases the device)
    buyout_pv = _pv(c.lease_buyout, term / 12, a.opportunity_rate) if c.lease_buyout > 0 else 0.0
    # If bought out, residual can be recovered by reselling
    residual_pv = 0.0
    if c.lease_buyout > 0:
        residual = c.residual_new * 0.50  # residual at lease end is lower
        residual_pv = _pv(residual, term / 12, a.opportunity_rate)
    npv = payment_pv - tax_savings + buyout_pv - residual_pv
    notes = f"${monthly}/mo × {term}mo"
    if c.lease_buyout > 0:
        notes += f"; buyout ${c.lease_buyout}"
    else:
        notes += "; return (no buyout)"
    notes += "; operating-expense deduction"
    return StructureResult("Lease", npv, notes)


# ---------------------------------------------------------------------------
# Orchestration
# ---------------------------------------------------------------------------

def evaluate_candidate(c: Candidate, a: Assumptions) -> CandidateResult:
    """Run all five structures for one candidate and pick the winner."""
    structures = [
        npv_buy_new_cash(c, a),
        npv_buy_new_finance(c, a),
        npv_buy_refurb(c, a),
        npv_buy_used(c, a),
        npv_lease(c, a),
    ]
    # Winner = lowest finite NPV
    finite = [s for s in structures if math.isfinite(s.npv)]
    winner = min(finite, key=lambda s: s.npv) if finite else None
    result = CandidateResult(name=c.name, structures=structures)
    if winner:
        result.winner = winner.structure
        result.winner_npv = winner.npv
    return result


def run_sensitivity(c: Candidate, a: Assumptions,
                    hold_periods: list[int]) -> list[dict]:
    """Re-run the evaluation at multiple hold periods."""
    out = []
    for n in hold_periods:
        a2 = Assumptions(sales_tax_rate=a.sales_tax_rate,
                         effective_tax_rate=a.effective_tax_rate,
                         hold_years=n,
                         opportunity_rate=a.opportunity_rate)
        res = evaluate_candidate(c, a2)
        out.append({
            "hold_years": n,
            "winner": res.winner,
            "winner_npv": round(res.winner_npv, 2),
            "structures": {s.structure: round(s.npv, 2) for s in res.structures},
        })
    return out


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def _parse_candidates(args: argparse.Namespace) -> list[Candidate]:
    """Parse repeated --name/--new-price groups into candidates."""
    names = args.name or []
    prices = args.new_price or []
    if not names:
        return []
    if len(prices) != len(names):
        print("Error: --new-price must be provided once per --name",
              file=sys.stderr)
        sys.exit(1)
    # Repeated lists align by index
    residuals = args.residual or [0.0] * len(names)
    refurb_prices = args.refurb_price or [None] * len(names)
    used_prices = args.used_price or [None] * len(names)
    lease_monthlies = args.lease_monthly or [None] * len(names)
    lease_terms = args.lease_term or [None] * len(names)
    candidates = []
    for i, name in enumerate(names):
        candidates.append(Candidate(
            name=name,
            new_price=prices[i],
            residual_new=residuals[i] if i < len(residuals) else 0.0,
            refurb_price=refurb_prices[i] if i < len(refurb_prices) else None,
            used_price=used_prices[i] if i < len(used_prices) else None,
            lease_monthly=lease_monthlies[i] if i < len(lease_monthlies) else None,
            lease_term_months=lease_terms[i] if i < len(lease_terms) else None,
            apple_card_pct=args.apple_card_pct,
            sec179=not args.no_sec179,
            sales_tax_avoidable_used=args.sales_tax_avoidable_used,
            lock_verification_cost=args.lock_verification_cost,
            warranty_gap_risk=args.warranty_gap_risk,
            fin_apr=args.fin_apr,
            fin_term_months=args.fin_term,
            lease_buyout=args.lease_buyout,
        ))
    return candidates


def main() -> int:
    p = argparse.ArgumentParser(
        description="Acquisition Strategy Calculator — lease vs finance vs "
                    "buy-new vs refurb vs used, tax-adjusted NPV.",
    )
    # Candidate spec (repeatable for multi-candidate comparison)
    p.add_argument("--name", action="append", help="Candidate name (repeatable)")
    p.add_argument("--new-price", type=float, action="append",
                   help="New sticker price (repeatable, one per --name)")
    p.add_argument("--residual", type=float, action="append",
                   help="Residual value at end of hold (repeatable)")
    p.add_argument("--refurb-price", type=float, action="append",
                   help="Refurbished price (repeatable)")
    p.add_argument("--used-price", type=float, action="append",
                   help="Used price (repeatable)")
    p.add_argument("--lease-monthly", type=float, action="append",
                   help="Lease monthly payment (repeatable)")
    p.add_argument("--lease-term", type=int, action="append",
                   help="Lease term in months (repeatable)")
    # Global assumptions
    p.add_argument("--sales-tax", type=float, default=0.10,
                   help="Sales tax rate (default 0.10 = 10%%)")
    p.add_argument("--tax-rate", type=float, default=0.38,
                   help="Effective income tax rate (default 0.38)")
    p.add_argument("--hold-years", type=int, default=3,
                   help="Holding period in years (default 3)")
    p.add_argument("--opp-rate", type=float, default=0.05,
                   help="Opportunity cost rate (default 0.05)")
    # Flags
    p.add_argument("--no-sec179", action="store_true",
                   help="No Section 179 / depreciation deduction")
    p.add_argument("--sales-tax-avoidable-used", action="store_true",
                   help="Sales tax avoidable on used (private party)")
    p.add_argument("--apple-card-pct", type=float, default=0.0,
                   help="Apple Card / rewards cashback percent (default 0)")
    p.add_argument("--fin-apr", type=float, default=0.0,
                   help="Financing APR percent (default 0)")
    p.add_argument("--fin-term", type=int, default=0,
                   help="Financing term in months (default 0 = disabled)")
    p.add_argument("--lease-buyout", type=float, default=0.0,
                   help="Lease buyout at end (default 0 = return)")
    p.add_argument("--lock-verification-cost", type=float, default=200.0,
                   help="Lock-verification time/risk cost for used (default 200)")
    p.add_argument("--warranty-gap-risk", type=float, default=0.0,
                   help="Warranty-gap risk for used (default 0)")
    p.add_argument("--sensitivity", type=str, default="",
                   help="Sensitivity analysis: 'hold:2,3,4' or 'tax:0.28,0.38,0.48'")
    p.add_argument("--json", action="store_true", help="JSON output")
    args = p.parse_args()

    candidates = _parse_candidates(args)
    if not candidates:
        print("Error: provide at least one candidate via --name and --new-price",
              file=sys.stderr)
        return 2

    assumptions = Assumptions(
        sales_tax_rate=args.sales_tax,
        effective_tax_rate=args.tax_rate,
        hold_years=args.hold_years,
        opportunity_rate=args.opp_rate,
    )

    results = [evaluate_candidate(c, assumptions) for c in candidates]

    # Sensitivity
    sensitivity_out = {}
    if args.sensitivity:
        key, values = args.sensitivity.split(":", 1)
        nums = [float(v) for v in values.split(",")]
        if key == "hold":
            for c in candidates:
                sensitivity_out[c.name] = run_sensitivity(
                    c, assumptions, [int(n) for n in nums])

    if args.json:
        out = {
            "assumptions": asdict(assumptions),
            "candidates": [
                {
                    "name": r.name,
                    "winner": r.winner,
                    "winner_npv": round(r.winner_npv, 2),
                    "structures": [
                        {"structure": s.structure,
                         "npv": round(s.npv, 2),
                         "notes": s.notes}
                        for s in r.structures
                    ],
                }
                for r in results
            ],
        }
        if sensitivity_out:
            out["sensitivity"] = sensitivity_out
        print(json.dumps(out, indent=2))
        return 0

    # Text output
    print(f"# Acquisition Strategy Analysis")
    print(f"Assumptions: {assumptions.hold_years}yr hold, "
          f"{assumptions.effective_tax_rate*100:.0f}% tax, "
          f"{assumptions.sales_tax_rate*100:.0f}% sales tax, "
          f"{assumptions.opportunity_rate*100:.0f}% opp cost")
    print()
    for r in results:
        print(f"## {r.name}")
        print(f"| Structure | NPV | Notes |")
        print(f"|-----------|-----|-------|")
        for s in r.structures:
            npv_str = f"${s.npv:,.0f}" if math.isfinite(s.npv) else "N/A"
            marker = " ← winner" if s.structure == r.winner else ""
            print(f"| {s.structure}{marker} | {npv_str} | {s.notes} |")
        print()
    if sensitivity_out:
        print("## Sensitivity — Hold Period")
        for name, runs in sensitivity_out.items():
            print(f"\n### {name}")
            print("| Hold (yr) | Winner | Winner NPV |")
            print("|-----------|--------|------------|")
            for run in runs:
                print(f"| {run['hold_years']} | {run['winner']} | "
                      f"${run['winner_npv']:,.0f} |")
    print("\n→ Hand off to shopping-acquisition skill for purchase execution")
    return 0


if __name__ == "__main__":
    sys.exit(main())
