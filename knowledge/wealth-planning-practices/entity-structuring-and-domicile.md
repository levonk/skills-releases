---
type: Practice
title: Entity Structuring and Domicile
description: W-2 vs 1099 vs entity election, the S-Corp break-even, LLC operating-agreement essentials, DE/NV/WY corporate domicile, holding-company layering, and real-estate OpCo structuring.
tags: [llc, s-corp, c-corp, 1099, w2, entity, holding-company, delaware, wyoming, nevada, real-estate]
date:
  created: "2026-10-15"
  knowledge-basis: "2026-10-15"
  last-used: "2026-10-15"
sources:
  - id: irs-qbi
    resource: "https://www.irs.gov/newsroom/qualified-business-income-deduction"
    title: "IRS — Qualified Business Income deduction (§199A)"
---

# Entity Structuring and Domicile

Entities do three jobs: **liability firewalls**, **tax routing**, and
**privacy**. Tier 3–4 is when the first one usually appears (a
business or a rental); Tier 5 is when they stack into holding
structures.

## W-2 vs 1099 vs Entity

- **W-2 employee** — simplest, least control: no business deductions,
  employer-paid FICA share invisible. Optimize via benefits and
  account maxing, not entities.
- **1099 / sole prop** — full SE tax (~15.3% FICA equivalent), QBI
  deduction eligibility, deductible expenses. Fine below ~$80k net
  profit.
- **S-Corp election** — pays you a *reasonable salary* (payroll-taxed)
  and distributes the rest free of SE tax. **Break-even is roughly
  $80–100k of net profit** — below that, payroll/admin costs exceed
  the SE-tax savings. Risks: reasonable-compensation audits (setting
  salary artificially low), state wrinkles (e.g., CA's $800 minimum
  franchise tax and AB5 classification pressure).
- **C-Corp** — rarely right for personal services; enters the picture
  for venture-scale startups (QSBS) or retaining earnings at
  corporate rates.
- **QBI / §199A** — pass-throughs can deduct ~20% of qualified
  business income, but **SSTBs** (specified service trades — law,
  medicine, consulting, financial services) phase out at higher
  incomes; check current-year thresholds.[^irs-qbi]

## The LLC Operating Agreement (where protection actually lives)

The filed articles are public and thin; the **operating agreement is
the document that matters**:

- **Manager-managed** — members don't appear as managers; adds a
  privacy layer and cleaner signature authority.
- **Discretionary distributions** — never mandatory distributions
  except a tax-liability carve-out; mandatory distributions give a
  creditor a hook.
- **Charging-order provisions** — in NV/WY the charging order is the
  exclusive remedy: a creditor who wins a judgment against *you*
  gets a lien on distributions from *the LLC*, not the assets — and
  can owe tax on phantom income they never receive.
- **Buy-sell / death / transfer mechanics** — what happens to a
  member's interest at death, divorce, or dispute.
- **Separate books and accounts** — commingling pierces the veil;
  per-entity bank accounts and bookkeeping are non-optional.

## Corporate Domicile

- **Delaware** — the Court of Chancery, predictable business case
  law; default for VC-backed and would-be-public companies.
- **Nevada** — no corporate income tax framing, strong
  charging-order protection; popular for holding entities.
- **Wyoming** — low fees, privacy-friendly (anonymous-LLC marketing
  claims, though banks and the IRS still require beneficial-owner
  disclosure), strong charging-order statute; the standard pick for
  holding companies in the structures below.
- **Home state** — if you operate where you live, you register there
  anyway (foreign qualification); domicile choice adds value mainly
  for holding companies that don't operate anywhere.

## The Holding-Company Stack (Tier 5+)

The canonical layered structure for real assets:

```
Irrevocable / dynasty trust (top — estate shield)
  └── WY or NV holding LLC (liability firewall + privacy)
        ├── Operating LLC — property 1
        ├── Operating LLC — property 2
        └── Management company (optional)
```

Personal side runs parallel: revocable trust → personal holding
company. **Primary residence stays out of the OpCo stack** — keep it
in the revocable trust (or land trust) to preserve the §121
capital-gains exclusion (2-of-5-year ownership and use; $250k/$500k
exclusion). Pass-through LLCs beat S-Corps for rentals — an S-Corp's
distribution and stock-basis rules are hostile to real estate.

## Cautions

- **Series LLC** — cheaper (one filing, many cells) but legal
  separateness between cells is untested in many states and lenders
  hate them; use per-property LLCs once cash flow supports it.
- **Privacy ≠ secrecy.** Manager-managed structures and registered
  agents reduce casual visibility; they do not survive discovery,
  and beneficial-owner disclosure (FinCEN BOI regime, bank KYC, IRS)
  still applies.
- **Entity sprawl.** Each entity is books, a bank account, a tax
  filing, a registered-agent fee. Add one per real risk — not per
  podcast.

[^irs-qbi]: IRS, "Qualified Business Income Deduction" — §199A
    mechanics and SSTB phase-outs; thresholds adjust annually.
