---
type: Synthesis
title: Cloud Provider Essentials Overview
description: Synthesis of cloud provider best practices across AWS, Azure, GCP, and OCI — covering the shared landscape of storage, database, networking, compute, and security services, plus IaC implementation patterns with Pulumi and Terraform.
tags: [cloud, aws, azure, gcp, oci, infrastructure, best-practices, pulumi, terraform, iac, overview, synthesis]
timestamp: 2026-07-18T00:00:00Z
---

# Cloud Provider Essentials Overview

This bundle documents best practices for the four major cloud providers —
AWS, Azure, GCP, and OCI — along with Infrastructure as Code (IaC)
implementation patterns for AWS using both Pulumi and Terraform. Each concept
page provides detailed, environment-tiered (prototyping / testing / production)
guidance for storage, database, networking, compute, and security services.

## The Cloud Provider Landscape

```
aws-essentials ──┬── aws-pulumi-patterns
                 └── aws-terraform-patterns

azure-essentials ── gcp-essentials ── oci-essentials
```

The four provider-specific concept pages cover the same service categories
(storage, database, networking, compute, security) but with provider-native
terminology and tooling. The two IaC pattern pages provide concrete
implementations for the AWS best practices described in `aws-essentials.md`.

## Cross-Provider Patterns

Despite different terminology and tooling, all four providers share a common
set of architectural patterns:

| Pattern | AWS | Azure | GCP | OCI |
|---------|-----|-------|-----|-----|
| Object storage | S3 | Blob Storage | Cloud Storage | Object Storage |
| Managed SQL | RDS / Aurora | Azure SQL | Cloud SQL | Autonomous Database |
| NoSQL | DynamoDB | Cosmos DB | Firestore | — |
| Virtual network | VPC | VNet | VPC | VCN |
| Virtual machines | EC2 | VMs | Compute Engine | Compute Instances |
| Private service access | VPC Endpoints | Service Endpoints | Private Google Access | Service Gateway |
| Load balancing | ELB / ALB | Load Balancer | Cloud Load Balancing | Network Load Balancer |
| DDoS protection | Shield | Azure DDoS | Cloud Armor | OCI DDoS Protection |
| Key management | KMS | Key Vault | Cloud KMS | OCI KMS |
| IAM | IAM | Azure AD / RBAC | Cloud IAM | OCI IAM |

### Shared Best Practices Across Providers

1. **Cost optimization via tiering**: All providers offer storage tiers (hot /
   cool / archive) with significant cost savings at the expense of retrieval
   latency. Lifecycle policies automate transitions.

2. **Private service access**: Every provider offers a mechanism to access
   managed services without traversing the public internet — VPC Endpoints
   (AWS), Service Endpoints (Azure), Private Google Access (GCP), and Service
   Gateways (OCI). These avoid NAT Gateway data transfer charges.

3. **Environment-tiered configurations**: Each concept page provides
   prototyping (minimize cost), testing (full observability), and production
   (reliability & compliance) configurations with estimated monthly costs.

4. **Security hardening**: All providers support least-privilege IAM,
   customer-managed encryption keys, audit logging, and MFA enforcement.
   Production environments require all of these.

5. **Spot/preemptible instances**: All providers offer significant discounts
   (70%+) for interruptible workloads, suitable for batch processing and
   fault-tolerant testing.

6. **Always Free tiers**: AWS, Azure, GCP, and OCI all offer free tiers for
   prototyping — small VMs, limited storage, and minimal database capacity.

### AWS-Specific IaC Patterns

The AWS best practices in `aws-essentials.md` are accompanied by two parallel
IaC implementations:

- **[AWS Pulumi Patterns](aws-pulumi-patterns.md)** — TypeScript-based IaC,
  recommended for TypeScript projects. Covers VPC endpoints, cost anomaly
  detection, Organizations setup, resource tagging, tag enforcement with AWS
  Config, and more.

- **[AWS Terraform Patterns](aws-terraform-patterns.md)** — HCL-based IaC,
  for teams using the Terraform ecosystem. Provides identical implementations
  of the same patterns, allowing teams to choose their preferred IaC tool.

Both files implement the same patterns described in `aws-essentials.md`,
including:

- VPC Gateway Endpoints for S3 (avoiding NAT Gateway charges)
- Cost Anomaly Detection setup
- AWS Organizations with Service Control Policies
- Resource tagging with common tag schemas
- Tag enforcement with AWS Config rules

## How the Concepts Fit Together

```
                    ┌─────────────────────────────────────┐
                    │       Cloud Provider Landscape       │
                    └───────────┬─────────────────────────┘
                                │
           ┌────────────────────┼────────────────────┐
           │                    │                    │
     ┌─────▼─────┐      ┌──────▼──────┐      ┌──────▼──────┐
     │    AWS     │      │   Azure     │      │    GCP      │
     │ Essentials │      │ Essentials  │      │ Essentials  │
     └─────┬──────┘      └─────────────┘      └─────────────┘
           │
     ┌─────┴─────┐
     │           │
┌────▼────┐ ┌───▼────────┐
│ Pulumi  │ │  Terraform  │
│ Patterns│ │  Patterns   │
└─────────┘ └────────────┘

           ┌─────────────────────┐
           │       OCI           │
           │    Essentials       │
           └─────────────────────┘
```

The provider-specific pages (`aws-essentials.md`, `azure-essentials.md`,
`gcp-essentials.md`, `oci-essentials.md`) each provide self-contained guidance
for their respective platforms. The IaC pattern pages (`aws-pulumi-patterns.md`,
`aws-terraform-patterns.md`) provide concrete code implementations for the AWS
best practices, referencing back to `aws-essentials.md` for the architectural
context.

## Scope

This bundle covers **cloud provider infrastructure best practices** —
storage, database, networking, compute, and security service configurations
across AWS, Azure, GCP, and OCI, plus IaC implementation patterns for AWS
using Pulumi and Terraform. It does **not** cover:

- Container deployment patterns — see
  [container-best-practices](../container-best-practices/overview.md).
- Networking patterns for VPN/zero-trust infrastructure — see
  [infrastructure-networking-practices](../infrastructure-networking-practices/overview.md).
- Application-level security — see
  [devsecops-codeguard](../devsecops-codeguard/overview.md).

## Related Knowledge Bundles

- [container-best-practices](../container-best-practices/overview.md) — Container
  deployment patterns for cloud (base image selection, multi-stage builds,
  runtime hardening, registry cache strategy).
- [infrastructure-networking-practices](../infrastructure-networking-practices/overview.md)
  — Networking patterns (zero-trust platforms, multi-exit node architecture,
  backup connectivity, infrastructure variable consolidation).
