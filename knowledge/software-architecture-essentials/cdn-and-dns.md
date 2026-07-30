---
type: Practice
title: CDN and DNS
description: Content delivery networks (push vs pull CDNs, edge caching) and the domain name system (record types, TTL caching) that routes users to the right edge.
tags: [architecture, cdn, dns, edge-caching, content-delivery, ttl]
date:
  created: "2026-07-24"
  knowledge-basis: "2026-07-24"
  last-used: "2026-07-24"
---

# CDN and DNS

## CDN

A CDN serves content from edge locations closer to the user. Reduces latency
and origin load.

| Type | Push CDN | Pull CDN |
|------|----------|----------|
| Upload | You push to CDN on change | CDN fetches on first request |
| Storage | Higher | Lower |
| Traffic to origin | Lower | Higher (until cached) |
| First request | Fast | Slower (cache miss) |
| Best for | Low traffic, rarely updated | High traffic, frequently accessed |

### Decision checklist

1. Is the content static (images, CSS, JS, video) or dynamic? Static only is
   simpler; dynamic requires edge compute or short TTLs.
2. How often does it change? Rare changes → push or long TTL. Frequent → pull
   with short TTL.
3. Can stale content be served for the TTL? If not, use instant purge or short
   TTL.
4. What is the egress cost vs origin compute cost? CDNs save origin compute
   but charge egress.

## DNS

Translates domain names to IP addresses. Hierarchical, with caching at every
level (browser, OS, resolver, authoritative). TTL controls cache lifetime.

### Common record types

| Record | Purpose |
|--------|---------|
| **A / AAAA** | Domain → IPv4 / IPv6 address |
| **CNAME** | Domain → another domain name |
| **NS** | Delegates to authoritative name servers |
| **MX** | Mail server for the domain |
| **TXT** | SPF, DKIM, verification |
| **SRV** | Service host and port |

### DNS as a routing tool

- **Round-robin A records** — distribute traffic.
- **Low TTL** — faster fail-over, more DNS query load.
- **Geo/health-based DNS** — route to nearest healthy region (Route 53,
  Cloudflare).

### Decision checklist

1. Do you need fast fail-over? Lower TTL (but not below 30s in normal times).
2. Do you route by geography? Use geo-DNS with health checks.
3. Is the service multi-region? Use weighted records or anycast.

## See Also

- [Load Balancing and Reverse Proxy](load-balancing-and-proxy.md) — CDN
  complements LBs at the edge.
- [Caching Strategies](caching-strategies.md) — CDN is the outermost cache
  layer.
- [Distribution and Packaging](distribution.md) — CDN distributes
  web-delivered content.

## Sources

- [The System Design Primer](https://github.com/donnemartin/system-design-primer)
  — Domain name system, Content delivery network.
