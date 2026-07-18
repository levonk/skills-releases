---
type: Practice
title: Infrastructure Variable Consolidation
description: Centralized infrastructure topology variables with infra_ naming convention. Shared schemas with client-specific overrides for networks, ports, domains, and storage.
tags: [infrastructure, ansible, variables, consolidation, naming-convention, topology]
timestamp: 2026-07-17T00:00:00Z
---

# Infrastructure Variable Consolidation

## Failure Mode

Infrastructure topology (IP addresses, ports, domain names, storage paths)
scattered across multiple variable files leads to port collisions, IP address
conflicts, domain name fragmentation, and inconsistent naming conventions.

## Practice

Implement a hybrid infrastructure consolidation strategy with shared schemas and
client-specific overrides.

### Shared Infrastructure Schemas

Location: `shared/active/02-config/ansible/infrastructure/`

- `networks.yml` — Network topology (subnets, gateways, network names, IP allocations)
- `ports.yml` — Port allocations (host/container ports by service)
- `domains.yml` — Domain names, DNS records, and hostnames
- `storage.yml` — Storage paths, volumes, and container mounts

### Client-Specific Values

Location: `levonk/active/02-config/ansible/infrastructure/`

- Same file structure as shared schemas
- Overrides shared defaults where needed

### Variable Naming Convention

Pattern: `infra_{CATEGORY}_{SERVICE}_{CONTEXT}_{ATTRIBUTE}`

Categories:
- `network` — IP addresses, subnets, gateways, network names
- `port` — Host and container port assignments
- `domain` — Domain names, DNS records, hostnames
- `storage` — Volume paths, mount points, storage quotas

Examples:
```yaml
infra_network_vpn_nordvpn_subnet: "172.28.0.0/16"
infra_port_forge_host_http: "8083"
infra_domain_ai_dashboard_web: "ai-dashboard.levonk.com"
infra_storage_vault_path: "/opt/localnet/config/vault"
```

### Usage Pattern

1. Define schema in shared directory with defaults
2. Override client-specific values in client directory
3. Reference consolidated variables in existing configuration files
4. Single source of truth for infrastructure topology

## Related Concepts

- [Multi-Exit Node Architecture](multi-exit-node-architecture.md) — Network
  subnets defined as consolidated variables
- [NetBird Zero-Trust Platform](netbird-zero-trust-platform.md) — Network
  topology managed through consolidated variables

## Citations

[1] `shared/active/08-docs/adr/adr-20260625001-infrastructure-consolidation.md` — infrahub
