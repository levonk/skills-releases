---
type: Practice
title: International Structures
description: Foreign entities for US persons — Estonia e-residency and the OÜ reality, EU entity cost map, EMI banking, non-EU alternatives, and the US compliance layer (CFC/NCTI, §962, FBAR, FATCA) that makes this a market-access play, not tax avoidance.
tags: [international, estonia, e-residency, ou-company, eu-business, cfc, ncti, gilti, section-962, fbar, fatca, offshore]
date:
  created: "2026-10-15"
  knowledge-basis: "2026-10-15"
  last-used: "2026-10-15"
sources:
  - id: e-residency
    resource: "https://www.e-resident.gov.ee/"
    title: "Republic of Estonia — e-Residency official program"
  - id: irs-fbar
    resource: "https://www.irs.gov/businesses/small-businesses-self-employed/report-of-foreign-bank-and-financial-accounts-fbar"
    title: "IRS — Report of Foreign Bank and Financial Accounts (FBAR)"
  - id: irs-5471
    resource: "https://www.irs.gov/forms-pubs/about-form-5471"
    title: "IRS — Form 5471, Information Return for Foreign Corporations"
---

# International Structures

For a US person, a foreign entity is almost never a tax *avoidance*
play — it's a **market-access play** (selling into the EU, hiring in
Europe) or an **asset-protection play** (offshore trusts), and it
always carries a US compliance tax.

## Estonia e-Residency and the OÜ

Estonia's e-residency is a **digital ID for running an Estonian
company remotely — nothing else.** It is not residency, not a visa,
not tax status.[^e-residency]

- Application is ~€150 (rising ~€165), a real company (OÜ) costs a
  few hundred euros to form; Estonia's corporate tax is 0% on
  *retained* earnings, ~22% on distributed profits — deferral, not
  exemption.
- The OÜ can be owned by a US holding LLC with you as the natural
  person board member — but UBO disclosure applies.
- **The real friction is banking, not formation.** Post-scandal,
  Estonian banks require an economic link to Estonia — e-residency
  alone is not sufficient. The practical answer is EMIs: Wise
  (Belgian IBAN) or Revolut Business (Lithuanian IBAN), trading the
  €100k EU deposit-guarantee level of a full bank for remote
  onboarding.
- **Board-fee tax trap**: paying yourself director fees from an OÜ is
  taxed in Estonia regardless of where you live — take dividends or
  salary structured carefully.
- **Verdict**: don't rush e-residency as a geopolitical hedge — the
  program is expanding, and the value is EU market access, not
  protection. If you don't have EU customers, you don't need it.

## The EU Cost Map

All-in first-year and recurring costs vary ~10× across the EU —
Romania and Bulgaria headline cheapest, Estonia mid-pack via
formation agents, Germany/Luxembourg most expensive. Compare **total
year-one cost** (formation + registered office + accounting +
filings), not formation price.

## Non-EU Alternatives

- **UAE/Dubai** — 0% personal tax, 9% corporate above a small
  threshold (0% for qualifying free-zone persons); realistic floor
  ~$30k/year all-in (visas, office, substance). Works when you're
  actually relocating or genuinely operating there — as a paper
  structure it's expensive and fragile.
- **Singapore** — 17% headline but effective ~5–10% with exemptions;
  the hidden cost is the **mandatory resident director** (~S$2–5k/yr
  for a nominee) plus real substance expectations.
- **Georgia (country)** — very cheap formation (~$22) and ~1% small-
  business tax to a cap, but weak banking, no SEPA/Stripe — fine for
  a lean solo operation, not for scaling.

## The US Compliance Layer (the part that decides feasibility)

A solo US founder owning a foreign company creates a **Controlled
Foreign Corporation** (CFC) — always. Consequences:

- **NCTI (formerly GILTI; renamed under OBBBA, effective 2026)** —
  the US taxes a share of the CFC's income annually even undistributed:
  the §250 deduction dropped to 40% (effective rate ~12.6%), the QBAI
  carve-out is gone, foreign-tax-credit use improved to 90%.
- **Form 5471** — annual information return for the CFC; the penalty
  for failure starts at **$10,000 per form per year**, plus FBAR
  (> $10k aggregate foreign accounts) and FATCA/Form 8938.[^irs-5471]
- **The §962 election** — lets an individual US shareholder be taxed
  on CFC income at *corporate* rates with corporate FTC rules; for a
  profitable foreign op it's frequently the single most valuable
  election available — model it every year.
- **CPA cost is the floor** — international-competent US tax prep runs
  ~$1,500–$5,000+/year, often exceeding the foreign entity's
  maintenance cost. Budget for the US side, not just the foreign side.

**Bottom line**: a foreign entity makes sense when there's a genuine
non-US reason (EU customers, actual relocation, real asset-protection
exposure). As tax arbitrage for a US resident it fails — the US taxes
worldwide income, and the compliance overhead eats any spread.

## Cautions

- **Penalties are asymmetric** — missed 5471/FBAR filings cost more
  than most structures save; the compliance calendar comes before the
  entity.
- **Substance is real** — paper companies without function are
  challenged under anti-avoidance rules in both the foreign country
  and the US.
- **Offshore trusts** (Cook Islands/Nevis) are asset-protection
  instruments at Tier 7–8 with full US reporting — not tax shelters;
  see [Asset Protection Ladder](asset-protection-ladder.md).
- **Numbers here are 2025–2026-specific** — fees, tax rates, and the
  NCTI rules shift; verify current figures before acting.

[^e-residency]: Republic of Estonia e-Residency program — digital
    identity for company administration, explicitly not residency or
    tax status.
[^irs-5471]: IRS Form 5471 — required for US shareholders of CFCs;
    penalties start at $10k.
[^irs-fbar]: FinCEN/IRS FBAR — required when aggregate foreign
    accounts exceed $10k at any point in the year.
