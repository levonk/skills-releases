# Directory Update Log

## 2026-08-23

* **Update**: Updated
  [volume-ownership-init.md](volume-ownership-init.md) to reflect the
  implemented `localnet-volume-init` utility container and reusable Ansible
  role. The "Future Enhancement: Parameterized Utility Container" section
  was rewritten as "Implemented: Parameterized Utility Container + Reusable
  Ansible Role" — documenting the actual image (alpine:3.20 + findutils +
  tar, ENTRYPOINT `init-volume`, standalone `verify-volume` entrypoint for
  Phase 2), the exit code contract (0=ok, 1=param, 2=chown, 3=persistence,
  4=in-container), the `DATA_DIR` env var for custom mount paths, and the
  reusable Ansible role (`include_role: name: localnet-volume-init` with a
  `volume_init_volumes` list of `{name, mount, uid, gid, mode}` specs and
  intelligent defaults: `/data`, `1000`, `1000`, `755`). Added a
  "Preferred form" callout to the "Ansible task pair (standard form)"
  section directing agents to use `include_role` when the utility container
  is available, keeping the inline `alpine sh -c` form as the mandated
  baseline. Added a "Reusable role (preferred when available)" subsection
  to the Implementation Checklist. Added a "When to use the utility
  container vs the inline alpine pattern" decision table. Updated
  frontmatter `description` and [index.md](index.md) entry to mention the
  implemented container and role. The `search-hister` role in the `infrahub`
  repo was refactored from hand-stitched inline tasks to `include_role` as
  the validation case.

## 2026-08-23 (earlier)

* **Ingest**: Created a new concept page
  [volume-ownership-init.md](volume-ownership-init.md) covering the
  three-phase Docker volume ownership initialization pattern for non-root
  containers, sourced from
  [ADR-20260822001](https://github.com/levonk/infrahub/blob/main/shared/active/08-docs/adr/adr-20260822001-volume-ownership-init-pattern.md)
  (Docker Volume Ownership Init Pattern for Non-Root Containers, accepted
  2026-08-22). The page documents practices not previously in the bundle:
  1. **Three-phase volume init** — chown + in-container verify (Phase 1),
     then fresh-container verify (Phase 2), then service container starts
     (Phase 3). The two verification layers catch different failure classes:
     in-container verify catches overlay/filesystem issues where `chown`
     exits 0 but the VFS layer does not reflect the change; fresh-container
     verify catches Docker Desktop WSL2 volume driver persistence failures
     where the chown took effect inside the Phase 1 container's mount
     namespace but did not persist to the volume's backing store.
  2. **Diagnostic matrix** — a four-row table mapping (Phase 1 chown rc,
     Phase 1 in-container verify, Phase 2 fresh-container verify) to
     diagnosis and action. Without the in-container verify, the persistence
     failure is indistinguishable from "chown ran but we don't know if it
     worked" — the blind spot that caused the Hister crash loop documented
     in the ADR.
  3. **Why alpine for the throwaway init container** — size (~7 MB, cached
     on every host), speed (<1 s start), universality (multi-arch per the
     fleet mandate), sufficiency (`sh`/`chown`/`chmod`/`stat`/`test`), and
     no registry dependency (avoids chicken-and-egg with a local registry
     that might itself have a volume ownership problem).
  4. **Standard Ansible task pair** — the canonical two-task form with
     `delegate_to: localhost` + `DOCKER_HOST` via SSH for Windows Docker
     Desktop hosts (where `community.docker` modules cannot run because they
     import `grp`, Unix-only), `changed_when: false` for idempotency, and
     `failed_when: <register>.rc != 0` on the Phase 2 verify.
  5. **Signal to upstream image authors** — if Phase 1 in-container verify
     passes but Phase 2 fresh-container verify fails and the service
     crash-loops, the image should be fixed upstream to start as root,
     `chown` the data directory in its entrypoint, then drop to the non-root
     user via `gosu`/`su-exec` (the Postgres/MySQL/Redis pattern), rather
     than relying on infrastructure to pre-fix the volume.
  6. **Recovery procedures** — separate recovery paths for Phase 1 failure
     (overlay/fs issue: check read-only mount, storage driver, NFS) vs
     Phase 2 failure (persistence: stop crash-looping containers, verbose
     chown, recreate volume, tar-based backup/restore for non-disposable
     data).
  7. **What does NOT work** — five approaches that fail: `ansible.builtin
     file` with owner/group (no direct filesystem access on Docker Desktop
     for Windows), `docker volume create --opt` (no ownership option),
     running as root (violates non-root policy), `userns-remap` (not
     supported on Docker Desktop for Windows; on Linux maps UID 1000 to
     100000+ so the volume is still not owned by the mapped UID), and
     entrypoint self-fix scripts (only work if the image starts as root).
  8. **Future enhancement: parameterized utility container** — a proposed
     `localnet-volume-init` image built from a local base that adds
     parameter validation, explicit exit codes (1=param, 2=chown, 3=
     persistence, 4=in-container), logging, and a standalone verify
     entrypoint. Documented as a future enhancement, not the baseline —
     the `alpine` + inline script pattern is the mandated baseline until a
     third role needs volume init.
  9. **Alternative pattern: entrypoint wrapper image** — a thin wrapper
     image that `FROM`s the upstream image, installs `su-exec` (Alpine) or
     `gosu` (Debian), overrides only `ENTRYPOINT` (inheriting `CMD` from
     upstream so auto-start and `docker restart` work), and injects an
     entrypoint script that chowns the data directory, verifies the chown
     in-container, then drops to the non-root user via `su-exec` and execs
     the original entrypoint. This makes the container self-healing — it
     fixes its own volume on every start, not just when Ansible runs. The
     three-phase init remains the mandatory baseline; the wrapper is an
     addition for services that may be restarted without Ansible, have
     multiple volumes, or are deployed to hosts where Ansible doesn't run
     frequently. Includes: a decision table (wrapper vs init), the
     ENTRYPOINT-vs-CMD-vs-runtime-override analysis (only ENTRYPOINT
     override preserves auto-start), the wrapper script with in-container
     verify before privilege drop, security analysis of the transient root
     context (scoped to chown only, ~0.1s duration, still uses
     no-new-privileges and cap-drop ALL), and when NOT to use the wrapper
     (upstream already does chown-then-drop, no volumes, runs as root by
     design, non-Alpine without gosu).
  Added 3 sources: the ADR itself, Docker Storage Volumes docs (default
  root ownership, driver semantics), and Docker Engine userns-remap docs
  (why userns-remap does not solve volume ownership). Cross-linked to
  [container-runtime-hardening](container-runtime-hardening.md) (non-root
  execution is WHY this is needed),
  [container-runtime-essentials](container-runtime-essentials.md) (sidecar
  shared volumes need ownership
  init; multi-arch mandate ensures alpine is available),
  [compose-service-dependency-ordering](compose-service-dependency-ordering.md)
  (init-container pattern with `condition: service_completed_successfully`),
  [nx-monorepo-docker-patterns](nx-monorepo-docker-patterns.md) (shared
  pnpm-store and nx-cache volumes need ownership init when sidecars run as
  non-root cuser), and [base-image-selection](base-image-selection.md)
  (why alpine is right for infra throwaway containers but wrong for app
  Dockerfiles). Updated [overview.md](overview.md.tmpl) lifecycle table,
  scope, description, and tags, and [index.md](index.md) with the new
  entry.

## 2026-08-02

* **Ingest**: Created a new concept page
  [image-versioning.md](image-versioning.md) covering deterministic image
  versioning from Git state, sourced from the reconstructed "Canonical Docker
  Image Versioning Spec" (Copilot share 58jfrWSQ83wu6fwm25Ddf). The page
  documents practices not previously in the bundle:
  1. **Version string format** — `<epoch>.<semver>-<commit>-<dirty>` as the
     single source of truth, with epoch manually incremented only when the
     versioning scheme changes, semver derived from the nearest Git tag
     (`v1.4.2` → `1.4.2`, ahead-of-tag → `1.4.2+3`), short SHA, and `-dirty`
     flag for uncommitted changes.
  2. **Canonical extraction script** — `scripts/version.sh` as the sole
     generator, deterministic across CI environments, no reliance on CI
     environment variables as the primary source.
  3. **Version file generation over Git keyword expansion** — generate a real
     `.version` file instead of using smudge/clean filters; the file is
     portable across Docker / Podman / Buildx / Nix / GitOps and safe for
     shallow clones and ephemeral CI workspaces.
  4. **Dockerfile integration** — `ARG VERSION` / `ARG GIT_COMMIT` /
     `ARG BUILD_DATE` plus OCI labels (`org.opencontainers.image.version`,
     `.revision`, `.created`, `.source`) and `COPY .version /app/.version`
     for runtime introspection.
  5. **Multi-arch buildx rule** — compute the version **once** before
     invoking `docker buildx build --platform` so every platform gets the
     same string (per-platform computation produces divergent tags).
  6. **Tagging rules** — always push `<full-version>`; push `<major.minor>`
     only on clean tags; push `latest` only on main.
  7. **Post-deployment version override** — three deterministic mechanisms:
     Kubernetes ConfigMap overlay (preferred), Docker/Podman bind mount
     override, and runtime environment variable override via entrypoint
     logic. All layer on top of the build-time version without rebuilding.
  8. **Avoid: Git smudge/clean filters** — folded inline as an "Avoid"
     callout per the normative stance rule. Documents why smudge/clean
     breaks reproducibility, multi-arch builds, Docker build contexts, CI
     shallow clones, GitOps workflows, and cross-platform consistency. Notes
     that Git has no built-in keyword identifiers (the `ident` attribute
     expands `$Id$` to the blob SHA-1, not commit/tag/semver).
  Added 4 sources: the Copilot share, gitattributes smudge/clean docs, OCI
  image-spec annotations, and docker buildx multi-platform docs. Cross-linked
  to [pin-image-digests](pin-image-digests.md) (input pinning vs output
  pinning), [registry-cache-strategy](registry-cache-strategy.md),
  [container-runtime-hardening](container-runtime-hardening.md),
  [buildkit-secrets](buildkit-secrets.md), and
  [container-runtime-essentials](container-runtime-essentials.md). Updated
  [overview.md](overview.md.tmpl) lifecycle table, scope, description, and
  tags, and [index.md](index.md) with the new entry.

## 2026-07-28

* **Ingest**: Created a new concept page
  [nx-monorepo-docker-patterns.md](nx-monorepo-docker-patterns.md) covering
  Dockerizing Nx monorepo frontends, sourced from the Medium article
  "Dockerizing NX Frontend Monorepos Without Losing Your Sanity" (2025-09)
  plus pnpm-vs-bun benchmark research and the existing pnpm-sidecar pattern
  from infrahub. The page documents four patterns not previously in the
  bundle:
  1. **Two-layer base image strategy** (`node-base` → `deps-base` → per-app
     Dockerfiles) so workspace dependencies install once and are shared
     across all app builds.
  2. **Nx-affected Docker builds** — `nx affected -t docker-build` builds
     only images for apps whose source changed, so CI time scales with
     changed apps, not total apps.
  3. **Dual cache union** — Nx computation cache mounted as a BuildKit
     cache mount inside the builder stage, paired with `type=gha` BuildKit
     cache in CI, so both caching systems complement each other.
  4. **pnpm-vs-bun-in-containers tradeoff** — when to use pnpm in the
     container (with the pnpm-sidecar shared store) vs bun, with a decision
     table covering `catalog:` support, store sharing, layer cache
     friendliness, and runtime size. Standardized on the canonical volume
     names from infrahub: `localnet-artifact-pnpm-store-volume` (mounted at
     `/home/cuser/.local/share/pnpm`) and `localnet-artifact-nx-cache-volume`
     (mounted at `/var/cache/nx-cache`). Documented the pnpm-sidecar archive
     pattern (build-stage zstd archive → runtime extraction to shared volume),
     the **module validation contract** (pnpm-sidecar healthcheck runs
     `pnpm store status` to validate store integrity; app containers declare
     `depends_on: pnpm-sidecar: condition: service_healthy` so they only
     start after the store is populated and validated), the nx-sidecar
     pattern (installs nx from the shared pnpm store, initializes the
     FHS-compliant nx cache directory structure), and the app container
     volume mount pattern with runtime hardening (no-new-privileges, cap_drop
     ALL, read_only, tmpfs).
  5. **Build-time sidecar vs injecting node_modules** — clarified that these
     compose, not compete: the pnpm-sidecar accelerates the builder stage's
     `pnpm install` (reads from shared store, offline), while `node_modules`
     are baked into the production image via multi-stage `COPY --from=builder`
     so the image is self-contained. Production containers do NOT mount the
     sidecar volume at runtime; dev containers do (for hot reload).
  6. **Runtime performance comparison (bun vs Node.js)** — added a runtime
     performance table separating build-time PM from runtime. Bun wins 4x on
     synthetic HTTP but only ~3% on real apps with database I/O; Bun uses
     25-40% less memory and has a 5x smaller image; Node.js wins on Lambda
     cold start (managed runtime), npm ecosystem compatibility, and Next.js
     native module support (`sharp`). Added a decision matrix mapping
     scenarios to build-time PM + runtime choices.
  7. **@nx/docker inference plugin** — documented the official `@nx/docker`
     plugin (`docker:build`, `docker:run`, `nx-release-publish` auto-inferred
     from Dockerfiles), with `nx.json` configuration supporting `--platform`
     for multi-arch, custom args, env vars, and pattern interpolation.
  8. **Custom Nx executor with hash-based tagging** — documented the
     `child_process.exec` pattern for hash-based base image tagging (hash of
     `base.Dockerfile` + `pnpm-lock.yaml` = base tag; git commit hash = app
     tag), with domain-tag-filtered affected builds (`--tag=domain:billing`).
  9. **Dev-time docker-compose pattern** — documented multi-app development
     with shared source + shared pnpm-sidecar/nx-cache volumes, `extends`
     base service pattern, and Webpack polling for cross-OS hot reload
     (`DEV_PLATFORM=DOCKER` → `watchOptions.poll`).
  Added 8 new sources: @nx/docker docs, Nx Release Docker guide, codefeetime
  dev-time docker-compose article, ngserve.io custom executor article, and
  three bun-vs-node runtime performance benchmarks (Strapi, Console.today,
  Woyable).
  Six choices from the source article that violate our standards (`npx` →
  `pnpm exec`, `node:18-alpine` → `node:22-slim`, missing USER/HEALTHCHECK,
  floating tags → digests, manual `actions/cache@v3` → `type=gha`, no secret
  handling → BuildKit secret mounts) are folded inline as "Avoid" callouts in
  the relevant practice sections, not as a standalone corrections table — the
  article remains in `sources:` as provenance. Cross-linked
  to [base-image-selection](base-image-selection.md),
  [layer-cache-order](layer-cache-order.md),
  [multi-stage-builds](multi-stage-builds.md),
  [registry-cache-strategy](registry-cache-strategy.md),
  [buildkit-secrets](buildkit-secrets.md),
  [nodejs-in-containers](nodejs-in-containers.md),
  [pin-image-digests](pin-image-digests.md),
  [container-runtime-hardening](container-runtime-hardening.md), and the
  [pnpm-nx-monorepo](https://github.com/levonk/skills-releases/blob/main/knowledge/typescript-monorepo-best-practices/pnpm-nx-monorepo.md)
  concept in the TypeScript bundle. Updated [overview.md](overview.md.tmpl)
  lifecycle table and scope, and [index.md](index.md) with the new entry.

## 2026-07-29

* **Refactor**: Refactored [nx-monorepo-docker-patterns.md](nx-monorepo-docker-patterns.md)
  to a normative stance. Deleted the standalone "Corrections to Common Article
  Advice" section (former section 5) and folded its six correction rows inline
  as "Avoid" callouts in the relevant practice sections (base image, builder
  stage, runtime stage, CI cache). Rewrote the frontmatter `description` to
  lead with the practice, not the article critique. The source article remains
  in `sources:` as provenance. Updated [index.md](index.md) entry to match.
  Renumbered sections 6→5, 7→6, 8→7. Motivated by the ai-upsert skill's new
  Normative Stance rule: concept pages state what to do; per-source critique
  folds inline, not as a standalone section.

## 2026-07-26
* **Migration**: Migrated `## Citations` body sections to `sources` frontmatter with stable `id` attributes per OKF v0.2 §13.1.
* **Migration**: Migrated bundle from OKF v0.1 to OKF v0.2 — bumped `okf_version` in index.md. No `# Citations` sections or `timestamp` fields to migrate.

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
