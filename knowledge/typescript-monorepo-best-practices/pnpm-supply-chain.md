---
type: Practice
title: pnpm Supply-Chain Hardening for Monorepos
description: Use pnpm overrides, patchedDependencies, onlyBuiltDependencies, .pnpmfile.mjs hooks, and packageExtensions to enforce dependency versions, patch vulnerable transitive deps, allowlist postinstall scripts, and fix broken peer dep declarations — the supply-chain security layer on top of pnpm workspaces and catalogs.
tags: [typescript, monorepo, pnpm, supply-chain, security, overrides, patches, postinstall, peer-dependencies]
generated:
  by: process:okf-v02-migration
  at: 2026-07-23T00:00:00Z
sources:
  - id: pnpm-settings-overrides-packageextensions-onlybuiltdependencies
    resource: https://pnpm.io/settings
    title: 'pnpm Settings — overrides, packageExtensions, onlyBuiltDependencies'
  - id: pnpm-patch-patcheddependencies
    resource: https://pnpm.io/cli/patch
    title: 'pnpm patch — patchedDependencies'
  - id: pnpm-pnpmfile-mjs-hooks
    resource: https://pnpm.io/pnpmfile
    title: 'pnpm .pnpmfile.mjs hooks'
  - id: ghsa-rxhj-4m44-96r4
    resource: https://github.com/pnpm/pnpm/security/advisories/GHSA-rxhj-4m44-96r4
    title: 'GHSA-rxhj-4m44-96r4 — Arbitrary File Write via Malicious Patch File (Path Traversal)'
  - id: pnpm-issue-11536
    resource: https://github.com/pnpm/pnpm/issues/11536
    title: 'pnpm issue #11536 — pnpm 11 silently ignores pnpm.overrides and pnpm.patchedDependencies in package.json'
  - id: shai-hulud-npm-worm-analysis
    resource: https://www.reversinglabs.com/blog/shai-hulud-worm-npm
    title: 'Shai-Hulud npm worm analysis (ReversingLabs, Sept 2025)'
  - id: shai-hulud-2-0-escalation
    resource: https://securitylabs.datadoghq.com/articles/shai-hulud-2.0-npm-worm/
    title: 'Shai-Hulud 2.0 escalation (Datadog Security Labs, Nov 2025)'
---

# pnpm Supply-Chain Hardening for Monorepos

## Failure Mode

A pnpm workspace with `catalog:` and `workspace:*` correctly pins **direct**
dependency versions, but the supply-chain attack surface extends well beyond
direct deps. Without the features below, a monorepo is vulnerable to:

1. **Vulnerable transitive dependencies**: A direct dep pulls in a transitive
   package with a known CVE. `catalog:` doesn't help — it only controls direct
   deps. Without `overrides`, the vulnerable transitive version ships to
   production.
2. **Malicious postinstall scripts**: A dependency (or a transitive dep) runs
   arbitrary code during `pnpm install` via `postinstall`/`preinstall`/`install`
   lifecycle scripts. The Shai-Hulud npm worm (Sept 2025) and its 2.0
   escalation (Nov 2025) spread exactly this way — by injecting malicious
   `postinstall` scripts into compromised packages, reaching ~795 packages by
   Nov 2025.
3. **Unpatched upstream bugs**: A third-party package has a security fix or
   critical bug that upstream hasn't released yet. Without `patchedDependencies`,
   you either fork the package (maintenance burden) or wait (exposure window).
4. **Path-traversal via malicious patches**: `patchedDependencies` itself is an
   attack vector — a malicious PR adding a `.patch` file with `../../` sequences
   in `diff --git` headers can write arbitrary files during `pnpm install`
   (advisory GHSA-rxhj-4m44-96r4).
5. **Broken peer dependency declarations**: A third-party package declares
   incorrect or missing peer deps (common in the React 19 ecosystem transition).
   Without `packageExtensions`, you get false-positive peer dep warnings or
   silent runtime failures.
6. **Silent regression on pnpm 11 upgrade**: `pnpm.overrides` and
   `pnpm.patchedDependencies` in `package.json` are **silently ignored** in
   pnpm 11 — no warning, no error. Security-critical overrides stop firing and
   CI stays green while the lockfile reverts to vulnerable transitive versions
   (see [pnpm issue #11536](https://github.com/pnpm/pnpm/issues/11536)).

## Practice

All supply-chain pnpm settings live in **`pnpm-workspace.yaml`** (not
`package.json#pnpm` — that location is silently ignored in pnpm 11+). Configure
five features, in order of how often you'll reach for them:

### 1. `overrides` — Force a Single Version Across the Entire Tree

`overrides` forces a specific version of any dependency, including **transitive**
deps that no `package.json` in the workspace directly declares. This is the
primary tool for CVE remediation on transitive packages.

```yaml
# pnpm-workspace.yaml
overrides:
  # Pin a transitive dep to a fixed version (CVE remediation)
  lodash@<4.17.21: 4.17.21

  # Replace a package with a fork
  broken-pkg: "@myorg/fixed-pkg"

  # Remove an unused dependency entirely
  unused-transitive-dep: "-"
```

`overrides` supports exact versions, ranges, package replacements, and removal
(`"-"`). It can also override peer dependencies. When a CVE advisory lands on a
transitive package, add an `overrides` entry — every workspace package gets the
fixed version in one line.

**Critical v11 migration**: if your project still has `pnpm.overrides` in
`package.json`, move it to `pnpm-workspace.yaml` before upgrading to pnpm 11.
The old location is silently ignored with no deprecation warning.

### 2. `patchedDependencies` — Patch Third-Party Packages at Install Time

`pnpm patch <pkg>` checks out the package source to a temp directory; you edit
it, then `pnpm patch-commit <temp-dir>` generates a `.patch` file and registers
it in `patchedDependencies`. The patch applies automatically on every
`pnpm install`.

```yaml
# pnpm-workspace.yaml
patchedDependencies:
  # Exact version (highest priority)
  express@4.18.2: patches/express@4.18.2.patch

  # Version range (applies to all matching versions except those pinned exactly)
  lodash@^4.17.0: patches/lodash@4.17.x.patch

  # Name-only (applies to all versions)
  react: patches/react.patch
```

Priority order: exact version > version range > name-only. Avoid overlapping
ranges — if you need a sub-range specialization, exclude it from the broader
range. In pnpm 11+, patch application failures **always throw** (the old
`ignorePatchFailures` setting was removed).

**Patch hygiene rules** (defends against GHSA-rxhj-4m44-96r4 path traversal):

- **Review every `.patch` file's `diff --git` headers** for `../` sequences
  before merging. A header like `diff --git a/../../.ssh/authorized_keys` is a
  path-traversal attack — it writes outside the package directory during
  `pnpm install`.
- **Keep a `patches/README.md`** documenting why each patch exists, with a link
  to the upstream issue/PR. Remove patches when upstream releases the fix.
- **Keep patches small and focused.** Large patches are hard to review and hard
  to maintain across version bumps.
- **Update patches when upgrading the patched dependency.** A patch for
  `express@4.18.2` won't apply cleanly to `express@4.19.0` — pnpm will throw.

### 3. `onlyBuiltDependencies` — Allowlist Postinstall Scripts

pnpm 10+ blocks all package build scripts (`postinstall`, `preinstall`,
`install`) by default and requires an explicit allowlist. This is a
default-on security feature — do not disable it with
`dangerouslyAllowAllBuilds: true`.

```yaml
# pnpm-workspace.yaml
onlyBuiltDependencies:
  # Only these packages may run lifecycle scripts during install
  - esbuild       # needs to build its native binary
  - sharp         # needs to download platform binaries
  - @biomejs/biome  # needs to fetch its binary
  - swc           # needs to build native bindings
```

When you add a new dependency that needs a build script, pnpm will print a
warning listing the package — add it to `onlyBuiltDependencies` after verifying
the package is trustworthy and the script is necessary. If a package doesn't
need its postinstall (e.g. it's a pure JS package with a vestigial script),
don't allowlist it.

**Why this matters**: the Shai-Hulud worm spread by injecting malicious
`postinstall` scripts into compromised npm packages. With
`onlyBuiltDependencies`, a compromised package's script never runs unless
you've explicitly allowlisted it.

### 4. `.pnpmfile.mjs` — Install-Time Hooks

`.pnpmfile.mjs` (ESM) or `.pnpmfile.cjs` (CommonJS) lives at the workspace root
(next to the lockfile) and lets you hook into the installation process
programmatically. Use this when declarative `overrides` isn't expressive enough.

```javascript
// .pnpmfile.mjs
export const hooks = {
  readPackage(pkg, context) {
    // Strip postinstall scripts from a dependency that doesn't need them
    if (pkg.name === 'noisy-dep') {
      delete pkg.scripts?.postinstall
    }
    // Conditionally rewrite a peer dep range
    if (pkg.name === 'react-ecosystem-pkg' && pkg.peerDependencies?.react) {
      pkg.peerDependencies.react = '>=18.0.0'
    }
    return pkg
  },
}
```

| Hook | When it runs | Use for |
|------|-------------|---------|
| `readPackage(pkg, ctx)` | After pnpm parses each dep's manifest | Mutate a dep's `package.json` (strip scripts, rewrite deps/peer deps) |
| `afterAllResolved(lockfile, ctx)` | After dependency resolution | Mutate the lockfile |
| `beforePacking(pkg)` | Before `pnpm pack`/`pnpm publish` | Customize the published manifest |

**Prefer `overrides` and `packageExtensions` over `.pnpmfile.mjs`** when
possible — declarative config is reviewable and grep-able; programmatic hooks
are not. Reach for `.pnpmfile.mjs` only when the declarative features can't
express the constraint (e.g. conditional logic, script stripping).

### 5. `packageExtensions` — Fix Broken Peer Dep Declarations

Third-party packages sometimes ship with incorrect or missing peer dependency
declarations. `packageExtensions` adds the missing peer deps without forking or
patching the package.

```yaml
# pnpm-workspace.yaml
packageExtensions:
  # React 19 ecosystem package that declares peerDependencies.react as ^17 || ^18
  # but actually works fine with React 19
  'react-ecosystem-pkg@*':
    peerDependencies:
      react: '>=17.0.0'
    peerDependenciesMeta:
      react:
        optional: false
```

This is the correct fix for false-positive peer dep warnings during ecosystem
transitions (e.g. React 18 → 19, Next.js 14 → 15). Don't use it to silence
legitimate peer dep mismatches — only to correct upstream declaration errors.

## Rationale

- **`overrides`**: The only way to pin a transitive dependency version across
  the entire workspace. Essential for CVE remediation — security advisories
  frequently land on transitive packages that no `package.json` directly
  declares. One line in `pnpm-workspace.yaml` fixes every package at once.
- **`patchedDependencies`**: Bridges the gap between "upstream is broken" and
  "upstream releases a fix." Better than forking (no separate package to
  maintain) and better than waiting (exposure window is closed immediately).
  The path-traversal advisory means patch files need the same review scrutiny
  as executable code.
- **`onlyBuiltDependencies`**: Default-on in pnpm 10+, this is the single most
  effective defense against postinstall-based supply-chain attacks. The
  Shai-Hulud worm would have been blocked by this allowlist in any project that
  didn't already trust the compromised package.
- **`.pnpmfile.mjs`**: The escape hatch when declarative config isn't enough.
  Programmatic manifest mutation handles conditional logic and script stripping
  that `overrides`/`packageExtensions` can't express.
- **`packageExtensions`**: The declarative fix for broken upstream peer dep
  declarations. Prevents both false-positive warnings and silent runtime
  failures during ecosystem version transitions.

## Consequences

### Positive

- Vulnerable transitive deps are pinned to fixed versions in one line
  (`overrides`).
- Critical upstream bugs are patched without forking (`patchedDependencies`).
- Malicious postinstall scripts are blocked by default
  (`onlyBuiltDependencies`).
- Broken peer dep declarations are corrected without forks or patches
  (`packageExtensions`).
- Programmatic install-time mutation is available when declarative config is
  insufficient (`.pnpmfile.mjs`).

### Negative

- `overrides` and `patchedDependencies` in `package.json#pnpm` are silently
  ignored in pnpm 11+ — projects upgrading from pnpm 10 must migrate these to
  `pnpm-workspace.yaml` or lose security controls with no warning.
- `.patch` files are a path-traversal attack vector (GHSA-rxhj-4m44-96r4) and
  require the same review scrutiny as executable code.
- `onlyBuiltDependencies` requires manual maintenance — every new dependency
  that needs a build script must be allowlisted, or its build won't run.
- `.pnpmfile.mjs` hooks are programmatic and harder to review than declarative
  config — overuse reduces install-time transparency.
- `packageExtensions` can mask legitimate peer dep mismatches if used to
  silence warnings rather than fix declaration errors.

## Migration

1. **Audit current `pnpm.overrides` and `pnpm.patchedDependencies`**: if they
   live in `package.json#pnpm`, move them to `pnpm-workspace.yaml` immediately
   (silent-ignore risk on pnpm 11).
2. **Add `onlyBuiltDependencies`**: run `pnpm install` and review the warning
   listing packages that want to run build scripts. Allowlist the trustworthy
   ones; leave the rest blocked.
3. **Audit existing `.patch` files**: check every `diff --git` header for `../`
   path traversal. Add a `patches/README.md` documenting each patch's rationale
   and upstream tracking link.
4. **Add `packageExtensions`** for any third-party packages emitting false
   positive peer dep warnings during ecosystem transitions.
5. **Reserve `.pnpmfile.mjs`** for cases the declarative features can't handle.
   If a `.pnpmfile.mjs` already exists, audit each hook — can it be replaced
   with `overrides` or `packageExtensions`?

## Related Concepts

- [pnpm and Nx Monorepo](/pnpm-nx-monorepo.md) — the workspace and catalog
  foundation this layer builds on. `catalog:` pins direct dep versions;
  `overrides` pins transitive dep versions. They are complementary.
- [Explicit File Extensions](/explicit-file-extensions.md) — ESM-first
  convention. `.pnpmfile.mjs` (not `.pnpmfile.js`) follows this rule.
- [Code Style](/code-style.md) — kebab-case applies to patch filenames
  (`patches/express@4.18.2.patch`, not `Express@4.18.2.Patch`).


