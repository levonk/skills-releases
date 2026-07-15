# Source Build Flake: Node.js (pnpm/npm)

Use when the project does not have published binary releases and uses Node.js.

Use `buildNpmPackage` or `mkYarnPackage` from nixpkgs. Pin `package-lock.json` or `yarn.lock`.

**Important for npm-published packages:** `package-lock.json` is excluded from npm tarballs by default. Use `npm-shrinkwrap.json` instead (add `npm shrinkwrap` to your `prepublishOnly` hook). See `references/architecture-analysis.md` — Ensure Lockfiles in npm Tarballs for details.
