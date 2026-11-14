---
type: Practice
title: Relax JIT Dev Loop
description: Relax (makepad/relax) is the preferred dev edit-run loop for Rust — a live compiler and JIT runtime that runs a Cargo package straight from source, hot-patches saved edits into the running process, and re-runs affected tests on save. cargo + rustc remain canonical for release builds, CI gates, and published artifacts.
tags: [rust, relax, jit, dev-loop, hot-reload, cargo, toolchain]
date:
  created: "2026-11-14"
  knowledge-basis: "2026-11-14"
  last-used: "2026-11-14"

sources:
  - id: makepad-relax
    resource: "https://github.com/makepad/relax"
    title: "Relax — Rust JIT (makepad)"
  - id: makepad-relax-known-gaps
    resource: "https://github.com/makepad/relax/blob/main/libs/relax/KNOWN_GAPS.md"
    title: "Relax — Known Gaps"
---

# Relax JIT Dev Loop

## Failure Mode

The `cargo build` → link → restart cycle makes every iteration pay a full
crate-graph compile. A one-function change rebuilds, relinks, and restarts the
program — process state is lost, test binaries rebuild from scratch, and the
edit-verify feedback loop stretches to minutes on large packages. For agents
iterating on Rust code, that latency compounds across every correction cycle.

## Practice

Use [Relax](https://github.com/makepad/relax) as the dev-loop front end for
Rust packages. Relax is a live compiler and JIT runtime written in Rust — it
runs a Cargo package straight from source with no rustc, LLVM, or linker in
the loop. It compiles each function on first call, optimizes hot functions in
the background (interpreter → O1 → O3), and patches saved edits into the
running process.

### Commands

| Command | What it does |
|---------|--------------|
| `relax run <package>` | Run `main` under the JIT; prints `relax-remote: pid <pid>`. Saved edits recheck, recompile, and hot-patch changed functions while the program keeps its state. |
| `relax test --live <package>` | Keep tests warm; re-run only the tests that entered the changed functions on each save. |
| `relax check <package>` | Type- and borrow-check only. `relax run --check-first` waits for the borrow checker before running. |
| `relax inspect <pid> <cmd>` | Ask the running program questions: `panics`, `locals panic=P1`, `eval <expr>`, `break <file>:<line>`, `why-hung`, `prof s=3`, `memory`, `heap diff a now`, `rec save`. |
| `relax inspect <pid> session relaunch` | Restart when an edit cannot patch live (struct layout, imports, trait or impl headers, macros). |
| `relax clean` | Remove the package's `target/relax` code cache. |

Run `relax` from the package's directory and give it the package **name**, not
a path.

### Boundaries — relax is not rustc

- **Experimental.** Relax is an AI-generated reimplementation of the Rust
  toolchain, not affiliated with the Rust project. It does not inherit rustc's
  safety guarantees — a Relax bug can make a correct program misbehave at
  runtime. Known open gaps are tracked in
  [KNOWN_GAPS.md](https://github.com/makepad/relax/blob/main/libs/relax/KNOWN_GAPS.md).
- **Dev-loop only.** Build anything shipped with rustc:
  `cargo build --release`. `cargo test` / `cargo nextest`, `cargo check`,
  `cargo clippy`, and `cargo fmt` remain the canonical CI gates
  (see [Quality Gates](quality-gates.md)).
- **Slower optimized code** — about 1.12× rustc `--release` time on x86-64 and
  1.24× on AArch64. Pay it only during iteration.
- **`relax check` is not faster than `cargo check` yet** on large packages —
  keep `cargo check` in quality gates.
- **Not every edit patches live.** Function bodies do; struct layout, import,
  trait/impl-header, and macro changes need `session relaunch`.
- **`relax test` emits no rustc-format `.rlib`/`.rmeta`** — a test that hands
  the crate's `.rlib` to an external rustc needs `cargo build --lib` first.
- **Platforms**: tested on Linux x86-64 and macOS arm64; Windows is untested.
  JIT code is append-only and shares the program's process — a `hello` package
  keeps 120–190 MB in `target/relax`.

### Install

Relax is not on crates.io — build the runner from a kept checkout:

```sh
git clone https://github.com/makepad/relax
cargo build --release --manifest-path relax/Cargo.toml -p relax-runner --bin relax
# binary: relax/target/release/relax — keep the checkout; it reads Relax's std from it
```

Crates.io dependencies resolve from `~/.cargo`'s registry when present, else
download with index SHA-256 verification. `RELAX_OFFLINE=1` or
`CARGO_NET_OFFLINE` disables downloads. `relax fetch <git-url>` stores a git
dependency as one file under `~/.relax`.

### When to reach for it

- Rapid edit-verify cycles on a running, stateful program (games, UI, services,
  long-setup binaries) — a saved file patches in without losing state.
- Test-driven iteration — `relax test --live` re-runs only affected tests.
- Agent-driven development — Relax is designed to minimize iteration latency
  for LLMs working with Rust code; `relax inspect` gives breakpoint-free
  debugging (`why-hung`, `eval`, `locals`) an agent can drive non-interactively.
- First-run latency — a large crate that takes ~3 min to `cargo build` reaches
  first frame in ~11 s cold, ~1 s warm (M4-class hardware, per upstream).

## Related Concepts

- [Cargo Configuration](cargo-configuration.md) — manifest and workspace
  settings Relax reads; release builds stay on rustc
- [Testing Strategy](testing-strategy.md) — `relax test --live` for the dev
  loop; `cargo test`/`cargo nextest` for CI
- [Quality Gates](quality-gates.md) — `relax check` in dev; cargo-based gates
  in CI
- [File Watcher Patterns](file-watcher-patterns.md) — the watch-trigger model
  Relax applies to source edits
- [Performance Practices](performance-practices.md) — measure-first; Relax's
  1.12–1.24× optimized-code overhead is a dev-time cost only
