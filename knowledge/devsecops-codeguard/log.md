# Directory Update Log

## 2026-07-17

* **Restructure**: Moved container-specific concepts to the
  [container-best-practices](../container-best-practices/index.md) bundle,
  which is the canonical home for container authoring, runtime, and Dockerfile
  practices. Moved files:
  - [container-hardening.md](../container-best-practices/container-runtime-hardening.md) → merged into `container-runtime-hardening.md` (unique sections: docker.sock prohibition, TCP daemon, image scanning, implementation checklist)
  - [nodejs-in-containers.md](../container-best-practices/nodejs-in-containers.md) → moved as-is
  - [dockerfile-best-practices.md](../container-best-practices/dockerfile-best-practices.md) → moved as-is
  Updated [overview.md](overview.md) pipeline, scope, and citations to reflect
  the narrower code-level security + audit focus. Updated [index.md](index.md)
  to remove the three container concept entries.

## 2026-07-17

* **Update**: Added missing concept pages referenced by [index.md](index.md):
  - [ssh-hardening.md](ssh-hardening.md) — PermitRootLogin, ed25519-only keys, fail2ban
  - [security-audit-playbook.md](security-audit-playbook.md) — final-audit.yml validation pattern
  - [dockerfile-best-practices.md](dockerfile-best-practices.md) — apt/apk cleanup, user creation, multi-stage builds, HEALTHCHECK (since moved to container-best-practices)

## 2026-07-17

* **Initialization**: Created the `devsecops-codeguard` knowledge bundle to consolidate codeguard rules from job-aide and security audit practices from infrahub into a generalizable OKF v0.1 knowledge base.
* **Creation**: Authored 7 concept pages covering the DevSecOps codeguard spectrum — from C memory safety and crypto algorithm governance through SSH hardening and infrastructure security audits. (Originally 10 pages; 3 container-specific pages were later moved to container-best-practices.)
  - [safe-c-functions.md](safe-c-functions.md) — banned memory/string functions, bounded replacements, compiler flags
  - [hardcoded-credentials-detection.md](hardcoded-credentials-detection.md) — AWS/Stripe/Google/GitHub/JWT patterns, private keys, connection strings
  - [crypto-algorithm-governance.md](crypto-algorithm-governance.md) — banned algorithms, deprecated OpenSSL APIs, EVP replacements
  - [digital-certificate-validation.md](digital-certificate-validation.md) — expiration, key strength, signature algorithm, self-signed checks
  - [ssh-hardening.md](ssh-hardening.md) — PermitRootLogin, ed25519-only, PasswordAuthentication no, fail2ban
  - [security-audit-playbook.md](security-audit-playbook.md) — final-audit.yml pattern, hardcoded IP/port checks, Docker daemon hardening
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
