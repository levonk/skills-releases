# Boilerplate Integration

This skill references the **boilerplate** submodule (vendored at
`vendor/boilerplate/`) for standard configurations. The submodule is pinned
by SHA in `.gitmodules` — bump the pin to consume newer boilerplate versions.

## Preference Templates
- **TypeScript projects**: `vendor/boilerplate/apps/web/typescript/nextjs/`
- **Rust CLI**: `vendor/boilerplate/apps/cli/rust/`
- **Rust packages**: `vendor/boilerplate/packages/category/general/domain/package-name/rust/`
- **Python packages**: `vendor/boilerplate/packages/category/general/domain/package-name/python/`
- **Go packages**: `vendor/boilerplate/packages/category/general/domain/package-name/go/`

## Configuration Patterns
Extract common patterns from boilerplates:
- **ESLint configurations**: Standard rule sets and overrides
- **CI/CD templates**: GitHub Actions workflows for different languages
- **Development environment**: devbox.json and justfile patterns
- **Documentation structures**: Standard docs/ and internal-docs/ organization
- **Shared partials**: `_shared/` directory contains reusable Jinja partials
  for devbox packages, Nx targets, CI workflows, and justfile snippets

## Using includeJinja

To inline boilerplate content into a skill or knowledge bundle, use the
`includeJinja` templater function:

```
{{{ includeJinja "vendor/boilerplate/apps/cli/rust/core/files/justfile.jinja" . }}}
```

This resolves `{% include "partials.bak/..." %}` directives (mapping
`partials.bak/` → `_shared/`) and strips remaining Jinja expressions.
