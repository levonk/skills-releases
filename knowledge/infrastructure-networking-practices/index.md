---
okf_version: "0.1"
---

# Infrastructure Networking Practices

A compounding knowledge base documenting practices for infrastructure networking
— zero-trust VPN platforms, multi-exit node architectures, infrastructure
variable consolidation, and network topology management. Each concept captures
specific architectural decisions sourced from real infrahub ADRs.

## Concepts

* [Overview](overview.md) - Synthesis of the full infrastructure networking practice set
* [netbird-zero-trust-platform](netbird-zero-trust-platform.md) - NetBird as primary zero-trust networking platform over Headscale and Netmaker
* [multi-exit-node-architecture](multi-exit-node-architecture.md) - Three exit nodes: Direct, NordVPN, Tor for different privacy levels
* [infrastructure-variable-consolidation](infrastructure-variable-consolidation.md) - Centralized infrastructure topology variables with infra_ naming convention
* [backup-connectivity-pattern](backup-connectivity-pattern.md) - SSH, mosh, and Tailscale as backup connectivity alongside primary VPN
