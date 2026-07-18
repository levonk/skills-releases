# Directory Update Log

## 2026-07-17

* **Initialization**: Created the `infrastructure-networking-practices` knowledge bundle to consolidate infrastructure networking practices from three ADRs in infrahub.
* **Creation**: Authored 4 concept pages covering the networking stack.
  - [netbird-zero-trust-platform.md](netbird-zero-trust-platform.md) — NetBird over Headscale/Netmaker, cloud-hosted control plane
  - [multi-exit-node-architecture.md](multi-exit-node-architecture.md) — Direct/NordVPN/Tor exit nodes with Docker network isolation
  - [infrastructure-variable-consolidation.md](infrastructure-variable-consolidation.md) — Centralized topology variables with infra_ naming
  - [backup-connectivity-pattern.md](backup-connectivity-pattern.md) — SSH/mosh/Tailscale as backup to primary VPN
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
* **Note**: Concepts extracted from ADR-20250524001 (NetBird cloud control plane, 255 lines), ADR-20260625001 (multi-exit node architecture, 303 lines), and ADR-20260625001 (infrastructure consolidation, 122 lines) in infrahub.
