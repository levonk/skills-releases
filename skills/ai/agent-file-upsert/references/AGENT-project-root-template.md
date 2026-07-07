
# {project name}

## Project Snapshot
- Type: [Monorepo/Polyrepo]
- Stack: [Tech]

## <purpose>
2-3 sentences what it does and who it's for.
</purpose>

## Setup

**Environment Activation (Fresh Shell)**
```bash
# 1. Enter project directory
cd /path/to/project

# 2. Bootstrap environment
devbox run -- just bootstrap-internal

# 3. Verify environment
devbox run -- just doctor-internal
```

**Build Commands (via just)**
- Build: `devbox run -- just build-internal`
- Test: `devbox run -- just test-internal`
- Lint: `devbox run -- just lint-internal`
- Typecheck: `devbox run -- just typecheck-internal`
- Dev: `devbox run -- just dev-internal`
- Bootstrap: `devbox run -- just bootstrap-internal`
- Prime: `devbox run -- just prime-internal`
- Doctor: `devbox run -- just doctor-internal`

**Note**: AI agents get fresh shells, so always use `devbox run -- just <command>` to ensure environment is active.

## <tech-stack>
- devbox:latest - Reproducible development environment
- direnv:latest - Automatic environment activation
- just:latest - Command runner for development tasks
- nx:latest - Monorepo build orchestration and caching
- pnpm:latest - JavaScript/TypeScript package manager
- nodejs:22 - JavaScript runtime 
- typescript:5 - TypeScript compiler 
- [other languages with versions]
</tech-stack>

## JIT Index
- Web: `apps/web/` -> [Guide](apps/web/AGENTS.md)
- API: `apps/api/` -> [Guide](apps/api/AGENTS.md)
- Developer Guide: [`.agents/knowledge/developer.md`](.agents/knowledge/developer.md) - Workflows, repo structure, code style, boundaries, and PR checklist for developers working on this project

## Out of Scope
For information about what this repo does NOT do, see [`internal-docs/oos/`](internal-docs/oos/).

## Universal Contracts
- Use `devbox run -- just <command>` for AI agents (fresh shell)
- Use `pnpm` for JavaScript/TypeScript packages (never `npm`)

## Developer Guide
For workflows, repository structure, code style, boundaries, known gotchas, and the Definition of Done checklist, see [`.agents/knowledge/developer.md`](.agents/knowledge/developer.md).
