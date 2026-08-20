# Unsupported Platform — Context-Aware Error Messages

Shared snippet for all flake templates. Provides context-aware `throw` messages so users in
different situations see the right error instead of Nix's generic "unsupported platform" or
"hash mismatch" text.

## Three error contexts (never overlap)

| Context | Trigger | Message |
|----------|---------|---------|
| Unsupported platform | User's system not in `meta.platforms` | "This project is `<scope>`-only. It doesn't expose `<excluded>` targets. To build from source on `<included>`, see the project's build instructions." |
| FakeHash unverified | User's system IS in `meta.platforms` but hash is `lib.fakeHash` | "The `<system>` source-build hash is unverified (set to `lib.fakeHash` after GitHub's Intel macOS runner was decommissioned). Run `nix build .#source` on an Intel Mac to compute the real hash, then open a PR with the updated hash." |
| CI runner decommissioned | `validate-x86-darwin` job fails in CI | Self-prune PR explains the runner retirement (see `references/advanced-features.md` — Self-Pruning on Runner Decommission) |

## Nix implementation

Add this to the flake's `outputs` function, before the `packages` attrset. It checks the caller's
system against `meta.platforms` and throws a descriptive error if the platform is not supported.

```nix
# Context-aware error for unsupported platforms.
# Replace <scope> with "macOS", "Linux", or the project's platform scope.
# Replace <excluded> and <included> with the appropriate platform families.
assertUnsupportedPlatform = system: supportedSystems:
  if builtins.elem system supportedSystems
  then true
  else throw ''
    This project is macOS-only (uses macOS UI frameworks).
    It does not expose Linux targets. To build from source on macOS:

      nix build .#source          # from-source build
      nix run .#default -- --version   # smoke test

    If you need Linux support, open an issue — the project may not be
    architecturally portable to Linux (e.g. it uses AppKit/CoreAudio).
  '';
```

For the fakeHash-unverified case, the error comes from Nix itself when the hash mismatch is
detected. To make it more helpful, wrap the FOD with a custom error message:

```nix
# When x86_64-darwin FOD hash is lib.fakeHash (after runner decommission),
# the hash mismatch error is unhelpful. Wrap with a descriptive message.
fakeHashWarning = system: hash:
  if hash == lib.fakeHash && system == "x86_64-darwin"
  then throw ''
    The x86_64-darwin source-build hash is unverified (set to lib.fakeHash
    after GitHub's Intel macOS runner was decommissioned — see
    https://github.com/actions/runner-images/issues/13739).

    To compute the real hash:
      1. Run this on an Intel Mac:
         nix build .#source --system x86_64-darwin
      2. Nix will fail with "got: sha256-<realHash>"
      3. Replace lib.fakeHash with the real hash in flake.nix
      4. Open a PR with the updated hash

    If you do not have an Intel Mac, the prebuilt binary (#prebuilt) may
    still work if the project ships a release asset for x86_64-darwin:
      nix run .#prebuilt --system x86_64-darwin
  ''
  else hash;
```

## Usage in flake templates

In the flake's `packages` attrset, apply the assertions:

```nix
packages = forAllSystems (system:
  assert assertUnsupportedPlatform system target_platforms;
  let
    # ... existing package definition ...
    # Apply fakeHashWarning to x86_64-darwin FOD hashes:
    sha256 = fakeHashWarning system (assets.${system}.sha256 or lib.fakeHash);
  in
    # ... package derivation ...
);
```

## When to include

Include this snippet in:
- All prebuilt tarball flake templates (standard + hybrid fallback)
- All source-build flake templates that declare `meta.platforms` narrower than `eachDefaultSystem`
- Any flake that sets `x86_64-darwin` FOD hashes to `lib.fakeHash` after runner decommission

## When NOT to include

- Flakes that support all default systems (`eachDefaultSystem`) — no platform is excluded, so the
  unsupported-platform error never fires
- Flakes with no `#source` output — the fakeHash warning only applies to source-build FODs
