---
type: Practice
title: ESLint Composition API — Three Usage Patterns
description: Use @job-aide/tools-lint-eslint-config with three progressive patterns — direct re-export, options-based customization, and full composition with rest parameters for file-specific rules.
tags: [typescript, monorepo, eslint, linting, plugin-composition, api-design]
timestamp: 2026-07-17T00:00:00Z
---

# ESLint Composition API — Three Usage Patterns

## Failure Mode

Using a rigid shared ESLint config that forces teams to fork or eject when
they need to add a project-specific plugin (Drizzle ORM, Tailwind CSS, Prisma,
etc.). Problems:

1. **No customization**: Users can't add project-specific plugins.
2. **Fork required**: Must copy the entire config to add one plugin.
3. **Maintenance burden**: Forked configs diverge from upstream.
4. **Monorepo complexity**: Different packages need different plugins.
5. **Framework-specific**: Next.js, Remix, Astro need different setups.

## Practice

Use `@job-aide/tools-lint-eslint-config` with three progressive levels of
customization:

### Level 1: Direct Usage (Zero Config)

```ts
// eslint.config.mjs
export { default } from "@job-aide/tools-lint-eslint-config/eslint.config.mts";
```

Use when you want all defaults with zero configuration.

### Level 2: Options-Based Customization

```ts
// eslint.config.mjs
import jobAideEslintConfig from "@job-aide/tools-lint-eslint-config";
import drizzle from "eslint-plugin-drizzle";

export default jobAideEslintConfig({
  react: false,           // Toggle features
  vitest: false,
  plugins: { drizzle },   // Add custom plugins
  rules: {
    "drizzle/enforce-delete-with-where": "error",
  },
  antfuOptions: {         // Override antfu base config
    type: "app",
    vue: true,
  },
});
```

Use when you need to toggle features, add plugins, or override rules globally.

### Level 3: Full Composition with Rest Parameters

```ts
// eslint.config.mjs
import jobAideEslintConfig from "@job-aide/tools-lint-eslint-config";
import drizzle from "eslint-plugin-drizzle";

export default jobAideEslintConfig(
  { plugins: { drizzle } },
  // File-specific rules
  {
    files: ["src/db/**"],
    rules: { "drizzle/enforce-update-with-where": "error" },
  },
  // Another file-specific block
  {
    files: ["src/api/**"],
    rules: { "no-console": "off" },
  }
);
```

Use when you need file-specific rules (e.g., database files only).

## API Signature

```ts
function jobAideEslintConfig(
  options?: ConfigOptions,
  ...userConfigs: Linter.Config[]
): Linter.Config[]

interface ConfigOptions {
  react?: boolean;
  vitest?: boolean;
  runtimeGuard?: boolean;
  fileExtensions?: boolean;
  plugins?: Record<string, any>;
  rules?: Linter.RulesRecord;
  antfuOptions?: OptionsConfig;
  overrides?: Linter.Config[];
}
```

## Rationale

1. **Progressive disclosure**: Start simple, add complexity as needed.
2. **Flexibility**: Supports all use cases from zero-config to advanced.
3. **Type safety**: Full TypeScript support at all levels.
4. **Composability**: Can combine multiple configs easily.
5. **No forking**: Users can extend without copying the entire config.
6. **Framework support**: Leverages antfu's framework support (Vue, Svelte,
   Next.js, Remix, Astro) via `antfuOptions` passthrough.

## Monorepo Usage

Different packages can use different levels:

```ts
// Root config — base for all packages
export default jobAideEslintConfig(
  { antfuOptions: { type: "lib" } },
  // Database package specific
  {
    files: ["packages/database/**/*.mts"],
    plugins: { drizzle },
    rules: { "drizzle/enforce-delete-with-where": "error" },
  },
  // Web app specific
  {
    files: ["apps/web/**/*.tsx"],
    rules: { "react/jsx-no-target-blank": "error" },
  }
);
```

## Related Concepts

- [Explicit File Extensions](/explicit-file-extensions.md) — enforced via this
  config's `fileExtensions` option.
- [Path Alias Safety](/path-alias-safety.md) — enforced via this config's
  `no-restricted-imports` rule.
- [Code Style](/code-style.md) — double quotes, semicolons, 2-space indent
  enforced via this config.

## Citations

[1] [ADR-20251019003: Flexible Plugin Composition API for ESLint Config](https://github.com/levonk/job-aide/blob/main/internal-docs/adr/adr-20251019003-plugin-composition-api.md)
[2] [USAGE-EXAMPLES.md](https://github.com/levonk/job-aide/blob/main/packages/active/tools/lint/eslint-config/typescript/docs/USAGE-EXAMPLES.md)
[3] [typescript-rules.md](https://github.com/levonk/job-aide/blob/main/.devin/rules/typescript-rules.md) — ESLint Configuration section
[4] [ARCHITECTURE.md](https://github.com/levonk/job-aide/blob/main/internal-docs/ARCHITECTURE.md) — ESLint Configuration section
