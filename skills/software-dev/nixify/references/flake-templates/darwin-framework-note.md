# Darwin Framework Note

If the build fails with:

```
error: darwin.apple_sdk_11_0 has been removed as it was a legacy compatibility stub
```

Remove the deprecated `pkgs.darwin.apple_sdk.frameworks.Security` reference. Modern `rustPlatform` / `stdenv` handles Security framework linking automatically. Keep only `pkgs.libiconv` in `buildInputs` for Darwin.
