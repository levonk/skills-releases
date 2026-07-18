---
type: Practice
title: ESLint Composition API
description: Three-level ESLint config customization — direct usage (zero config), options-based (toggle features, add plugins), and full composition (file-specific rules via rest parameters).
tags: [eslint, composition, plugins, api-design, configuration, customization]
timestamp: 2026-07-17T00:00:00Z
---

# ESLint Composition API

## Failure Mode

Rigid shared ESLint configs force users to fork the entire config to add one
plugin. Forked configs diverge from upstream. Different packages in a monorepo
need different plugins but can't customize independently.

## Practice

Provide **three levels of customization**:

### Level 1: Direct Usage (Zero Config)

```ts
export { default } from "@job-aide/tools-lint-eslint-config/eslint.config.mts";
```

### Level 2: Options-Based Customization

```ts
import jobAideEslintConfig from "@job-aide/tools-lint-eslint-config";
import drizzle from "eslint-plugin-drizzle";

export default jobAideEslintConfig({
  react: false,
  vitest: false,
  plugins: { drizzle },
  rules: {
    "drizzle/enforce-delete-with-where": "error",
  },
});
```

### Level 3: Full Composition with Rest Parameters

```ts
export default jobAideEslintConfig(
  { plugins: { drizzle } },
  {
    files: ["src/db/**"],
    rules: { "drizzle/enforce-update-with-where": "error" },
  }
);
```

### API Signature

```ts
function jobAideEslintConfig(
  options?: ConfigOptions,
  ...userConfigs: Linter.Config[]
): Linter.Config[]
```

### Why Three Levels

1. **Zero config** for simple projects that just want the defaults
2. **Options** for projects that need to toggle features or add common plugins
3. **Full composition** for projects that need file-specific rules or custom
   config objects

## Related Concepts

- [Explicit File Extensions](explicit-file-extensions.md) — Rules enforced by
  this config
- [Path Alias Safety](path-alias-safety.md) — Rules enforced by this config
- [Code Style Conventions](code-style-conventions.md) — Style rules in this config

## Citations

[1] `internal-docs/adr/adr-20251019003-plugin-composition-api.md` — job-aide
