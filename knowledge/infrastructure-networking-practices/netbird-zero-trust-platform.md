---
type: Practice
title: NetBird Zero-Trust Platform
description: NetBird as primary zero-trust networking platform with cloud-hosted control plane in Docker. Chosen over Headscale and Netmaker for complete platform, cross-platform support, and active development.
tags: [netbird, zero-trust, vpn, wireguard, docker, networking, tailscale, headscale]
timestamp: 2026-07-17T00:00:00Z
---

# NetBird Zero-Trust Platform

## Failure Mode

Using a coordination-only VPN solution (Headscale) requires assembling multiple
components (relay servers, DNS resolver, policy engine). Using a Linux-focused
SD-WAN (Netmaker) leaves macOS/Windows/mobile without native clients and lacks
identity-based zero-trust features.

## Practice

Use **NetBird** as the primary zero-trust networking platform with a cloud-hosted
control plane deployed in Docker containers.

### Architecture

- NetBird gateway agent on cloud host
- Docker containers for:
  1. Management service (control plane — state, ACLs, routes, DNS, logging)
  2. Signal service (NAT traversal helper)
  3. Relay/TURN service (fallback transport)
- VM on cloud server for AI agent workloads with its own NetBird gateway agent

### Why NetBird Over Alternatives

**vs Headscale**: NetBird provides a complete platform (management, signal,
relay, DNS, identity, multi-network) rather than just a coordination layer.
Headscale lacks built-in relay servers, DNS resolver, and limits to single OIDC
provider.

**vs Netmaker**: NetBird has excellent cross-platform support (Linux, macOS,
Windows, iOS, Android) with native clients. Netmaker is Linux-focused with
user-space WireGuard on macOS/Windows and no mobile clients. NetBird has faster
release cycle (5 days vs 3 weeks) and stronger community (25.4k vs 11.6k stars).

### Requirements

- Self-hosted control plane for data sovereignty
- Cross-platform: Linux, macOS, Windows, iOS, Android
- Identity-based access control with multi-IdP support
- NAT traversal and relay fallback
- Containerizable for Docker-based infrastructure

## Related Concepts

- [Backup Connectivity Pattern](backup-connectivity-pattern.md) — Tailscale as
  backup to NetBird
- [Multi-Exit Node Architecture](multi-exit-node-architecture.md) — Exit nodes
  on top of the VPN platform

## Citations

[1] `shared/active/08-docs/adr/adr-001-netbird-cloud-controlplane.md` — infrahub
