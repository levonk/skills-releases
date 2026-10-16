<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **finance** · Status:  · Version: 1.0.0

Personal wealth navigation guide — what to do next with your money at every net-worth stage. Locates the user on an eight-tier net-worth roadmap (Foundation <$100k through UHNW $50M+), then drives the matching playbook: emergency fund and debt ordering, tax-advantaged account sequencing, insurance and umbrella sizing, first entities (LLC/S-Corp), asset protection and tax-optimization ladders, trusts and advanced estate instruments, charitable structures, infinite/family banking, borrowing against assets, the micro family office operating system, family governance, international structures, and windfall handling. Materializes the wealth-planning-practices and estate-planning-practices knowledge bundles for offline use. Use when the user asks what to do with their money, how to structure wealth, whether they need an LLC or S-Corp, when to hire a tax strategist vs a CPA, how much umbrella insurance to carry, how to protect assets, whether infinite banking is worth it, how to borrow against a portfolio, how to set up a family office, what a windfall (lottery/inheritance/IPO) requires, or how to plan across generations. Make sure to use this skill whenever the user mentions personal net worth, wealth tiers, estate structuring, tax optimization strategy, asset protection, trusts (living/irrevocable/dynasty/DAPT/ILIT/GRAT), charitable giving structures, SBLOC/margin borrowing, infinite banking, family banking, micro family office, family governance, domicile/residency for taxes, foreign business entities, or sudden wealth events, even if they don't explicitly ask for guidance. Do NOT trigger on business financial-operations analysis (QuickBooks data, CFO briefings, burn rate/runway, vendor spend), tax preparation or filing, specific stock/crypto/investment picks, consumer credit counseling, or medical/estate-document questions with no wealth context (the cancer-patient skill and estate-planning-practices bundle cover illness-side estate readiness).

## Metadata

| Field | Value |
|-------|-------|
| Name | `wealth-planning` |
| Category | `finance` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## References

- [`references/included/knowledge/wealth-planning-practices/overview.md`](references/included/knowledge/wealth-planning-practices/overview.md) — the wealth-planning bundle (materialized at build time)
- [`references/included/knowledge/estate-planning-practices/overview.md`](references/included/knowledge/estate-planning-practices/overview.md) — the core estate documents bundle (materialized at build time)

---

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files
- **trigger-guard** (template, over-triggering-guard) — Shared over-triggering guard protocol
- **** (, bundled-dependency) — Bundled via includeTree for offline availability. The eight-tier net-worth roadmap and per-domain playbooks — accumulation ordering, advisors by tier, insurance levels, entity structuring, asset protection, tax ladders, residency and domestic havens, advanced estate instruments, charitable structures, infinite/family banking, borrowing against assets, micro family office, family governance, international structures, windfalls, business acquisition. Materialized at references/included/knowledge/wealth-planning-practices/ at build time.
- **** (, bundled-dependency) — Bundled via includeTree for offline availability. The core-documents floor required from Tier 1 — will, living trust, powers of attorney, advance directives, digital estate/beneficiaries, letter of instruction, after-death checklist. Materialized at references/included/knowledge/estate-planning-practices/ at build time.

---

- **Full skill**: [`skills/finance/wealth-planning/SKILL.md`](skills/finance/wealth-planning/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-10-16T00:10:26Z
