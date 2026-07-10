# Branch B — Dockerfile + buildx

> Use when no suitable upstream image exists, or you need customizations, and
> the service does NOT need a Nix store at runtime.

## When to Use

- No upstream multi-arch image found (Branch A ruled out).
- The service is a binary (Rust, Go, C/C++, Python, Node.js) that runs in a
  slim runtime image without `nix-store` or `nix` CLI.
- You need customizations (extra config, healthcheck, entrypoint) on top of a
  base image.

## Multi-Stage Dockerfile Pattern

Stage 1 compiles the binary natively or cross-compiles. Stage 2 copies the
binary into a slim runtime image.

```dockerfile
# --- Build stage: run on the BUILD platform (native), not emulated ---
FROM --platform=$BUILDPLATFORM rust:1-bookworm AS builder
WORKDIR /src
COPY . .
# Cross-compile for the TARGET platform (see Rust section below).
RUN cargo build --release --target aarch64-unknown-linux-gnu

# --- Runtime stage: slim, target-platform image ---
FROM debian:bookworm-slim
COPY --from=builder /src/target/aarch64-unknown-linux-gnu/release/myapp /usr/local/bin/myapp
ENTRYPOINT ["/usr/local/bin/myapp"]
```

## buildx Multi-Arch Build

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag <your-registry>/<image:tag> \
  --push \
  .
```

- `--push` is **required** for multi-platform — the local Docker image store
  cannot hold a multi-arch manifest. `--load` only works for a single platform.
- Use `--push` to a registry, then verify with
  `scripts/verify-multi-arch.sh <your-registry>/<image:tag>`.

## Cross-Compilation vs QEMU

QEMU/binfmt emulation is 10-24x slower than native builds and known to fail:

- Rust segfaults under QEMU — [rust-lang/rust#147026](https://github.com/rust-lang/rust/issues/147026)
- mold linker crashes under QEMU — [rui314/mold#1550](https://github.com/rui314/mold/issues/1550)

For Rust, C++, or Go **production** builds, use cross-compilation toolchains or
native build hosts per architecture. QEMU is acceptable only for simple builds,
dependency installation, or prototyping.

### Build Platform vs Target Platform

```dockerfile
# Run build stages natively on the build host's platform (no QEMU).
FROM --platform=$BUILDPLATFORM golang:1-bookworm AS builder
ARG TARGETPLATFORM
# Cross-compile for the target platform.
RUN CGO_ENABLED=0 \
    GOOS=$(echo $TARGETPLATFORM | cut -d/ -f1) \
    GOARCH=$(echo $TARGETPLATFORM | cut -d/ -f2) \
    go build -o /out/myapp .
```

- `--platform=$BUILDPLATFORM` on `FROM` → stage runs natively (fast).
- `ARG TARGETPLATFORM` → injects the target arch for cross-compilation flags.
- This pattern avoids QEMU entirely for Go.

### Go Cross-Compilation

Go cross-compiles trivially with `CGO_ENABLED=0`:

```bash
CGO_ENABLED=0 GOOS=$(echo $TARGETPLATFORM | cut -d/ -f1) \
  GOARCH=$(echo $TARGETPLATFORM | cut -d/ -f2) go build
```

### Rust Cross-Compilation

Use [`cross-rs`](https://github.com/cross-rs/cross) or a manual target triple.
Avoid QEMU for Rust builds.

```dockerfile
FROM --platform=$BUILDPLATFORM rust:1-bookworm AS builder
ARG TARGETPLATFORM
# Install the target's std + linker.
RUN case "$TARGETPLATFORM" in \
      linux/amd64)  rustup target add x86_64-unknown-linux-gnu ;; \
      linux/arm64)  rustup target add aarch64-unknown-linux-gnu \
                    && apt-get update && apt-get install -y gcc-aarch64-linux-gnu ;; \
    esac
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc
RUN cargo build --release --target $(echo $TARGETPLATFORM | sed 's|linux/|unknown-linux-gnu|;s|amd64|x86_64|;s|arm64|aarch64|')
```

Or use `cross build --target <triple>` which handles the toolchain
automatically via its own cross-compilation containers.

## Base Image Selection

Prefer official multi-arch base images. Verify before using:

```bash
docker buildx imagetools inspect alpine:3.20
docker buildx imagetools inspect debian:bookworm-slim
docker buildx imagetools inspect nixos/nix:latest
```

Preference chain (generalized — do not hardcode org-specific names):

1. **Alpine** — smallest, musl libc. Use when the binary is static or musl-
   compatible.
2. **`debian:slim`** — glibc, broad package compatibility. Default for Rust /
   C++ dynamically-linked binaries.
3. **`nixos/nix`** — only when the runtime genuinely needs Nix (that's Branch C,
   not here).

Verify every base image is multi-arch before pinning. A single-arch base
breaks the whole build.

## Examples

- **Harmonia** (Rust binary) — serves the host `/nix/store` via a volume mount.
  The container itself does NOT need `nix-store` running inside; it's a Rust
  binary reading the mounted store. Build with a multi-stage Dockerfile +
  `cross-rs` or manual target triple, runtime image `debian:bookworm-slim`.
- **ncro** (pure HTTP proxy) — Go binary, `CGO_ENABLED=0` cross-compile,
  runtime image `alpine:3.20` or `scratch`.
