
# Developer Guide: {project name}

This guide is for developers working on the codebase. For user-facing setup and project overview, see the root [`AGENTS.md`](../../AGENTS.md).

## JIT Index
- Out of Scope: [`internal-docs/oos/`](../../internal-docs/oos/) - What this repo explicitly does NOT do (check before adding features)
- Improvements: [`internal-docs/improvements/INDEX.md`](../../internal-docs/improvements/INDEX.md) - Potential improvements to consider (check before proposing changes to avoid re-proposing already-evaluated improvements)
- Anti-Patterns: [`internal-docs/anti-patterns/INDEX.md`](../../internal-docs/anti-patterns/INDEX.md) - Things explicitly NOT to do (check before implementing changes to avoid re-introducing known-bad approaches)

## <commands>
**Devbox Commands (Environment)**
- `devbox run -- <command>` - Run single command in devbox environment
- `devbox add <package>` - Add package to devbox environment
</commands>

## <workflow>
**AI Agent Workflow (Fresh Shell)**
1. Enter project directory: `cd /path/to/project`
2. Activate direnv: `direnv allow && source .envrc`
3. Bootstrap environment: `devbox run -- just bootstrap-internal`
4. Create `feature/{feature-name}`, `fix/{issue-name}`, or `chore/{task-name}` branch from `main`
5. Write failing test first (TDD)
6. Implement feature
7. Run quality gates: `devbox run -- just test-internal && devbox run -- just lint-internal`
8. Fix any failing tests or lint issues
9. Commit changes with conventional commit message
10. Rebase on `main` if diverged
11. Open PR with description

**Testing in /tmp (for boilerplate/features)**
1. Materialize project to `/tmp`: `cd /tmp && copier copy <boilerplate-path> test-project`
2. `cd test-project && direnv allow && source .envrc`
3. `devbox run -- just bootstrap-internal`
4. `devbox run -- just test-internal`
5. Clean up: `rm -rf /tmp/test-project`
</workflow>

## <key-directories>
- `apps/active/` - Working applications
- `apps/icebox/` - Prototype applications
- `packages/active/` - Working packages
- `packages/icebox/` - Prototype packages
- `boilerplates/` - Project templates for copier
- `internal-docs/` - ADRs, architecture documentation
- `scripts/` - Deterministic scripts and workflows
- `.devbox/` - Devbox environment configuration
- `justfile` - Command runner recipes (root and per-project)
- This is a monorepo using NX for build orchestration
- [Add DDD or architectural pattern if applicable]
</key-directories>

## <key-files>
**Core Configuration**
- `justfile` - Command runner recipes (normal + *-internal targets)
- `devbox.json` - Devbox environment configuration
- `.envrc` - direnv configuration for auto-activation
- `nx.json` - NX workspace configuration
- `package.json` - pnpm workspace configuration
- `pnpm-workspace.yaml` - pnpm workspace definition

**Documentation**
- `AGENTS.md` - Comprehensive agent documentation (PRIMARY)
- `README.md` - Project overview and quick start
- `internal-docs/adr/` - Architecture Decision Records

**Fallback Rules**
- `${XDG_CONFIG_HOME:-$HOME/.config}/ai/rules/rules.md` - Fallback rules if not specified here
</key-files>

## <patterns>
describe your code style and patterns (✅ DO / ❌ DON'T examples)
</patterns>

## <boundaries>
### <always>
- Run tests before committing
- Use TypeScript strict mode for TS projects
- Use `devbox run -- just <command>` for AI agents (fresh shell)
- Never use `npm` directly, use `pnpm`
- Follow TDD: write failing tests first, then implement
- All features must include comprehensive tests
- All bug fixes must include regression tests
- Activate direnv on first entry: `direnv allow && source .envrc`
</always>
### <ask-first>
- Changes to `/migrations`
- Modifying public APIs
- Reducing functionality without explicit request
- Changing architecture
- Adding new packages (check existing packages first)
- Creating new boilerplates (check existing patterns)
</ask-first>
### <never>
- Commit secrets or credentials
- Delete tests
- Modify vendor directory
- Use `npm` directly
- Skip testing for any change
- Make bandaids - fix root causes
- Use direct nx commands (use just instead)
</never>
</boundaries>

## <known-gotchas>
- **Fresh shell**: AI agents get fresh shells, always use `devbox run -- just <command>` to ensure environment is active
- **Justfile pattern**: Normal targets call `devbox run`, internal targets (ending in `-internal`) contain actual implementation
- **Use just to run nx**: Avoid use of nx directly, always use `just build-internal`, `just test-internal`, etc.
- **pnpm only**: Never use `npm` or `yarn` - `pnpm` is only choice for node package management
- **Testing is mandatory**: All changes require tests before completion - no exceptions
</known-gotchas>

## Definition of Done
- [ ] Tests pass: `devbox run -- just test-internal`
- [ ] Lint passes: `devbox run -- just lint-internal`
- [ ] Typecheck passes: `devbox run -- just typecheck-internal`
- [ ] No secrets or credentials committed
- [ ] Conventional commit message used
- [ ] PR describes the "why" not just the "what"
- [ ] Rebased on `main` if diverged
- [ ] Affected AGENTS.md files updated per Maintenance Protocol
