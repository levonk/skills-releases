---
type: Synthesis
title: Infrastructure Networking Practices Overview
description: Synthesis of infrastructure networking practices — NetBird zero-trust platform, multi-exit node architecture (Direct/NordVPN/Tor), infrastructure variable consolidation, and backup connectivity patterns.
tags: [infrastructure, networking, vpn, zero-trust, netbird, tailscale, overview, synthesis]
timestamp: 2026-07-17T00:00:00Z
---

# Infrastructure Networking Practices Overview

This bundle documents practices for infrastructure networking in a multi-platform
homelab/cloud environment. Each concept was extracted from real infrahub ADRs —
the decisions that ensure secure remote access, flexible exit routing, and
consistent infrastructure topology management.

## The Networking Stack

```
zero-trust-platform → exit-nodes → backup-connectivity → variable-consolidation
```

| Phase | Practice | Prevents |
|-------|----------|----------|
| Platform | [NetBird Zero-Trust Platform](netbird-zero-trust-platform.md) | Incomplete VPN solutions, poor cross-platform support, no identity-based access |
| Exit | [Multi-Exit Node Architecture](multi-exit-node-architecture.md) | Single exit point, no privacy options, no high-anonymity path |
| Backup | [Backup Connectivity Pattern](backup-connectivity-pattern.md) | Complete lockout when primary VPN fails |
| Config | [Infrastructure Variable Consolidation](infrastructure-variable-consolidation.md) | Port collisions, IP conflicts, domain fragmentation, inconsistent naming |

## Scope

This bundle covers **infrastructure networking** — VPN platforms, exit node
architecture, connectivity patterns, and infrastructure topology management. It
does **not** cover:

- Container runtime hardening — see
  [container-best-practices](../container-best-practices/overview.md).
- Dev environment setup — see
  [dev-environment-practices](../dev-environment-practices/overview.md).
- Security audit practices — see
  [devsecops-codeguard](../devsecops-codeguard/overview.md).

## Sources

- `shared/active/08-docs/adr/adr-001-netbird-cloud-controlplane.md` — infrahub (255 lines)
- `shared/active/08-docs/adr/adr-20260625001-multi-exit-node-architecture.md` — infrahub (303 lines)
- `shared/active/08-docs/adr/adr-20260625001-infrastructure-consolidation.md` — infrahub (122 lines)

## Related Knowledge Bundles

- [container-best-practices](../container-best-practices/overview.md) — Containers
  run on the network infrastructure
- [devsecops-codeguard](../devsecops-codeguard/overview.md) — Security practices
  for networked services
- [secrets-egress-security](../secrets-egress-security/overview.md) — Secret
  management across network infrastructure
- [cloud-provider-essentials](../cloud-provider-essentials/overview.md) — Cloud
  provider infrastructure best practices (AWS, Azure, GCP, OCI) including VPC,
  VNet, and VCN networking configurations that complement these networking
  patterns.

## Citations

[1] `shared/active/08-docs/adr/adr-001-netbird-cloud-controlplane.md` — infrahub
[2] `shared/active/08-docs/adr/adr-20260625001-multi-exit-node-architecture.md` — infrahub
[3] `shared/active/08-docs/adr/adr-20260625001-infrastructure-consolidation.md` — infrahub
