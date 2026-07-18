---
type: Practice
title: JavaScript and TypeScript Fundamentals
description: JavaScript ES modules, modern syntax, error handling, performance, security, JSDoc typing standards, import standards, config hygiene, and tooling integration for TypeScript monorepos.
tags: [javascript, typescript, es-modules, jsdoc, error-handling, performance, security, imports, config-hygiene, tooling]
timestamp: 2026-07-18T00:00:00Z
---

# JavaScript and TypeScript Fundamentals

Foundation-layer practices for JavaScript and TypeScript development in a
monorepo. This page covers the concerns that sit *below* the monorepo-specific
conventions (file extensions, path aliases, ESLint composition, package
managers, testing, naming, structure) — the language-level patterns, typing
standards, import hygiene, and config discipline that every package inherits.

## JavaScript ES Modules and Modern Syntax

### Module System Standards

- **Use ESM syntax**: `import`/`export` instead of `require`/`module.exports`
- **Dynamic imports**: Use `import()` for conditional loading
- **Named exports**: Prefer named exports over default exports for tree-shaking
- **CommonJS (legacy)**: Use only when required by legacy Node.js modules or
  specific tooling; use `.cjs` for explicit CommonJS in ESM projects
- **Consistency**: Don't mix module systems in the same file

```javascript
// ✅ Preferred ESM
import { getUser, createPost } from "./api.mjs";
export { processData, formatData };

// ✅ Dynamic import for conditional loading
const module = await import("./heavy-module.mjs");
```

```javascript
// ❌ Avoid in new code
const fs = require("fs");
module.exports = { handler };

// ✅ Use ESM instead
import fs from "fs";
export { handler };
```

For explicit file extension conventions (`.mts`, `.cts`, `.tsx`, `.mjs`,
`.cjs`, `.d.ts`), see [Explicit File Extensions](explicit-file-extensions.md).

### Modern JavaScript Features

- **Use modern syntax**: Destructuring, spread/rest, template literals, arrow
  functions
- **Async/await**: Prefer over Promise chains or callbacks
- **Optional chaining**: Use `?.` for safe property access
- **Nullish coalescing**: Use `??` instead of `||` for null/undefined checks
- **Object.hasOwn()**: Use instead of `obj.hasOwnProperty()`

```javascript
// ✅ Modern patterns
const { name, age } = user;
const items = [...baseItems, ...newItems];
const greeting = `Hello ${name}`;
const data = response?.data ?? {};
if (Object.hasOwn(obj, "property")) { /* ... */ }

// ✅ Async/await
async function fetchData() {
  try {
    const response = await fetch("/api/data");
    const data = await response.json();
    return data;
  } catch (error) {
    console.error("Fetch failed:", error);
  }
}
```

## Error Handling Patterns

- **Try/catch for async operations**: Always handle promise rejections
- **Custom errors**: Extend `Error` class for domain-specific errors
- **Error logging**: Include context and stack traces
- **Graceful degradation**: Provide fallbacks when possible
- **Re-throw unexpected errors**: Don't swallow errors you can't handle

```javascript
// ✅ Proper error handling
class ValidationError extends Error {
  constructor(message, field) {
    super(message);
    this.name = "ValidationError";
    this.field = field;
  }
}

async function processData(input) {
  try {
    if (!input) throw new ValidationError("Input required", "data");
    return await transform(input);
  } catch (error) {
    if (error instanceof ValidationError) {
      console.warn(`Validation failed: ${error.message}`);
      return getDefaultData();
    }
    throw error; // Re-throw unexpected errors
  }
}
```

## Performance Patterns

### Memory Management

- **Avoid memory leaks**: Clean up event listeners, timers, and intervals
- **Lazy loading**: Use dynamic imports for heavy modules
- **Object pooling**: Reuse objects in performance-critical code
- **Weak references**: Use `WeakMap`/`WeakSet` for cached metadata

```javascript
// ✅ Memory management
class Component {
  constructor() {
    this.handleClick = this.handleClick.bind(this);
  }

  mount() {
    document.addEventListener("click", this.handleClick);
  }

  unmount() {
    document.removeEventListener("click", this.handleClick);
  }
}

// ✅ Lazy loading
const heavyModule = await import("./heavy-module.mjs");
```

### Code Splitting

- **Dynamic imports**: Split code by routes or features
- **Tree shaking**: Use named exports to enable dead code elimination
- **Bundle analysis**: Regularly audit bundle sizes

## Security Practices

### Input Validation

- **Sanitize all inputs**: Never trust external data
- **Use validation libraries**: Joi, Zod, or built-in validation
- **Prevent injection**: Use parameterized queries, avoid `eval()`

```javascript
// ✅ Input validation
function validateUser(data) {
  if (!data || typeof data !== "object") {
    throw new Error("Invalid user data");
  }

  const required = ["name", "email"];
  for (const field of required) {
    if (!data[field] || typeof data[field] !== "string") {
      throw new Error(`Missing required field: ${field}`);
    }
  }

  return data;
}
```

### Secure Coding Practices

- **Avoid `eval()`**: Use safer alternatives like `JSON.parse()`
- **Content Security Policy**: Configure CSP headers
- **HTTPS only**: Never send sensitive data over HTTP
- **Environment variables**: Use for secrets, never commit to repo

## JSDoc Typing Standards (for Gradual Migration)

JSDoc is TypeScript — TypeScript parses JSDoc, and `tsc` can type-check
JavaScript when configured. This makes JSDoc the bridge for gradual migration
from JavaScript to TypeScript.

- **Prefer JSDoc typing for JS**: In `*.js` / `*.mjs` / `*.cjs` files, prefer
  `// @ts-check` plus JSDoc types over ad-hoc comments
- **Project config**: When a codebase relies on JSDoc typing, enable `allowJs`
  + `checkJs` (and usually `noEmit`) in the relevant `tsconfig.json`, and run
  `tsc --noEmit` in CI
- **Use TypeScript syntax inside JSDoc types**: Unions (`string | number`),
  intersections (`A & B`), generics (`Array<string>`, `Promise<Result>`), and
  object shapes (`{ id: string, count: number }`)
- **Import types explicitly**: Use `import()` types for cross-module
  references; example: `@typedef {import("./types.mts").UserId} UserId`
- **Use standard tags**:
  - `@param {Type} name` for parameters; keep `name` aligned with the function
    signature
  - `@returns {Type}` for return types
  - `@typedef {Type} Name` for reusable aliases
  - `@template T` for generics (only when inference can't do the job)
- **Avoid JSDoc in TS unless it is documentation**: In `*.ts` / `*.mts`,
  prefer real TS types for typing; use JSDoc for behavior docs and public API
  docs

```javascript
// @ts-check

/** @typedef {{ id: string, email: string }} User */

/**
 * @param {User} user
 * @returns {string}
 */
export function formatUser(user) {
  return user.email.toLowerCase();
}
```

### JSDoc for Public APIs

- **Public APIs**: Document all public functions and classes
- **Parameter types**: Use JSDoc type annotations
- **Examples**: Include usage examples
- **@deprecated**: Mark deprecated APIs with migration path

```javascript
/**
 * Calculates the total price including tax and discount.
 * @param {number} basePrice - The original price
 * @param {number} discount - Discount percentage (0-1)
 * @param {number} tax - Tax percentage (0-1)
 * @returns {number} Final price
 * @example
 * calculatePrice(100, 0.1, 0.08) // Returns 97.2
 */
function calculatePrice(basePrice, discount, tax) {
  // Implementation...
}
```

### Migration Path to TypeScript

When transitioning to TypeScript:

1. **Add JSDoc types**: Use JSDoc for gradual typing
2. **Enable `checkJs`**: Add `"checkJs": true` to `tsconfig.json`
3. **Rename files**: Progressively rename `.js` to `.ts` (or `.mjs` to `.mts`)
4. **Add type definitions**: Create `.d.ts` files for untyped modules

```javascript
// ✅ JSDoc for gradual migration
/**
 * @typedef {Object} User
 * @property {string} name
 * @property {string} email
 * @property {number} age
 */

/**
 * @param {User} user
 * @returns {string}
 */
function formatUser(user) {
  return `${user.name} (${user.email})`;
}
```

## Import Standards

### Named and Grouped Imports

- **Named imports**: Prefer named imports over default imports
- **Grouped imports**: Group imports by origin (external packages, internal
  packages, local modules)
- **Wildcard imports**: Prefer explicit imports over wildcard imports
- **No side effects**: Avoid side effects in imports

### Path Aliases and Module Boundaries

- **Path aliases**: If the repo uses path aliases, avoid ambiguous `@` and
  `@/*` aliases; prefer explicit category-based aliases. See
  [Path Alias Safety](path-alias-safety.md) for the full convention.
- **Repo compliance**: Follow the repo's existing alias strategy. Do not
  introduce new alias schemes unless explicitly tasked.
- **Absolute imports**: Prefer relative imports over absolute imports
- **Deep imports**: Avoid deep relative imports (`../../../../`); if
  necessary, use barrel files
- **`index.ts` imports**: Prefer explicit paths vs. importing from `index.ts`
- **Circular imports**: Use lint or static analysis to detect circular
  dependencies and refactor to avoid them
- **Module boundaries**: Enforce via ESLint `no-restricted-imports` that
  module boundaries shouldn't be violated by importing outside of exports

### Clean Imports via Index Files

- **Single responsibility**: Each file/module has one clear purpose
- **Logical grouping**: Group related functionality
- **Index files**: Use for clean imports

```javascript
// ✅ Clean imports
// Instead of:
import { getUser } from "../../../services/api/users.mjs";
import { createPost } from "../../../services/api/posts.mjs";

// Use:
import { getUser, createPost } from "../services/api/index.mjs";
```

## Config Hygiene

### TypeScript Standards

- **TypeScript version**: Prefer >= 5.9.2 on greenfield; suggest upgrade
  otherwise
- **ECMAScript Modules**: Prefer ESM on greenfield; suggest migrating from
  CJS/AMD/UMD
- **Strict mode**: Always enabled in `tsconfig.json`
- **Eradicate `any`**: Use proper types or `unknown`
- **No `as` casting**: Fix type issues at source
- **Explicit types**: Prefer explicit over implicit
- **Interfaces vs types**: Interfaces for objects (see also
  [Code Style](code-style.md) which prefers `type` over `interface` for type
  definitions — use `interface` for object shapes that may be extended, `type`
  for unions, intersections, and functional styles)
- **No suppressions**: Never use `// eslint-disable`, `// @ts-ignore`, or
  weaken configs to hide problems
- **Aggressive immutability**: Enforce `const`, `readonly`, `Readonly<T>`,
  `as const` where applicable
- **Modern & safe syntax**: Use optional chaining `?.`, nullish coalescing
  `??`, `Object.hasOwn()`
- **Deterministic diffs**: Change only what's necessary; honor formatter and
  file ordering
- **Named exports**: Prefer named exports over default exports

### tsconfig and package.json

- **Mirror `tsconfig.paths`**: Mirror path aliases in ESLint and Jest/Vitest
  configs
- **Type imports**: `type` imports are for types only — use `import type`
- **Style importing**: `.css` and `.scss` should use dedicated style entry
  points, and not be imported directly into logic files
- **Respect repository configuration**: Before any edits, read and adhere to
  `package.json` (especially `type`, `scripts`, `packageManager`),
  `tsconfig.json`, `.eslintrc`, `.prettierrc`, `.editorconfig`,
  `.gitattributes`
- **No unsolicited changes**: Do not modify deps or configs unless explicitly
  tasked
- **Monorepo awareness**: Operate within the affected workspace. Respect TS
  project references and `tsc -b` where configured

### Shared Config Packages

Prefer using repo-provided shared config packages over ad-hoc per-project
configs:

- In the `job-aide` monorepo, prefer the standard config packages (where
  applicable) like `@job-aide/tools-lint-eslint-config`,
  `@job-aide/tools-platform-typescript-config`,
  `@job-aide/tools-css-config`, and `@job-aide/tools-postcss-config`.
- This is guidance, not a mandate; existing repos may already use other configs
  (e.g., XO, biome, custom ESLint).

For ESLint config composition patterns, see
[ESLint Composition API](eslint-composition-api.md).

### Agentic Stack Rules

- **Subagent import**: Avoid cross-agent leakage by having subagents import
  only from scoped modules
- **Config layers**: Must be imported explicitly, not implicitly from root
- **SSR-safe imports only**: Avoid importing runtime-only modules in static
  contexts

## Tooling Integration

### Package Management

- **Lock files**: Commit lock files for reproducible builds
- **Semantic versioning**: Follow SemVer for package versions
- **Security audits**: Regularly run `npm audit` or equivalent
- **Dependency updates**: Use tools like Renovate for automated updates
- **Package manager**: Determine the project manager based on the lockfile or
  `package.json`. If there isn't an explicit package manager defined, `bun` is
  the preferred package manager
- **Use repository scripts**: Execute via `package.json` scripts; do not call
  global binaries directly. Use the detected package manager

For pnpm workspace and Nx task orchestration conventions, see
[pnpm and Nx Monorepo](pnpm-nx-monorepo.md).

### Linting and Formatting

- **ESLint**: Configure strict rules for code quality
- **Prettier**: Use for consistent formatting
- **Husky**: Use git hooks for pre-commit checks
- **CI/CD**: Run linting and tests in pipeline

For code style specifics (double quotes, 2-space indent, semicolons,
kebab-case, `type` over `interface`, `import type`), see
[Code Style](code-style.md).

### Testing Patterns

- **Pure functions**: Write testable, side-effect-free functions
- **Dependency injection**: Pass dependencies as parameters
- **Mock external services**: Use test doubles for APIs
- **Coverage**: Aim for >80% test coverage
- **Integration testing**: Test API request/response cycles, database
  operations with test databases, and error/failure scenarios

For the standard test runner configuration, see
[Vitest Testing](vitest-testing.md).

## See Also

- [Explicit File Extensions](explicit-file-extensions.md) — `.mts`/`.cts`/`.tsx`/`.mjs`/`.cjs`/`.d.ts` usage; banned ambiguous `.ts` and `.js`
- [Path Alias Safety](path-alias-safety.md) — explicit category-based aliases instead of bare `@/*`
- [ESLint Composition API](eslint-composition-api.md) — three patterns for `@job-aide/tools-lint-eslint-config`
- [Code Style](code-style.md) — double quotes, 2-space indent, semicolons, kebab-case, `type` over `interface`, `import type`
- [pnpm and Nx Monorepo](pnpm-nx-monorepo.md) — pnpm workspaces, `workspace:*`, Nx polyglot task orchestration
- [Vitest Testing](vitest-testing.md) — `.test.mts` extension, project-based unit/integration testing
- [Package Naming Convention](package-naming-convention.md) — `packages/{active|icebox}/{category}/{platform}/{domain}/{package-name}/{language}`
- [Application Naming Convention](app-naming-convention.md) — `apps/{status}/{product-suite}/{app-name}/{platform}/{language}`
- [Monorepo Structure](monorepo-structure.md) — `active` vs `icebox`, `core`/`features`/`services`/`ui`/`tools` categories

## Sources

- Migrated from src/current/rules/software-dev/platforms/node-dev/javascript-essentials.md
- Migrated from src/current/rules/software-dev/platforms/node-dev/typescript-essentials.md
