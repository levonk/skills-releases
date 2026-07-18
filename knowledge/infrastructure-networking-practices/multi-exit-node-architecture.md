---
type: Practice
title: Multi-Exit Node Architecture
description: Three exit node configurations — Direct (OCI), NordVPN (privacy), Tor (high anonymity) — with dedicated Docker networks and Tailscale routing per exit node.
tags: [vpn, exit-node, nordvpn, tor, tailscale, docker, networking, privacy]
timestamp: 2026-07-17T00:00:00Z
---

# Multi-Exit Node Architecture

## Failure Mode

A single exit node provides no privacy options. All traffic exits from the same
IP regardless of sensitivity. No high-anonymity path exists for operations
requiring Tor-level privacy.

## Practice

Support **three exit node configurations** with different privacy/latency
tradeoffs:

| Exit Node | Latency | Bandwidth | Privacy | Use Case |
|-----------|---------|-----------|---------|----------|
| Direct (oci) | Low | High | Oracle IP visible | Regular browsing, development |
| NordVPN (nordvpn) | Moderate | Good | NordVPN IP visible | Privacy-sensitive operations |
| Tor (tor) | High | Variable | Tor exit IP visible | High-anonymity requirements |

### Technical Implementation

**Direct Exit**: Host-level Tailscale service, direct Oracle Cloud connection,
systemd managed.

**NordVPN Exit**: Docker container with NordVPN + Tailscale. Routing:
Tailscale → NordVPN container → Internet. Dedicated `vpn-network` (172.28.0.0/16).
Docker Compose managed.

**Tor Exit**: Docker container with Tor + Tailscale. Routing: Tailscale → Tor
SOCKS proxy → Tor network → Internet. Dedicated `tor-network` (172.29.0.0/16).
Tailscale configured with `ALL_PROXY=socks5://tor-exit:9050`. Docker Compose
with profile support.

### Network Isolation

Each exit node has a dedicated Docker network to prevent traffic leakage between
exit paths.

## Related Concepts

- [NetBird Zero-Trust Platform](netbird-zero-trust-platform.md) — The VPN
  platform that exit nodes route through
- [Infrastructure Variable Consolidation](infrastructure-variable-consolidation.md)
  — Network subnets defined as consolidated variables

## Citations

[1] `shared/active/08-docs/adr/adr-20260625001-multi-exit-node-architecture.md` — infrahub
