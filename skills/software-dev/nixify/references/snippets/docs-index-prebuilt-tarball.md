:::code-group

```bash [npm]
npm install -g <package-name>
```

```bash [Homebrew]
brew install <formula>
```

```bash [Nix]
# Latest release (auto-bumped daily, prebuilt)
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO
nix profile install github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Build from source instead
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#source
```

:::
