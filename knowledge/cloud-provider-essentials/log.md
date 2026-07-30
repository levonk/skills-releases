---
type: Log
title: Cloud Provider Essentials — Update Log
description: Chronological log of changes to the cloud-provider-essentials knowledge bundle.
tags: [cloud, aws, azure, gcp, oci, log, changelog]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-18"
  last-used: "2026-07-18"
---

# Update Log

## 2026-07-26
* **Migration**: Migrated bundle from OKF v0.1 to OKF v0.2 — bumped `okf_version` in index.md. No `# Citations` sections or `timestamp` fields to migrate.

## 2026-07-18

- **Initial migration**: Created the `cloud-provider-essentials` knowledge
  bundle by migrating content from 6 cloud-provider rule files in
  `src/current/rules/software-dev/devops/`.
- Migrated `aws-essentials.md` (750 lines) → [aws-essentials.md](aws-essentials.md)
- Migrated `azure-essentials.md` (606 lines) → [azure-essentials.md](azure-essentials.md)
- Migrated `gcp-essentials.md` (605 lines) → [gcp-essentials.md](gcp-essentials.md)
- Migrated `oci-essentials.md` (550 lines) → [oci-essentials.md](oci-essentials.md)
- Migrated `aws-pulumi.md` (905 lines) → [aws-pulumi-patterns.md](aws-pulumi-patterns.md)
- Migrated `aws-terraform.md` (967 lines) → [aws-terraform-patterns.md](aws-terraform-patterns.md)
- Created [index.md](index.md) with OKF v0.1 frontmatter and concept listing.
- Created [overview.md](overview.md) with synthesis of the cloud provider
  landscape, cross-provider patterns, and concept relationships.
- Added cross-references in `container-best-practices/overview.md` and
  `infrastructure-networking-practices/overview.md` linking back to this
  bundle.
