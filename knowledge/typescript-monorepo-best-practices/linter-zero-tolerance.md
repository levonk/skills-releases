---
type: Practice
title: Linter Zero-Tolerance — max-warnings 0, No Unjustified Inline Disables
description: Enforce a zero-tolerance linting policy in CI — --max-warnings 0 so warnings are failures, inline disable comments only with documented justification, and no bulk file-level disables — so the linter is a gate, not a suggestion.
tags: [typescript, eslint, linting, zero-tolerance, max-warnings, inline-disable, ruff, clippy, golangci-lint]
date:
  created: "2026-08-10"
  knowledge-basis: "2026-08-10"
  last-used: "2026-08-10"
sources:
  - id: archon-eslint-config
    resource: https://github.com/coleam00/archon/blob/main/eslint.config.mjs
    title: 'archon eslint.config.mjs — flat config with strict type-checked rules'
  - id: archon-validate-script
    resource: https://github.com/coleam00/archon/blob/main/package.json
    title: 'archon package.json — validate script with --max-warnings 0'
  - id: archon-eslint-guidelines
    resource: https://github.com/coleam00/archon/blob/main/AGENTS.md
    title: 'archon AGENTS.md — ESLint Guidelines: zero-tolerance policy'
---

# Linter Zero-Tolerance — max-warnings 0, No Unjustified Inline Disables

## Failure Mode

A linter that runs but doesn't gate. Warnings accumulate over time — 47
warnings today, 120 next month — and nobody fixes them because "they're just
warnings." A new warning introduced by a code change is invisible in the noise.
Eventually the linter is noise itself, and developers stop reading its output.

Worse: developers disable rules inline to "make CI pass" without documenting
why. `// eslint-disable-next-line` spreads through the codebase, each instance
silently weakening the safety net. Bulk file-level disables (`/* eslint-disable */`)
turn entire files into unlinted zones.

Symptoms:

1. **Warning debt**: CI passes with 47 warnings. No one knows which are old
   and which are new. A real issue hides in the pile.
2. **Silent rule disables**: `// eslint-disable-next-line no-explicit-any`
   with no comment explaining why — the rule is off for this line forever,
   and no one knows if the reason still applies.
3. **Bulk disables**: `/* eslint-disable */` at the top of a file means the
   entire file is unlinted. New violations are invisible.
4. **"Fix later" never comes**: A disable comment says "TODO: fix this" —
   but there is no mechanism to enforce the TODO, so it becomes permanent.

## Practice

### max-warnings 0: Warnings Are Failures

Run the linter with `--max-warnings 0` in CI and in the pre-PR validation
gate. If the linter emits even one warning, the build fails. This transforms
the linter from a suggestion into a gate.

```json
{
  "scripts": {
    "lint": "eslint . --cache",
    "validate": "npm run lint -- --max-warnings 0 && npm run type-check && npm run test"
  }
}
```

### Inline Disables: Almost Never

Inline disable comments (`// eslint-disable-next-line <rule>`) are acceptable
only in two narrow situations:

1. **External SDK types are incorrect**: The SDK's type definitions are wrong,
   and you cannot fix them upstream. The disable comment must document which
   SDK and why.
2. **Intentional type assertion after validation**: You have validated the
   data at runtime (see [Type-Safe Data Interchange](type-safe-data-interchange.md))
   and the assertion is safe. The disable comment must explain the validation.

Every inline disable must include a comment on the same line (or the line
above) explaining the justification. A disable without a comment is a
violation.

**Never acceptable:**

- Disabling `no-explicit-any` without justification.
- Disabling rules to "make CI pass" — fix the code instead.
- Bulk disabling at file level (`/* eslint-disable */`).
- Disabling a rule and leaving a `TODO: fix this` with no enforcement.

### Rule Configuration: Explicit, Not Accidental

When a rule is turned off in the config, it should be off for a documented
reason (e.g. "external SDK interop requires `no-unsafe-assignment: off`"),
not because someone was silencing a warning. Group disabled rules with
comments explaining the category:

```javascript
// --- External SDK interop (types are often `any` or incomplete) ---
'@typescript-eslint/no-unsafe-assignment': 'off',
'@typescript-eslint/no-unsafe-member-access': 'off',
```

## Concrete Instances

### TypeScript / ESLint

```bash
# CI gate — zero warnings allowed
eslint . --cache --max-warnings 0
```

```javascript
// ✅ Acceptable — documented SDK type issue
// eslint-disable-next-line @typescript-eslint/no-unsafe-assignment -- Claude SDK returns any for content blocks
const content = msg.content;

// ❌ Never — no justification
// eslint-disable-next-line no-explicit-any
const data: any = response;
```

### Python / ruff

```bash
# CI gate — zero warnings, treat all as errors
ruff check . --exit-non-zero-on-fix
```

```python
# ✅ Acceptable — documented justification
# ruff: noqa: E501 -- URL in docstring cannot be wrapped without breaking clickability
# https://example.com/very/long/url/that/exceeds/line/length/limit

# ❌ Never — no justification
# ruff: noqa: F401
import unused_module
```

### Rust / clippy

```bash
# CI gate — deny warnings, treat clippy lints as errors
cargo clippy -- -D warnings
```

```rust
// ✅ Acceptable — documented justification
#[allow(clippy::needless_return)] // Required by the trait signature in external crate `serde::Serialize`
fn serialize(&self) -> String {
    return self.to_string();
}

// ❌ Never — no justification
#[allow(dead_code)]
fn unused_function() {}
```

### Go / golangci-lint

```bash
# CI gate — treat all issues as errors
golangci-lint run --max-issues-per-linter 0 --max-same-issues 0
```

```go
// ✅ Acceptable — documented justification
//nolint:errcheck // Closes() never returns an error for os.File after successful Open
defer file.Close()

// ❌ Never — no justification
//nolint:errcheck
defer db.Close()
```

## Rationale

- **Warnings are debt**: An unenforced warning is a future bug. `--max-warnings 0`
  makes the linter a gate, not a suggestion.
- **Justified disables survive review**: A disable with a comment forces the
  reviewer to evaluate the justification. A disable without a comment is
  invisible debt.
- **Cross-language consistency**: The principle (zero warnings, justified
  disables only) applies identically to ESLint, ruff, clippy, and
  golangci-lint. The tool changes; the discipline does not.

## Consequences

### Positive

- The linter is a reliable gate — if CI passes, the code is clean.
- Disable comments are rare and self-documenting.
- New warnings are caught immediately, not buried in legacy debt.

### Negative

- Initial cleanup of existing warning debt may be significant.
- Developers must justify every disable — but this friction is the point: it
  makes disabling the exception, not the default.

## Related Concepts

- [ESLint Composition API](eslint-composition-api.md) — the config layer that
  defines which rules are enforced; this page defines the enforcement policy.
- [Type-Safe Data Interchange](type-safe-data-interchange.md) — schemas
  eliminate the `any` types that would otherwise require inline disables.
- [SDK Type Patterns](sdk-type-patterns.md) — importing SDK types directly
  avoids the `no-unsafe-*` disables that external SDK interop would otherwise
  require.
