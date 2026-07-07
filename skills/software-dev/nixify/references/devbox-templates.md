# Devbox Templates

## Table of Contents

- [Rust (Cargo)](#rust-cargo)
- [Node.js (pnpm/npm/bun)](#nodejs-pnpmnpmbun)
- [Go](#go)
- [Python](#python)
- [Darwin-Specific Notes](#darwin-specific-notes)

---

## Rust (Cargo)

```json
{
  "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/0.12.0/.schema/devbox.schema.json",
  "packages": [
    "rustc",
    "cargo",
    "rust-analyzer",
    "pkg-config",
    "openssl"
  ],
  "shell": {
    "init_hook": [
      "echo 'Welcome to the Devbox environment!'"
    ],
    "scripts": {
      "build": "cargo build --release",
      "test": "cargo test",
      "run": "cargo run --"
    }
  }
}
```

---

## Node.js (pnpm/npm/bun)

```json
{
  "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/0.12.0/.schema/devbox.schema.json",
  "packages": [
    "nodejs_20",
    "pnpm"
  ],
  "shell": {
    "init_hook": [
      "echo 'Welcome to the Devbox environment!'"
    ],
    "scripts": {
      "install": "pnpm install",
      "build": "pnpm build",
      "test": "pnpm test",
      "dev": "pnpm dev"
    }
  }
}
```

**Note on `nodejs_20` vs `bun`:** If the project uses `bun` as its runtime/package manager, verify whether `nodejs_20` is still required for any development tooling (e.g., linters, build scripts, or CI tooling that expect a `node` binary). If `bun` covers all runtime needs, remove `nodejs_20` to keep the devbox lean.

---

## Go

```json
{
  "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/0.12.0/.schema/devbox.schema.json",
  "packages": [
    "go",
    "gopls"
  ],
  "shell": {
    "init_hook": [
      "echo 'Welcome to the Devbox environment!'"
    ],
    "scripts": {
      "build": "go build ./...",
      "test": "go test ./...",
      "run": "go run ."
    }
  }
}
```

---

## Python

```json
{
  "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/0.12.0/.schema/devbox.schema.json",
  "packages": [
    "python311",
    "uv"
  ],
  "shell": {
    "init_hook": [
      "echo 'Welcome to the Devbox environment!'"
    ],
    "scripts": {
      "install": "uv pip install -e .",
      "test": "uv run pytest",
      "run": "uv run python"
    }
  }
}
```

---

## Darwin-Specific Notes

For macOS, add platform-specific packages if needed:

```json
{
  "packages": [
    "rustc",
    "cargo",
    "pkg-config",
    "openssl"
  ],
  "shell": {
    "env": {
      "PKG_CONFIG_PATH": "${PKG_CONFIG_PATH}:${pkgs.openssl.dev}/lib/pkgconfig"
    }
  }
}
```
