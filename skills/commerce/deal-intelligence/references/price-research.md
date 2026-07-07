# Historical Price Research — Reference

Detailed source comparison and output format for building price history profiles. Referenced by `SKILL.md` section "1. Historical Price Research".

## Price History Sources

| Source | What it provides | How to use |
|--------|-----------------|------------|
| [CamelCamelCamel](https://camelcamelcamel.com/) | Amazon price history, all-time low, average | Establish price floor and fair-market baseline |
| [Wayback Machine](https://web.archive.org/) | Archived retailer pages | Verify historical MSRP, detect price inflation before "sales" |
| [Slickdeals](https://slickdeals.net/) | Community-sourced deals, historical deal threads | Find recurring deal patterns and typical discount depth |
| Closed auction data ([eBay sold](https://www.ebay.com/), [Mercari](https://www.mercari.com/)) | Actual transaction prices | Establish used/refurbished fair market value |
| [Google Shopping](https://shopping.google.com/) | Cross-retailer price comparison | Current lowest price across retailers |
| [Honey](https://www.joinhoney.com/) / [Keepa](https://keepa.com/) | Price drop alerts, coupon aggregation | Supplementary price tracking |

## Price Summary Table Format

```text
| Source | Current | 30-Day Low | 90-Day Low | All-Time Low | Avg Price |
|--------|---------|-----------|-----------|-------------|-----------|
| Amazon | $X | $X | $X | $X | $X |
| Walmart| $X | $X | — | — | — |
| eBay (used) | $X | $X | $X | — | $X |
```

<!-- vim: set ft=markdown -->
