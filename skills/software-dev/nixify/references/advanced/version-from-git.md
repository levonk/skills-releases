## Version from Git Revision

For source-build flakes that build from `src = self` (the repo's own source
tree) where there is **no language manifest with a version field**, derive the
Nix `version` attribute from the flake's git revision instead of hardcoding a
stale number.

### The pattern

```nix
version = "unstable-${self.shortRev or "dirty"}";
```

This produces:
- `unstable-a1b2c3d` — for builds at a committed git revision (the 7-char
  short SHA)
- `unstable-dirty` — for uncommitted/dirty working trees (the `or "dirty"`
  fallback)

### Flake attributes

| Attribute | Value | Notes |
|-----------|-------|-------|
| `self.shortRev` | First 7 chars of the commit SHA (e.g. `a1b2c3d`) | `null` for dirty/uncommitted trees — always pair with `or "dirty"` |
| `self.dirtyRev` | The short SHA with `-dirty` suffix, or `null` | Use when you want to distinguish dirty from clean in the version string |
| `self.lastModifiedDate` | Commit date as `YYYYMMDDHHMMSS` | Useful for sorting or as a fallback when `shortRev` is unavailable |

### When to use it

- **C/C++ projects with CMake** — there is no `Cargo.toml` or `package.json`
  to read the version from. CMake projects commonly derive the version from
  git tags at build time via `git describe` in `CMakeLists.txt`. The Nix
  `version` attribute should track the git revision too. See
  [`source-build/cmake.md`](../flake-templates/source-build/cmake.md) for the
  CMake template that uses this pattern.
- **Projects without a standard version file** — any project building from
  `src = self` where the version is not in a language manifest. A hardcoded
  `version = "1.26.0"` goes stale the moment the source moves past that tag;
  the git-revision pattern stays correct at every commit.

### When NOT to use it

- **Projects with a language manifest** — read the version from the manifest
  instead. This keeps the Nix version in sync with the project's own version
  declaration:
  - Rust: `version = (builtins.fromTOML (builtins.readFile ./Cargo.toml)).version;`
    (see [`source-build/rust.md`](../flake-templates/source-build/rust.md))
  - Node: `version = (pkgs.lib.importJSON ./package.json).version;`
    (see [`source-build/node.md`](../flake-templates/source-build/node.md))
- **Prebuilt tarball flakes** — the version comes from the release tag
  (`version = "<x.y.z>"` from `check-releases.sh`), not the git revision. The
  hash automation workflow bumps it on each release. See
  [`prebuilt-tarball.md`](../flake-templates/prebuilt-tarball.md) and
  [Release-Triggered Hash Automation](hash-automation.md).

### The `or "dirty"` fallback

`self.shortRev` is `null` when the working tree is dirty or uncommitted. The
`or "dirty"` fallback prevents a Nix evaluation error (`cannot coerce null to
string`). Without it, `nix build` fails on any dirty checkout — including
local development builds. Always include the fallback:

```nix
# Correct — handles dirty trees
version = "unstable-${self.shortRev or "dirty"}";

# Wrong — fails on dirty trees with "cannot coerce null to string"
version = "unstable-${self.shortRev}";
```

### CMake's `git describe` vs. Nix's `self.shortRev`

These are **complementary**, not redundant:

- **CMake's `git describe`** (run at build time inside `CMakeLists.txt`) reads
  git tags to embed a version string into the binary — the binary's internal
  `--version` output. This runs during the Nix build's `configurePhase`.
- **Nix's `self.shortRev`** (evaluated from the flake lock) sets the package
  `version` attribute — Nix package metadata, what `nix run` and
  `nix profile list` display.

Both track the git commit, so they stay in sync. The Nix sandbox has no
`.git` directory (it is filtered by `cleanSource`), so CMake's `git describe`
fallback would produce a garbage version without a fallback. Pass the
revision to CMake explicitly via a CMake flag:

```nix
cmakeFlags = [
  "-DGIT_REV=${self.shortRev or "dirty"}"
];
```

This lets CMake's `CMakeLists.txt` use `${GIT_REV}` as a fallback when
`git describe` fails (no `.git` in the sandbox). Do not try to make Nix read
the CMake-derived version — that would require running CMake's configure step
during Nix evaluation, which is not possible.

### Real-world example

The Deskflow flake hardcoded `version = "1.26.0"`, which became wrong the
moment the source moved past 1.26.0. The fix was:

```nix
version = "unstable-${self.shortRev or "dirty"}";
```

This tracks the git commit automatically — no manual version bump needed on
every source change. The `unstable-` prefix follows the Nixpkgs convention for
unreleased versions (packages not yet at a tagged release use
`unstable-<date>` or `unstable-<rev>`).
