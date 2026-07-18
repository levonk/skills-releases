# Directory Update Log

## 2026-07-18

* **Ingest**: Migrated container-essentials.md and container-build-principles.md rules into new concept page container-runtime-essentials.md.

## 2026-07-17

* **Ingest**: Migrated 2 container-specific concepts from the
  devsecops-codeguard bundle and extended 1 existing concept with merged
  content:
  - [nodejs-in-containers.md](nodejs-in-containers.md) — moved from
    devsecops-codeguard; updated cross-references to point to
    [build-context-hygiene](build-context-hygiene.md) and
    [buildkit-secrets](buildkit-secrets.md) instead of devsecops-internal
    links.
  - [dockerfile-best-practices.md](dockerfile-best-practices.md) — moved from
    devsecops-codeguard; added "Related Concepts" cross-links to
    multi-stage-builds, base-image-selection, layer-cache-order,
    container-runtime-hardening, and dockerfile-linting.
  - [container-runtime-hardening.md](container-runtime-hardening.md) —
    extended with unique sections from the former devsecops
    `container-hardening.md`: docker.sock prohibition, TCP daemon TLS
    requirement, image scanning, secret management, and a comprehensive
    implementation checklist.
  Updated [overview.md](overview.md) lifecycle table, scope, sources, and
  related-bundles sections. Updated [index.md](index.md) with the 2 new
  concept entries.

## 2026-07-17

* **Creation**: Initialized the `container-best-practices` knowledge bundle with 7 concept pages extracted from the DevOps Toolbox video "Give me 15 minutes and I'll Fix Your Dockerfiles Forever".
  - [base-image-selection.md](base-image-selection.md) — Alpine vs Slim, musl libc trap
  - [layer-cache-order.md](layer-cache-order.md) — onion model, deps before source
  - [build-context-hygiene.md](build-context-hygiene.md) — .dockerignore over COPY gymnastics
  - [multi-stage-builds.md](multi-stage-builds.md) — builder = bloat zone, scratch/distroless
  - [single-container-multi-process.md](single-container-multi-process.md) — supervisord, "vibe not law"
  - [pin-image-digests.md](pin-image-digests.md) — tags move, digests don't
  - [dockerfile-linting.md](dockerfile-linting.md) — hadolint in CI
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
* **Note**: Flagged apparent contradiction between [base-image-selection.md](base-image-selection.md) (slim for apps) and the existing `docker-standards.md` workflow (alpine for infra). Resolved as context-dependent — see the "Apparent Contradiction With Project Standards" section in base-image-selection.md.
* **Ingest**: Added 4 new concept pages from web research, expanding the bundle beyond the original video source into compose, runtime, registry, and build-time secret practices.
  - [compose-service-dependency-ordering.md](compose-service-dependency-ordering.md) — depends_on with condition: service_healthy + healthchecks; service_completed_successfully for init containers
  - [container-runtime-hardening.md](container-runtime-hardening.md) — non-root, read-only, cap-drop ALL, no-new-privileges; CIS Docker Benchmark + NIST SP 800-190 citations
  - [registry-cache-strategy.md](registry-cache-strategy.md) — BuildKit --cache-to/--cache-from with registry/gha/local/inline backends; mode=max for multi-stage; registry mirroring
  - [buildkit-secrets.md](buildkit-secrets.md) — --mount=type=secret and --mount=type=ssh; never bake credentials into layers or pass as --build-arg
* **Update**: Extended [overview.md](overview.md) lifecycle table and scope to cover runtime, registry, and build-time secret phases. Pruned the future-candidates list (all 4 candidates now ingested).
