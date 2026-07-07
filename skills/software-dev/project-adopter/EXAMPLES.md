# Project Adopter Examples

## Example 1: New TypeScript Project Setup with Skill Integration

### Scenario
Creating a new Next.js application from scratch with full skill ecosystem integration.

### Before
```bash
$ ls -la
total 0
```

### After Applying Skills
```bash
# 1. Initialize project
npx create-next-app@latest my-app --typescript --tailwind --eslint
cd my-app

# 2. Apply project-adopter skill (uses project-detection internally)
# (Skill detects TypeScript and sets up everything)

# 3. Result structure with skill integration
$ ls -la
.envrc              # direnv configuration
devbox.json          # Devbox with nodejs_22, pnpm, typescript
justfile             # Standard targets
README.md            # Updated with devbox setup
LICENSE.md           # Proprietary license
AGENTS.md            # AI workflow (integrates with ai-development-loop)
docker-compose.yml
docker/
└── Dockerfile
.github/
├── workflows/
│   └── ci.yml
└── dependabot.yml
```

### Skill Integration Workflow

**Step 1: Project Detection (project-detection skill)**
```bash
# The project-adopter skill internally calls:
DETECTION_SKILL_PATH="../project-detection"
source "$DETECTION_SKILL_PATH/scripts/detect-build-systems.sh"
build_systems=$(detect_systems "$PROJECT_PATH" "false")
# Output: "pnpm typescript nextjs tailwind"
```

**Step 2: Configuration (project-adopter skill)**
```bash
# Based on detection, configures:
# - devbox.json with appropriate packages
# - justfile with standard targets
# - .envrc for direnv integration
# - AGENTS.md that references ai-development-loop
```

**Step 3: Development Loop (ai-development-loop skill)**
```bash
# After setup, follow the systematic workflow:
tkr ready                    # Step 1: Ticket selection
tkr start <ticket-id>         # Step 2: Start work
# Step 4: High Quality - check existing tests
# Step 5: Strategy - determine implementation approach
# Step 6: Implementation
# Step 7: Verification - add/update tests
# Step 8: Completion
# Step 9: Commit & Loop
```

### Scenario
Creating a new Next.js application from scratch.

### Before
```bash
$ ls -la
total 0
```

### After Applying Skill
```bash
# 1. Initialize project
npx create-next-app@latest my-app --typescript --tailwind --eslint
cd my-app

# 2. Apply project-adopter skill
# (Skill detects TypeScript and sets up everything)

# 3. Result structure
$ ls -la
.envrc          # direnv configuration
devbox.json      # Devbox with nodejs_22, pnpm, typescript
justfile         # Standard targets
README.md        # Updated with devbox setup
LICENSE.md       # Proprietary license
AGENTS.md        # AI workflow guide
docker-compose.yml
docker/
└── Dockerfile
.github/
├── workflows/
│   └── ci.yml
└── dependabot.yml
```

### Generated Files

**devbox.json**
```json
{
  "packages": [
    "just",
    "nodejs_22",
    "pnpm",
    "typescript"
  ],
  "shell": {
    "init_hook": ["just bootstrap-internal"]
  },
  "scripts": {
    "bootstrap": "just bootstrap-internal",
    "build": "just build-internal",
    "test": "just test-internal",
    "dev": "just dev-internal",
    "lint": "just lint-internal",
    "typecheck": "just typecheck-internal"
  }
}
```

**justfile**
```just
# Normal targets
clean:
    devbox shell clean

dev:
    devbox shell dev

build:
    devbox shell build

test:
    devbox shell test

lint:
    devbox shell lint

typecheck:
    devbox shell typecheck

# Bootstrap
bootstrap:
    devbox shell bootstrap

bootstrap-internal:
    pnpm install
    echo "✅ TypeScript environment ready!"

# Internal targets
build-internal:
    pnpm run build

test-internal:
    pnpm run test

dev-internal:
    pnpm run dev

lint-internal:
    pnpm run lint

typecheck-internal:
    pnpm run typecheck

clean-internal:
    rm -rf dist node_modules/.cache
```

## Example 2: Existing Rust Project Migration

### Scenario
Migrating an existing Rust CLI tool that uses Makefile and cargo.

### Before
```bash
$ ls -la
Cargo.toml
Makefile
src/
└── main.rs
README.md
.gitignore
```

**Existing Makefile**
```makefile
.PHONY: build test clean

build:
	cargo build --release

test:
	cargo test

clean:
	cargo clean
```

### After Migration
```bash
# 1. Add devbox
devbox init
devbox add rustc cargo clippy rustfmt just

# 2. Apply skill
# (Skill detects Rust and existing files)

# 3. Update configuration
direnv allow
```

### Generated Files

**devbox.json**
```json
{
  "packages": [
    "just",
    "rustc",
    "cargo",
    "clippy",
    "rustfmt"
  ],
  "shell": {
    "init_hook": ["just bootstrap-internal"]
  },
  "scripts": {
    "bootstrap": "just bootstrap-internal",
    "build": "just build-internal",
    "test": "just test-internal",
    "dev": "just dev-internal",
    "lint": "just lint-internal",
    "clean": "just clean-internal"
  }
}
```

**justfile** (replaces Makefile)
```just
# Normal targets
clean:
    devbox shell clean

dev:
    devbox shell dev

build:
    devbox shell build

test:
    devbox shell test

lint:
    devbox shell lint

# Bootstrap
bootstrap:
    devbox shell bootstrap

bootstrap-internal:
    cargo build
    echo "✅ Rust environment ready!"

# Internal targets
build-internal:
    cargo build --release

test-internal:
    cargo test

dev-internal:
    cargo run

lint-internal:
    cargo clippy

clean-internal:
    cargo clean
```

**.envrc**
```bash
# Rust Project Environment Configuration

if [[ "$DEVBOX_SHELL_ENABLED" == "1" ]]; then
    echo "🔄 Exiting existing devbox shell to prevent shell inception..."
    exit 0
fi

path_prepend() {
  local p="$1"
  if [ -d "$p" ] && [[ ":$PATH:" != *":$p:"* ]]; then
    export PATH="$p:$PATH"
  fi
}

path_append() {
  local p="$1"
  if [ -d "$p" ] && [[ ":$PATH:" != *":$p:"* ]]; then
    export PATH="$PATH:$p"
  fi
}

path_prepend "/nix/var/nix/profiles/default/bin"

if ! command -v nix >/dev/null 2>&1; then
    path_append "$HOME/.nix-profile/bin"
fi

use_devbox() {
    watch_file devbox.json
    eval "$(devbox shellenv)"
}

if command -v devbox >/dev/null 2>&1; then
    use devbox
fi

echo "🦀 Rust project environment initialized"
echo "💡 Run 'just --list' to see available commands"
```

### Migration Benefits
- Consistent with other projects
- Automatic environment setup
- Better error messages
- Cross-platform compatibility

## Example 3: Python Data Science Project

### Scenario
Setting up a new Python project for data analysis.

### Project Detection
```bash
# Skill detects Python from requirements.txt and .py files
$ find . -name "*.py" | head -5
./src/data_processing.py
./src/analysis.py
./tests/test_data.py
```

### Generated Configuration

**devbox.json**
```json
{
  "packages": [
    "just",
    "python3",
    "poetry",
    "black",
    "ruff",
    "mypy",
    "pandas",
    "numpy",
    "jupyter"
  ],
  "shell": {
    "init_hook": ["just bootstrap-internal"]
  },
  "scripts": {
    "bootstrap": "just bootstrap-internal",
    "build": "just build-internal",
    "test": "just test-internal",
    "dev": "just dev-internal",
    "lint": "just lint-internal",
    "typecheck": "just typecheck-internal",
    "notebook": "just notebook-internal"
  }
}
```

**justfile**
```just
# Normal targets
clean:
    devbox shell clean

dev:
    devbox shell dev

build:
    devbox shell build

test:
    devbox shell test

lint:
    devbox shell lint

typecheck:
    devbox shell typecheck

notebook:
    devbox shell notebook

# Bootstrap
bootstrap:
    devbox shell bootstrap

bootstrap-internal:
    poetry install
    echo "✅ Python data science environment ready!"

# Internal targets
build-internal:
    poetry build

test-internal:
    poetry run pytest

dev-internal:
    poetry run python src/main.py

lint-internal:
    poetry run ruff check
    poetry run black --check .

typecheck-internal:
    poetry run mypy src/

notebook-internal:
    poetry run jupyter notebook

clean-internal:
    rm -rf build dist .pytest_cache .coverage
```

## Example 4: Monorepo Setup

### Scenario
Setting up a monorepo with multiple packages.

### Structure
```
my-monorepo/
├── apps/
│   └── web/
├── packages/
│   ├── shared/
│   └── utils/
├── devbox.json      # Root devbox
├── justfile         # Root justfile
├── pnpm-workspace.yaml
└── turbo.json
```

### Root devbox.json
```json
{
  "packages": [
    "just",
    "nodejs_22",
    "pnpm",
    "typescript"
  ],
  "shell": {
    "init_hook": ["just bootstrap-internal"]
  },
  "scripts": {
    "bootstrap": "just bootstrap-internal",
    "build": "just build-internal",
    "test": "just test-internal",
    "dev": "just dev-internal",
    "lint": "just lint-internal",
    "typecheck": "just typecheck-internal"
  }
}
```

### Root justfile
```just
# Normal targets
clean:
    devbox shell clean

dev:
    devbox shell dev

build:
    devbox shell build

test:
    devbox shell test

lint:
    devbox shell lint

typecheck:
    devbox shell typecheck

# Bootstrap
bootstrap:
    devbox shell bootstrap

bootstrap-internal:
    pnpm install
    echo "✅ Monorepo environment ready!"

# Internal targets - use Turbo
build-internal:
    pnpm turbo run build

test-internal:
    pnpm turbo run test

dev-internal:
    pnpm turbo run dev --filter=web

lint-internal:
    pnpm turbo run lint

typecheck-internal:
    pnpm turbo run typecheck

clean-internal:
    pnpm turbo run clean
    rm -rf node_modules/.cache
```

## Example 5: Migration Complexity Assessment

### High Complexity Scenario
```bash
$ ./scripts/detect-project.sh

Project Detection Results:
===========================
Project Type: application
Main Language: typescript

Existing Configuration:
  - devbox.json: false
  - justfile: false
  - .envrc: false
  - package.json: true
  - Cargo.toml: false
  - pyproject.toml: false
  - go.mod: false

Migration Complexity:
===================
❌ High complexity - Significant migration effort
Factors affecting complexity:
  - Has Makefile (needs conversion)
  - Has npm lockfile (switch to pnpm)
  - Has existing venv (recreate with devbox)
  - Has Dockerfile (may need updates)

Quick Setup Commands:
====================
# Initialize devbox
devbox init
devbox add just nodejs_22 pnpm typescript

# Configure direnv
echo 'use devbox' > .envrc
direnv allow

# Create justfile (use project-adopter skill for full template)
touch justfile

# Bootstrap the project
just bootstrap
```

### Migration Strategy for High Complexity
1. **Phase 1**: Add devbox alongside existing tools
2. **Phase 2**: Convert Makefile to justfile
3. **Phase 3**: Switch from npm to pnpm
4. **Phase 4**: Update Docker configuration
5. **Phase 5**: Remove old tooling

## Example 6: Docker Integration

### Generated docker-compose.yml
```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: docker/Dockerfile
    volumes:
      - .:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    command: just dev-internal

  # Add database if needed
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### Generated docker/Dockerfile
```dockerfile
# Multi-stage build for TypeScript project
FROM node:22-alpine as builder

# Install devbox and dependencies
RUN apk add --no-cache curl
RUN curl -L https://nixos.org/nix/install | sh
RUN nix profile install nixpkgs#devbox nixpkgs#nodejs_22 nixpkgs#pnpm

WORKDIR /app
COPY devbox.json pnpm-lock.json package*.json ./
RUN devbox shell -- pnpm install --frozen-lockfile

COPY . .
RUN devbox shell -- pnpm run build

# Production stage
FROM node:22-alpine as runtime
WORKDIR /app

# Copy built application
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

# Use non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001
USER nodejs

CMD ["node", "dist/index.js"]
```

## Example 7: CI/CD Integration

### Generated .github/workflows/ci.yml
```yaml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Devbox
        uses: jetify-com/devbox-action@v0.10.0

      - name: Bootstrap project
        run: just bootstrap-internal

      - name: Run typecheck
        run: just typecheck-internal

      - name: Run linting
        run: just lint-internal

      - name: Run tests
        run: just test-internal

      - name: Build project
        run: just build-internal

  security:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Devbox
        uses: jetify-com/devbox-action@v0.10.0

      - name: Run security scan
        run: |
          just bootstrap-internal
          # Add security scanning tools here
          # npm audit, snyk, etc.
```

### Generated .github/dependabot.yml
```yaml
version: 2
updates:
  # Node.js dependencies
  - package-ecosystem: npm
    directory: "/"
    schedule:
      interval: weekly
    open-pull-requests-limit: 5

  # Rust dependencies
  - package-ecosystem: cargo
    directory: "/"
    schedule:
      interval: weekly
    open-pull-requests-limit: 5

  # Python dependencies
  - package-ecosystem: pip
    directory: "/"
    schedule:
      interval: weekly
    open-pull-requests-limit: 5

  # Docker base images
  - package-ecosystem: docker
    directory: "/"
    schedule:
      interval: weekly
    open-pull-requests-limit: 3
```

## Example 8: Quality Gates

### Automated Quality Check
```bash
# Run full quality check
just quality

# Equivalent to:
just lint-internal && just test-internal && just typecheck-internal
```

### Pre-commit Hook Setup
```bash
# .git/hooks/pre-commit
#!/bin/bash
set -e

echo "Running quality checks..."

# Ensure we're in devbox environment
if [[ -z "$DEVBOX_SHELL_ENABLED" ]]; then
    echo "❌ Not in devbox environment. Run 'direnv allow' first."
    exit 1
fi

# Run quality checks
just lint-internal
just test-internal
just typecheck-internal

echo "✅ All quality checks passed!"
```

## Example 9: Troubleshooting Common Issues

### Issue: Devbox not found
```bash
# Error: command not found: devbox
# Solution:
curl -L https://nixos.org/nix/install | sh
nix profile install nixpkgs#devbox
```

### Issue: direnv not working
```bash
# Error: direnv: error
# Solution:
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
source ~/.bashrc
direnv allow
```

### Issue: Permission denied on .envrc
```bash
# Error: permission denied
# Solution:
direnv allow
```

### Issue: just command not found
```bash
# Error: command not found: just
# Solution:
devbox add just
# Or install globally:
cargo install just
```

## Example 10: Custom Project Types

### Custom Language Detection
The skill can be extended for custom project types by adding detection logic:

```bash
# In detect-project.sh
detect_custom_language() {
    # Check for custom framework files
    if [[ -f "elixir_mix.exs" ]]; then
        MAIN_LANGUAGE="elixir"
    elif [[ -f "Cargo.toml" ]] && grep -q "wasm" Cargo.toml; then
        MAIN_LANGUAGE="rust-wasm"
    elif [[ -f "setup.py" ]]; then
        MAIN_LANGUAGE="python-legacy"
    fi
}
```

### Custom Devbox Packages
```json
{
  "packages": [
    "just",
    "elixir",
    "erlang"
  ],
  "shell": {
    "init_hook": ["just bootstrap-internal"]
  }
}
```

These examples demonstrate how the project-adopter skill handles various scenarios and project types, providing consistent developer experience across all projects.
