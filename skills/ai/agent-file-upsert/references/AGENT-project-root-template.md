
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

## Knowledge Bundles

Canonical practice bundles from [levonk/skills-releases](https://github.com/levonk/skills-releases/knowledge) are copied into [`.agents/knowledge/bundles/`](.agents/knowledge/bundles/) for offline agent access. Domain-specific bundles are URL-referenced and fetched on demand only when the task touches that domain.

### Installed (offline-ready)

| Bundle | Applies when |
|--------|--------------|
| [software-architecture-essentials](.agents/knowledge/bundles/software-architecture-essentials/) | Universal — any project |
| [dev-environment-practices](.agents/knowledge/bundles/dev-environment-practices/) | Universal — any project |
| [devsecops-codeguard](.agents/knowledge/bundles/devsecops-codeguard/) | Universal — any project |
| [cicd-testing-practices](.agents/knowledge/bundles/cicd-testing-practices/) | Universal — any project |
| [build-system-essentials](.agents/knowledge/bundles/build-system-essentials/) | Universal — any project |
| [typescript-monorepo-best-practices](.agents/knowledge/bundles/typescript-monorepo-best-practices/) | TypeScript / Node.js detected |
| [rust-development-practices](.agents/knowledge/bundles/rust-development-practices/) | Rust detected |
| [python-services-practices](.agents/knowledge/bundles/python-services-practices/) | Python detected |
| [java-best-practices](.agents/knowledge/bundles/java-best-practices/) | Java detected |
| [frontend-stack-practices](.agents/knowledge/bundles/frontend-stack-practices/) | Frontend web detected |
| [nix-build-practices](.agents/knowledge/bundles/nix-build-practices/) | Nix-heavy build detected |
| [container-best-practices](.agents/knowledge/bundles/container-best-practices/) | Docker / Kubernetes detected |
| [data-engineering-best-practices](.agents/knowledge/bundles/data-engineering-best-practices/) | Data pipelines detected |

### URL-referenced (fetched on demand)

| Bundle | Read when working on… |
|--------|-----------------------|
| [api-auth-payment-practices](https://github.com/levonk/skills-releases/knowledge/api-auth-payment-practices) | Auth, payments, billing |
| [infrastructure-networking-practices](https://github.com/levonk/skills-releases/knowledge/infrastructure-networking-practices) | Network topology, VPN, DNS |
| [secrets-egress-security](https://github.com/levonk/skills-releases/knowledge/secrets-egress-security) | Secrets management, egress firewalls |
| [cloud-provider-essentials](https://github.com/levonk/skills-releases/knowledge/cloud-provider-essentials) | AWS / Azure / GCP / OCI |
| [web-resource-catalog](https://github.com/levonk/skills-releases/knowledge/web-resource-catalog) | UI components, stock media, color palettes |
| [upstream-contribution-practices](https://github.com/levonk/skills-releases/knowledge/upstream-contribution-practices) | Contributing to upstream OSS |
| [ai-primitives](https://github.com/levonk/skills-releases/knowledge/ai-primitives) | AI tooling, prompt engineering |

**Installation**: Run `uv run --script scripts/install-knowledge-bundles.py <project-root>` (from the `project-adopter` skill) to populate `.agents/knowledge/bundles/`. Universal bundles install by default; pass `--bundles <name1>,<name2>` for stack-matched bundles.

## Out of Scope
For information about what this repo does NOT do, see [`internal-docs/oos/`](internal-docs/oos/).

## Improvements
For potential improvements to architecture, standards, and processes, see [`internal-docs/improvements/INDEX.md`](internal-docs/improvements/INDEX.md). These are suggestions to consider — not decisions yet. Check before proposing changes to avoid re-proposing already-evaluated improvements.

## Anti-Patterns
For things explicitly NOT to do (practices found harmful or inferior), see [`internal-docs/anti-patterns/INDEX.md`](internal-docs/anti-patterns/INDEX.md). These are negative findings — do NOT implement any approach listed there.

## Universal Contracts
- Use `devbox run -- just <command>` for AI agents (fresh shell)
- Use `pnpm` for JavaScript/TypeScript packages (never `npm`)

## Developer Guide
For workflows, repository structure, code style, boundaries, known gotchas, and the Definition of Done checklist, see [`.agents/knowledge/developer.md`](.agents/knowledge/developer.md).
