---
type: Practice
title: Backup Connectivity Pattern
description: SSH server, mosh, and Tailscale as backup connectivity alongside primary NetBird VPN. Prevents complete lockout when primary VPN fails.
tags: [ssh, mosh, tailscale, backup, connectivity, netbird, failover]
timestamp: 2026-07-17T00:00:00Z
---

# Backup Connectivity Pattern

## Failure Mode

When the primary VPN platform (NetBird) fails or is misconfigured, complete
lockout occurs. No alternative path exists to reach the cloud host for
troubleshooting and recovery.

## Practice

Deploy **multiple connectivity layers** on the cloud host:

1. **Primary**: NetBird zero-trust VPN platform
2. **Backup**: Tailscale (separate from NetBird control plane)
3. **Fallback**: SSH server + mosh for direct access

### Configuration

- SSH server running on standard port for direct access
- mosh (mobile shell) for resilient connections with high latency
- Tailscale daemon as independent backup to NetBird
- All three available on the cloud host simultaneously

### Why Multiple Layers

- NetBird control plane could fail (Docker container crash, config error)
- Tailscale provides independent mesh connectivity
- SSH/mosh provides direct access when all VPN platforms are down
- mosh handles high-latency and intermittent connections better than SSH

## Related Concepts

- [NetBird Zero-Trust Platform](netbird-zero-trust-platform.md) — Primary
  connectivity layer
- [Multi-Exit Node Architecture](multi-exit-node-architecture.md) — Tailscale
  also used for exit node routing

## Citations

[1] `shared/active/08-docs/adr/adr-001-netbird-cloud-controlplane.md` — infrahub
