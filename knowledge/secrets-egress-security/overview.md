---
type: Synthesis
title: Secrets Egress Security Overview
description: Synthesis of secret management and egress security practices — hybrid vault storage, shared path cleanliness, Ansible vault distribution, iron-proxy egress firewall, and vault troubleshooting.
tags: [secrets, vault, ansible, egress, security, iron-proxy, overview, synthesis]
timestamp: 2026-07-17T00:00:00Z
---

# Secrets Egress Security Overview

This bundle documents practices for secret management and egress security in
infrastructure projects. Each concept was extracted from real infrahub ADRs and
boilerplate practices — the decisions that ensure secrets are stored,
distributed, and protected from leakage.

## The Security Stack

```
hybrid-vault → shared-path-clean → ansible-distribution → egress-firewall → troubleshooting
```

| Phase | Practice | Prevents |
|-------|----------|----------|
| Storage | [Hybrid Vault Storage](hybrid-vault-storage.md) | Secret duplication, inconsistent rotation, scattered credentials |
| Cleanliness | [Shared Path Cleanliness](shared-path-cleanliness.md) | Cross-client secret exposure, broken reusability |
| Distribution | [Ansible Vault Distribution](ansible-vault-distribution.md) | Hardcoded secrets, insecure distribution |
| Egress | [Iron-Proxy Egress Firewall](iron-proxy-egress-firewall.md) | Unauthorized outbound traffic, supply chain attacks |
| Recovery | [Vault Troubleshooting](vault-troubleshooting.md) | Vault corruption, lost passwords, broken decryption |

## Scope

This bundle covers **secret management and egress security** — vault storage,
path cleanliness, distribution patterns, CI egress firewalls, and vault
recovery. It does **not** cover:

- Application-level token encryption — see
  [api-auth-payment-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/api-auth-payment-practices/overview.md).
- Network VPN security — see
  [infrastructure-networking-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/infrastructure-networking-practices/overview.md).
- Code-level security audits — see
  [devsecops-codeguard](https://github.com/levonk/skills-releases/blob/main/knowledge/devsecops-codeguard/overview.md).

## Sources

- `shared/active/08-docs/adr/adr-20260624001-hybrid-sensitive-information-storage.md` — infrahub (402 lines)
- Boilerplate AGENTS.md — iron-proxy egress firewall documentation
- Infrahub AGENTS.md — vault troubleshooting and Docker-based vault editing

## Related Knowledge Bundles

- [api-auth-payment-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/api-auth-payment-practices/overview.md) —
  Application-level token security
- [infrastructure-networking-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/infrastructure-networking-practices/overview.md)
  — Network-level security
- [devsecops-codeguard](https://github.com/levonk/skills-releases/blob/main/knowledge/devsecops-codeguard/overview.md) — Code-level
  security practices

## Citations

[1] `shared/active/08-docs/adr/adr-20260624001-hybrid-sensitive-information-storage.md` — infrahub
[2] Boilerplate AGENTS.md — iron-proxy egress firewall section
[3] Infrahub AGENTS.md — vault troubleshooting section
