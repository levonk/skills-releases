#!/bin/bash

# Project Adopter Script
# Uses project-detection and surgical-config skills for intelligent project adoption

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Loop prevention
readonly PROJECT_ADOPTER_LOCK_FILE="/tmp/.project-adopter.lock"
readonly SURGICAL_CONFIG_LOCK_FILE="/tmp/.surgical-config.lock"
LOOP_DETECTION_ENABLED=true

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check for potential infinite loops
check_for_loops() {
    if [[ "$LOOP_DETECTION_ENABLED" != "true" ]]; then
        return 0
    fi

    # Skip loop detection if forced
    if [[ "${FORCE_ADOPTION:-}" == "true" ]]; then
        log_info "Force adoption enabled - skipping loop prevention"
        return 0
    fi

    # Check if project-adopter is already running
    if [[ -f "$PROJECT_ADOPTER_LOCK_FILE" ]]; then
        local adopter_pid
        adopter_pid=$(cat "$PROJECT_ADOPTER_LOCK_FILE" 2>/dev/null || echo "")
        if [[ -n "$adopter_pid" ]] && kill -0 "$adopter_pid" 2>/dev/null; then
            log_warn "Project-adopter is already running (PID: $adopter_pid)"
            log_warn "Avoiding potential infinite loop - exiting"
            exit 1
        else
            # Stale lock file, remove it
            rm -f "$PROJECT_ADOPTER_LOCK_FILE"
        fi
    fi

    # Check if surgical-config is already running (might indicate nested call)
    if [[ -f "$SURGICAL_CONFIG_LOCK_FILE" ]]; then
        local surgical_pid
        surgical_pid=$(cat "$SURGICAL_CONFIG_LOCK_FILE" 2>/dev/null || echo "")
        if [[ -n "$surgical_pid" ]] && kill -0 "$surgical_pid" 2>/dev/null; then
            # Check if this is a nested call from the same process tree
            local current_ppid
            current_ppid=$(ps -o ppid= -p $$ 2>/dev/null | tr -d ' ')
            local surgical_ppid
            surgical_ppid=$(ps -o ppid= -p "$surgical_pid" 2>/dev/null | tr -d ' ' || echo "")

            if [[ "$current_ppid" == "$surgical_ppid" ]] || [[ "$current_ppid" == "$surgical_pid" ]]; then
                log_warn "Nested call detected - surgical-config is running from same process tree"
                log_warn "Avoiding potential infinite loop - exiting"
                exit 1
            fi
        else
            # Stale lock file, remove it
            rm -f "$SURGICAL_CONFIG_LOCK_FILE"
        fi
    fi

    return 0
}

# Create lock file for this process
create_lock_file() {
    if [[ "$LOOP_DETECTION_ENABLED" != "true" ]]; then
        return 0
    fi

    echo $$ > "$PROJECT_ADOPTER_LOCK_FILE"
    # Set up cleanup on exit
    trap 'rm -f "$PROJECT_ADOPTER_LOCK_FILE"' EXIT
}

# Check if we're being called by another project-adopter instance
check_caller() {
    if [[ "$LOOP_DETECTION_ENABLED" != "true" ]]; then
        return 0
    fi

    # Skip caller check if forced
    if [[ "${FORCE_ADOPTION:-}" == "true" ]]; then
        log_info "Force adoption enabled - skipping caller check"
        return 0
    fi

    local parent_process
    parent_process=$(ps -o comm= -p $(ps -o ppid= -p $$ | tr -d ' ') 2>/dev/null || echo "")

    # Check if parent process looks like project-adopter
    if [[ "$parent_process" == *"adopt-project"* ]] || [[ "$parent_process" == *"project-adopter"* ]]; then
        log_warn "Called by another project-adopter process: $parent_process"
        log_warn "Avoiding potential infinite loop - exiting"
        exit 1
    fi

    # Check environment variables that might indicate recursive call
    if [[ -n "${PROJECT_ADOPTER_RUNNING:-}" ]] || [[ -n "${ADOPTER_MODE:-}" ]]; then
        log_warn "Running in project-adopter context (detected from environment)"
        log_warn "Avoiding potential infinite loop - exiting"
        exit 1
    fi

    return 0
}

# Set project path
PROJECT_PATH="${1:-.}"
PROJECT_NAME="${2:-$(basename "$PROJECT_PATH")}"

# Skill paths (auto-detect context)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(dirname "$SCRIPT_DIR")"

# Determine context and set skill paths
determine_context() {
    if [[ "$SCRIPT_DIR" == *".chezmoitemplates"* ]]; then
        echo "chezmoi-templates:$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
    elif [[ "$SCRIPT_DIR" == *"/.config/ai/skills/"* ]]; then
        echo "deployed-config:$(dirname "$(dirname "$SCRIPT_DIR")")"
    elif [[ "$SCRIPT_DIR" == *"/skills/"* ]] && [[ "$SCRIPT_DIR" != *".config"* ]]; then
        echo "ai-tools:$(dirname "$SCRIPT_DIR")"
    else
        echo "default:$(dirname "$SCRIPT_DIR")"
    fi
}

# Get skill paths based on context
get_skill_paths() {
    local context_info
    context_info=$(determine_context)
    local context_type="${context_info%%:*}"
    local base_path="${context_info##*:}"

    case "$context_type" in
        "chezmoi-templates")
            echo "$base_path/project-detection/scripts"
            echo "$base_path/surgical-config/scripts"
            ;;
        "deployed-config")
            echo "$base_path/project-detection/scripts"
            echo "$base_path/surgical-config/scripts"
            ;;
        "ai-tools")
            echo "$base_path/project-detection/scripts"
            echo "$base_path/surgical-config/scripts"
            ;;
        *)
            echo "$base_path/../project-detection/scripts"
            echo "$base_path/../surgical-config/scripts"
            ;;
    esac
}

# Load project detection functions
load_project_detection() {
    local skill_paths
    readarray -t skill_paths < <(get_skill_paths)
    local detection_path="${skill_paths[0]}"

    if [[ -f "$detection_path/detect-build-systems.sh" ]]; then
        source "$detection_path/detect-build-systems.sh"
        source "$detection_path/detect-ci-cd-systems.sh"
        source "$detection_path/detect-workspace-configs.sh"
        log_info "✓ Project detection functions loaded from: $detection_path"
        return 0
    else
        log_error "Project detection scripts not found at: $detection_path"
        return 1
    fi
}

# Load surgical-config functions
load_surgical_config() {
    local skill_paths
    readarray -t skill_paths < <(get_skill_paths)
    local surgical_path="${skill_paths[1]}"

    if [[ -f "$surgical_path/surgical-edit.sh" ]]; then
        SURGICAL_EDIT="$surgical_path/surgical-edit.sh"
        SURGICAL_ENV="$surgical_path/ensure-environment.sh"
        log_info "✓ Surgical config functions found at: $surgical_path"
        return 0
    else
        log_error "Surgical config scripts not found at: $surgical_path"
        return 1
    fi
}

# Detect project characteristics
detect_project() {
    log_step "Detecting project characteristics..."

    # Detect build systems
    local build_systems
    build_systems=$(detect_systems "$PROJECT_PATH" "false")
    log_info "Detected build systems: $build_systems"

    # Detect CI/CD systems
    local ci_cd_systems
    ci_cd_systems=$(detect_ci_cd_systems "$PROJECT_PATH" "false")
    log_info "Detected CI/CD systems: $ci_cd_systems"

    # Detect workspace configurations
    local workspace_configs
    workspace_configs=$(analyze_workspace_configs "$PROJECT_PATH" "$PROJECT_NAME" "false")
    log_info "Workspace configs: $workspace_configs"

    echo "$build_systems|$ci_cd_systems|$workspace_configs"
}

# Detect languages in project and apply per-language configurations
apply_surgical_configs() {
    local detected_characteristics="$1"

    log_step "Applying per-language configuration updates..."

    # Parse characteristics to get build systems, app type, and project type
    parse_project_characteristics "$detected_characteristics"

    # Detect languages based on build systems
    local detected_languages=""
    if echo "$DETECTED_BUILD_SYSTEMS" | grep -q "npm\|pnpm\|yarn\|bun"; then
        detected_languages="$detected_languages nodejs"
    fi
    if echo "$DETECTED_BUILD_SYSTEMS" | grep -q "cargo\|rust"; then
        detected_languages="$detected_languages rust"
    fi
    if echo "$DETECTED_BUILD_SYSTEMS" | grep -q "poetry\|python\|pip"; then
        detected_languages="$detected_languages python"
    fi
    if echo "$DETECTED_BUILD_SYSTEMS" | grep -q "go\|golang"; then
        detected_languages="$detected_languages go"
    fi
    if echo "$DETECTED_BUILD_SYSTEMS" | grep -q "maven\|gradle"; then
        detected_languages="$detected_languages java"
    fi

    log_info "Detected languages: $detected_languages"

    # Load per-language configuration scripts
    load_language_config_scripts

    # Configure each detected language
    for lang in $detected_languages; do
        case "$lang" in
            "nodejs")
                configure_nodejs_language "$PROJECT_PATH" "$ADOPTION_MODE" "$DETECTED_APP_TYPE" "$DETECTED_PROJECT_TYPE"
                ;;
            "rust")
                configure_rust_language "$PROJECT_PATH" "$ADOPTION_MODE" "$DETECTED_APP_TYPE" "$DETECTED_PROJECT_TYPE"
                ;;
            "python")
                configure_python_language "$PROJECT_PATH" "$ADOPTION_MODE" "$DETECTED_APP_TYPE" "$DETECTED_PROJECT_TYPE"
                ;;
            "go")
                configure_go_language "$PROJECT_PATH" "$ADOPTION_MODE" "$DETECTED_APP_TYPE" "$DETECTED_PROJECT_TYPE"
                ;;
            "java")
                configure_java_language "$PROJECT_PATH" "$ADOPTION_MODE" "$DETECTED_APP_TYPE" "$DETECTED_PROJECT_TYPE"
                ;;
            *)
                log_warn "Unknown language: $lang"
                ;;
        esac
    done

    # If no languages detected, use generic configuration
    if [[ -z "$detected_languages" ]]; then
        log_info "No specific languages detected, using generic configuration"
        configure_generic_language "$PROJECT_PATH" "$ADOPTION_MODE" "$DETECTED_APP_TYPE" "$DETECTED_PROJECT_TYPE"
    fi
}

# Load per-language configuration scripts
load_language_config_scripts() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Source language configuration scripts
    for script in "$script_dir"/configure-*.sh; do
        if [[ -f "$script" ]]; then
            # shellcheck source=/dev/null
            source "$script"
            log_info "✓ Loaded $(basename "$script")"
        fi
    done
}

# Configure Node.js project using per-language script
configure_nodejs_language() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring Node.js project with per-language script..."

    if command -v configure_nodejs_project >/dev/null 2>&1; then
        configure_nodejs_project "$project_path" "$mode" "$app_type" "$project_type"
        log_info "✓ Node.js project configured"
    else
        log_warn "Node.js configuration function not available"
    fi
}

# Configure Rust project using per-language script
configure_rust_language() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring Rust project with per-language script..."

    if command -v configure_rust_project >/dev/null 2>&1; then
        configure_rust_project "$project_path" "$mode" "$app_type" "$project_type"
        log_info "✓ Rust project configured"
    else
        log_warn "Rust configuration function not available"
    fi
}

# Configure Python project using per-language script
configure_python_language() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring Python project with per-language script..."

    if command -v configure_python_project >/dev/null 2>&1; then
        configure_python_project "$project_path" "$mode" "$app_type" "$project_type"
        log_info "✓ Python project configured"
    else
        log_warn "Python configuration function not available"
    fi
}

# Configure Go project using per-language script
configure_go_language() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring Go project with per-language script..."

    if command -v configure_go_project >/dev/null 2>&1; then
        configure_go_project "$project_path" "$mode" "$app_type" "$project_type"
        log_info "✓ Go project configured"
    else
        log_warn "Go configuration function not available"
    fi
}

# Configure Java project using per-language script
configure_java_language() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring Java project with per-language script..."

    if command -v configure_java_project >/dev/null 2>&1; then
        configure_java_project "$project_path" "$mode" "$app_type" "$project_type"
        log_info "✓ Java project configured"
    else
        log_warn "Java configuration function not available"
    fi
}

# Configure generic project using per-language script
configure_generic_language() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring generic project with per-language script..."

    if command -v configure_generic_project >/dev/null 2>&1; then
        configure_generic_project "$project_path" "$mode" "$app_type" "$project_type"
        log_info "✓ Generic project configured"
    else
        log_warn "Generic configuration function not available"
    fi
}

# Create/update configuration files
create_config_files() {
    local detected_characteristics="$1"

    log_step "Creating/updating configuration files..."

    # Parse characteristics for use in configuration generation
    parse_project_characteristics "$detected_characteristics"

    # Create/update .envrc
    if [[ ! -f "$PROJECT_PATH/.envrc" ]]; then
        log_info "Creating .envrc..."
        cat > "$PROJECT_PATH/.envrc" << 'EOF'
# Project Environment Configuration

# Use devbox if available
if command -v devbox >/dev/null 2>&1; then
    eval "$(devbox shellenv)"
fi

# Project-specific environment
export PROJECT_NAME="$(basename "$PWD)"
export PROJECT_PATH="$PWD"

# Watch for changes
watch_file devbox.json
watch_file package.json
watch_file Cargo.toml
watch_file pyproject.toml
watch_file go.mod
EOF
        log_info "✓ .envrc created"
    fi

    # Create/update devbox.json
    if [[ ! -f "$PROJECT_PATH/devbox.json" ]]; then
        log_info "Creating devbox.json with language-specific packages..."
        # Detect project characteristics for devbox.json generation
        local detection_script="../../project-detection/scripts/detect-build-systems.sh"
        local detected_characteristics=""
        if [[ -f "$detection_script" ]]; then
            detected_characteristics=$("$detection_script" -t characteristics "$PROJECT_PATH" 2>/dev/null || echo "")
        fi
        generate_devbox_json "$PROJECT_PATH" "$detected_characteristics"
    else
        log_info "devbox.json already exists, skipping creation"
    fi

    # Create/update justfile with integrated generation
    if [[ ! -f "$PROJECT_PATH/justfile" ]]; then
        log_info "Creating integrated justfile with devbox support..."
        # Detect project characteristics for justfile generation
        local detection_script="../../project-detection/scripts/detect-build-systems.sh"
        local detected_characteristics=""
        if [[ -f "$detection_script" ]]; then
            detected_characteristics=$("$detection_script" -t characteristics "$PROJECT_PATH" 2>/dev/null || echo "")
        fi
        parse_project_characteristics "$detected_characteristics"
        generate_project_justfile "$PROJECT_PATH"
    else
        log_info "justfile already exists, skipping creation"
    fi

    # Create/update AGENTS.md FIRST so readme-upsert can link to it and
    # verify_consistency.py can check README<->AGENTS.md agreement.
    # README.md generation is delegated to the readme-upsert skill — do NOT
    # hand-write README content here. The orchestrating AI agent should run,
    # after AGENTS.md is in place:
    #   <readme-upsert>/SKILL.md workflow (Phase 1: analyze, Phase 2: generate
    #     from references/README-project-root-template.md.tmpl, Phase 3: upsert,
    #     Phase 4: cross-reference check, Phase 5: verify_consistency.py)
    # See SKILL.md -> "Repository & Ignore File Management" for the full contract.
    if [[ ! -f "$PROJECT_PATH/AGENTS.md" ]]; then
        log_info "Creating AGENTS.md with AI agent configuration..."
        # Detect project characteristics for AGENTS.md generation
        local detection_script="../../project-detection/scripts/detect-build-systems.sh"
        local detected_characteristics=""
        if [[ -f "$detection_script" ]]; then
            detected_characteristics=$("$detection_script" -t characteristics "$PROJECT_PATH" 2>/dev/null || echo "")
        fi
        parse_project_characteristics "$detected_characteristics"
        generate_agents_md "$PROJECT_PATH" "$detected_characteristics"
    else
        log_info "AGENTS.md already exists, skipping creation"
    fi

    # README.md generation is delegated to the readme-upsert skill.
    # Do NOT hand-write README content here — that duplicates readme-upsert's
    # template (references/README-project-root-template.md.tmpl), required-
    # sections list, and verify_consistency.py checks (README<->AGENTS.md
    # name match, no content duplication, no wrong sections in either file).
    # The orchestrating AI agent should invoke readme-upsert after AGENTS.md
    # is in place. See SKILL.md -> "Repository & Ignore File Management".
    if [[ ! -f "$PROJECT_PATH/README.md" ]] || [[ ! -s "$PROJECT_PATH/README.md" ]]; then
        log_info "ℹ README.md absent — will be generated by readme-upsert (delegated; see SKILL.md)"
    else
        log_info "ℹ README.md present — run readme-upsert to preserve accurate sections and update stale ones (delegated; see SKILL.md)"
    fi
}

# Generate justfile based on detected project type
generate_project_justfile() {
    local project_path="${1:-.}"

    log_info "Generating justfile for project: $project_path"

    # Change to project directory
    cd "$project_path" || {
        log_error "Failed to change to directory: $project_path"
        return 1
    }

    # First try to extract from existing configurations
    local extraction_script="../../project-detection/scripts/extract-build-targets.sh"
    if [[ -f "$extraction_script" ]]; then
        log_info "Attempting to extract targets from existing configurations..."
        if "$extraction_script" generate "$project_path" justfile 2>/dev/null; then
            log_info "✓ Generated justfile from existing configurations"
            return 0
        else
            log_warn "Could not extract from existing configs, falling back to integrated generation"
        fi
    fi

    # Fallback to integrated generation with devbox support
    local detection_script="../../project-detection/scripts/detect-build-systems.sh"
    if [[ ! -f "$detection_script" ]]; then
        log_error "Project detection script not found: $detection_script"
        return 1
    fi

    # Detect build systems
    local detected_systems
    detected_systems=$("$detection_script" "$project_path" --verbose 2>/dev/null || echo "")

    if [[ -z "$detected_systems" ]]; then
        log_warn "No build systems detected, creating generic justfile"
        create_generic_justfile
        return 0
    fi

    log_info "Detected systems: $detected_systems"

    # Generate integrated devbox.json + justfile setup
    generate_devbox_json "$project_path" "$detected_systems"
    generate_integrated_justfile "$project_path" "$detected_systems"

    log_info "✓ Generated integrated devbox.json + justfile with language-specific targets"
}

# Create Node.js justfile
create_nodejs_justfile() {
    local systems="$1"
    local pkg_manager="npm"

    # Determine package manager priority
    if echo "$systems" | grep -q "pnpm"; then
        pkg_manager="pnpm"
    elif echo "$systems" | grep -q "yarn"; then
        pkg_manager="yarn"
    elif echo "$systems" | grep -q "bun"; then
        pkg_manager="bun"
    fi

    log_info "Creating Node.js justfile with $pkg_manager"

    cat > justfile << EOF
# Node.js development targets
# Package manager: $pkg_manager

default:
    @just --list

# Install dependencies
install:
    $pkg_manager install

# Clean dependencies and artifacts
clean:
    rm -rf node_modules/
    rm -rf dist/
    rm -rf .nuxt/
    rm -rf .next/
    rm -rf .vite/
    rm -rf .turbo/

# Development server
dev:
    $pkg_manager run dev

# Build project
build:
    $pkg_manager run build

# Run tests
test:
    $pkg_manager test

# Run tests with coverage
test-coverage:
    $pkg_manager run test:coverage || $pkg_manager run test --coverage

# Run linting
lint:
    $pkg_manager run lint

# Run linting and fix
lint-fix:
    $pkg_manager run lint:fix || $pkg_manager run lint --fix

# Type checking
typecheck:
    $pkg_manager run typecheck || $pkg_manager run tsc --noEmit

# Format code
format:
    $pkg_manager run format || $pkg_manager run prettier --write .

# Security audit
audit:
    $pkg_manager audit || $pkg_manager audit --audit-level moderate

# Update dependencies
update:
    $pkg_manager update

# Bootstrap project
bootstrap:
    @just install
    @echo "Node.js project bootstrapped!"

# Development loop - fails fast if any step fails
loop: || (install build lint test dev)

# Complete CI pipeline
ci: || (install lint typecheck test build)

# E2E tests (if Playwright is available)
e2e:
    pnpm exec playwright test || echo "Playwright not configured"

EOF
    log_info "✓ Node.js justfile created"
}

# Create Rust justfile
create_rust_justfile() {
    local systems="$1"

    log_info "Creating Rust justfile"

    cat > justfile << EOF
# Rust development targets

default:
    @just --list

# Install dependencies
install:
    cargo build

# Clean build artifacts
clean:
    cargo clean

# Development build
dev:
    cargo build

# Release build
build:
    cargo build --release

# Run tests
test:
    cargo test

# Run tests with coverage
test-coverage:
    cargo tarpaulin --out Html || cargo test

# Run linting
lint:
    cargo clippy -- -D warnings

# Format code
format:
    cargo fmt

# Type checking (already done by cargo check)
typecheck:
    cargo check

# Run application
run:
    cargo run

# Bootstrap project
bootstrap:
    @just install
    @echo "Rust project bootstrapped!"

# Development loop - fails fast if any step fails
loop: || (install lint test build)

# Complete CI pipeline
ci: || (install lint typecheck test build)

# Security audit
audit:
    cargo audit || echo "cargo-audit not installed"

# Update dependencies
update:
    cargo update

EOF
    log_info "✓ Rust justfile created"
}

# Create Python justfile
create_python_justfile() {
    local systems="$1"
    local install_cmd="pip install"

    if echo "$systems" | grep -q "poetry"; then
        install_cmd="poetry install"
    fi

    log_info "Creating Python justfile"

    cat > justfile << EOF
# Python development targets

default:
    @just --list

# Install dependencies
install:
    $install_cmd

# Clean artifacts
clean:
    rm -rf __pycache__/
    rm -rf *.egg-info/
    rm -rf dist/
    rm -rf build/
    find . -type d -name __pycache__ -delete
    find . -type f -name "*.pyc" -delete

# Development server (if applicable)
dev:
    python -m uvicorn main:app --reload || python main.py

# Build package
build:
    python -m build

# Run tests
test:
    python -m pytest

# Run tests with coverage
test-coverage:
    python -m pytest --cov=. --cov-report=html

# Run linting
lint:
    python -m ruff check . || python -m flake8 .

# Run linting and fix
lint-fix:
    python -m ruff check . --fix || python -m black .

# Type checking
typecheck:
    python -m mypy . || echo "MyPy not configured"

# Format code
format:
    python -m black . || python -m ruff format .

# Security audit
audit:
    python -m bandit -r . || echo "Bandit not installed"

# Bootstrap project
bootstrap:
    @just install
    @echo "Python project bootstrapped!"

# Development loop - fails fast if any step fails
loop: || (install lint test dev)

# Complete CI pipeline
ci: || (install lint typecheck test build)

EOF
    log_info "✓ Python justfile created"
}

# Create Go justfile
create_go_justfile() {
    local systems="$1"

    log_info "Creating Go justfile"

    cat > justfile << EOF
# Go development targets

default:
    @just --list

# Install dependencies
install:
    go mod download
    go mod tidy

# Clean build artifacts
clean:
    rm -rf bin/
    go clean

# Development build
dev:
    go build -o bin/dev ./cmd/...

# Build project
build:
    go build -o bin/main ./cmd/...

# Run tests
test:
    go test ./...

# Run tests with coverage
test-coverage:
    go test -coverprofile=coverage.out ./...
    go tool cover -html=coverage.out -o coverage.html

# Run linting
lint:
    golangci-lint run || go vet ./...

# Format code
format:
    go fmt ./...

# Type checking (built into go build)
typecheck:
    go build ./...

# Run application
run:
    go run ./cmd/...

# Bootstrap project
bootstrap:
    @just install
    @echo "Go project bootstrapped!"

# Development loop - fails fast if any step fails
loop: || (install lint test build)

# Complete CI pipeline
ci: || (install lint typecheck test build)

# Security audit
audit:
    gosec ./... || echo "gosec not installed"

# Update dependencies
update:
    go get -u ./...
    go mod tidy

EOF
    log_info "✓ Go justfile created"
}

# Create Java justfile
create_java_justfile() {
    local systems="$1"
    local build_cmd="mvn"

    if echo "$systems" | grep -q "gradle"; then
        build_cmd="./gradlew"
    elif echo "$systems" | grep -q "maven"; then
        build_cmd="mvn"
    fi

    log_info "Creating Java justfile with $build_cmd"

    cat > justfile << EOF
# Java development targets
# Build system: $build_cmd

default:
    @just --list

# Install dependencies
install:
    $build_cmd dependency:resolve || $build_cmd dependencies

# Clean build artifacts
clean:
    $build_cmd clean

# Development build
dev:
    $build_cmd compile

# Build project
build:
    $build_cmd package

# Run tests
test:
    $build_cmd test

# Run tests with coverage
test-coverage:
    $build_cmd test jacoco:report || $build_cmd test

# Run linting
lint:
    $build_cmd checkstyle:check || echo "Checkstyle not configured"

# Type checking (built into compilation)
typecheck:
    $build_cmd compile

# Run application
run:
    $build_cmd exec:java || java -jar target/*.jar

# Bootstrap project
bootstrap:
    @just install
    @echo "Java project bootstrapped!"

# Development loop - fails fast if any step fails
loop: || (install compile test package)

# Complete CI pipeline
ci: || (install lint test package)

# Security audit
audit:
    $build_cmd dependency-check || echo "Dependency check not configured"

EOF
    log_info "✓ Java justfile created"
}

# Parse project characteristics string into individual variables
parse_project_characteristics() {
    local characteristics="$1"

    # Default values
    local build_systems=""
    local app_type=""
    local project_type=""

    # Parse the characteristics string
    if [[ -n "$characteristics" ]]; then
        build_systems=$(echo "$characteristics" | grep -o 'build_systems:[^|]*' | cut -d: -f2- || echo "")
        app_type=$(echo "$characteristics" | grep -o 'app_type:[^|]*' | cut -d: -f2- || echo "")
        project_type=$(echo "$characteristics" | grep -o 'project_type:[^|]*' | cut -d: -f2- || echo "")
    fi

    # Export variables for use in other functions
    export DETECTED_BUILD_SYSTEMS="$build_systems"
    export DETECTED_APP_TYPE="$app_type"
    export DETECTED_PROJECT_TYPE="$project_type"

    if [[ -n "$build_systems" ]]; then
        log_info "✓ Detected build systems: $build_systems"
    fi
    if [[ -n "$app_type" ]]; then
        log_info "✓ Detected application type: $app_type"
    fi
    if [[ -n "$project_type" ]]; then
        log_info "✓ Detected project type: $project_type"
    fi
}

# Generate devbox.json with language-specific packages
generate_devbox_json() {
    local project_path="${1:-.}"
    local detected_characteristics="$2"

    log_info "Generating devbox.json for project: $project_path"

    cd "$project_path" || {
        log_error "Failed to change to directory: $project_path"
        return 1
    }

    # Parse the characteristics into individual variables
    parse_project_characteristics "$detected_characteristics"

    # Base packages always included
    local packages='["just"]'
    local language_packages=""
    local ai_tools='["yq-go", "jq", "ripgrep", "fd", "bat"]'

    # Add language-specific packages based on detection
    if echo "$DETECTED_BUILD_SYSTEMS" | grep -q "pnpm\|npm\|yarn\|bun"; then
        language_packages='"nodejs_22", "pnpm", "typescript", "eslint", "prettier", "jest"'

        # Add web-specific tooling for web applications
        if [[ "$DETECTED_APP_TYPE" == "web" ]] || [[ "$DETECTED_PROJECT_TYPE" == *"frontend-web"* ]] || [[ "$DETECTED_PROJECT_TYPE" == *"fullstack-web"* ]]; then
            # Add Playwright only for web applications
            ai_tools="$ai_tools, \"playwright\""
            language_packages="$language_packages, \"vite\", \"@vitejs/plugin-react\""
        fi

        # Add CLI-specific tooling for CLI applications
        if [[ "$DETECTED_APP_TYPE" == "cli" ]] || [[ "$DETECTED_PROJECT_TYPE" == *"cli-tool"* ]]; then
            language_packages="$language_packages, \"commander\", \"yargs\""
        fi

    elif echo "$DETECTED_BUILD_SYSTEMS" | grep -q "cargo\|rust"; then
        language_packages='"rustc", "cargo", "clippy", "rustfmt", "rust-analyzer"'

        # Add web-specific tooling for Rust web applications
        if [[ "$DETECTED_APP_TYPE" == "web" ]] || [[ "$DETECTED_PROJECT_TYPE" == *"frontend-web"* ]] || [[ "$DETECTED_PROJECT_TYPE" == *"fullstack-web"* ]]; then
            language_packages="$language_packages, \"trunk\", \"wasm-bindgen-cli\""
        fi

        # Add CLI-specific tooling for Rust CLI applications
        if [[ "$DETECTED_APP_TYPE" == "cli" ]] || [[ "$DETECTED_PROJECT_TYPE" == *"cli-tool"* ]]; then
            language_packages="$language_packages, \"clap\", \"structopt\""
        fi

    elif echo "$DETECTED_BUILD_SYSTEMS" | grep -q "poetry\|python"; then
        language_packages='"python3", "poetry", "black", "ruff", "mypy", "pytest"'

        # Add web-specific tooling for Python web applications
        if [[ "$DETECTED_APP_TYPE" == "web" ]] || [[ "$DETECTED_PROJECT_TYPE" == *"fullstack-web"* ]] || [[ "$DETECTED_PROJECT_TYPE" == *"api-service"* ]]; then
            language_packages="$language_packages, \"fastapi\", \"uvicorn\", \"django\""
        fi

        # Add CLI-specific tooling for Python CLI applications
        if [[ "$DETECTED_APP_TYPE" == "cli" ]] || [[ "$DETECTED_PROJECT_TYPE" == *"cli-tool"* ]]; then
            language_packages="$language_packages, \"click\", \"typer\""
        fi

    elif echo "$DETECTED_BUILD_SYSTEMS" | grep -q "go\|golang"; then
        language_packages='"go", "gopls", "golangci-lint", "go-swagger"'

        # Add web-specific tooling for Go web applications
        if [[ "$DETECTED_APP_TYPE" == "web" ]] || [[ "$DETECTED_PROJECT_TYPE" == *"fullstack-web"* ]] || [[ "$DETECTED_PROJECT_TYPE" == *"api-service"* ]]; then
            language_packages="$language_packages, \"gin\", \"echo\", \"fiber\""
        fi

        # Add CLI-specific tooling for Go CLI applications
        if [[ "$DETECTED_APP_TYPE" == "cli" ]] || [[ "$DETECTED_PROJECT_TYPE" == *"cli-tool"* ]]; then
            language_packages="$language_packages, \"cobra\", \"urfave-cli\""
        fi

    elif echo "$DETECTED_BUILD_SYSTEMS" | grep -q "maven\|gradle"; then
        language_packages='"openjdk", "maven", "gradle", "checkstyle"'

        # Add web-specific tooling for Java web applications
        if [[ "$DETECTED_APP_TYPE" == "web" ]] || [[ "$DETECTED_PROJECT_TYPE" == *"fullstack-web"* ]] || [[ "$DETECTED_PROJECT_TYPE" == *"api-service"* ]]; then
            language_packages="$language_packages, \"spring-boot\", \"tomcat\""
        fi
    fi

    # Combine all packages
    local all_packages="[$packages, $ai_tools"
    if [[ -n "$language_packages" ]]; then
        all_packages="[$packages, $ai_tools, $language_packages]"
    fi

    # Create devbox.json
    cat > devbox.json << EOF
{
  "packages": $all_packages,
  "shell": {
    "init_hook": [
      "just bootstrap-internal"
    ]
  },
  "scripts": {
    "bootstrap": "just bootstrap-internal",
    "build": "just build-internal",
    "test": "just test-internal",
    "dev": "just dev-internal",
    "lint": "just lint-internal",
    "typecheck": "just typecheck-internal",
    "clean": "just clean-internal"
  }
}
EOF

    log_info "✓ devbox.json created with AI tools and language-specific packages"
}

# Generate justfile with proper *-internal targets
generate_integrated_justfile() {
    local project_path="${1:-.}"
    local detected_systems="$2"

    log_info "Generating integrated justfile for project: $project_path"

    cd "$project_path" || {
        log_error "Failed to change to directory: $project_path"
        return 1
    }

    # Start justfile with header
    cat > justfile << 'EOF'
# Integrated justfile with devbox support
# Auto-generated by project-adopter with language-specific targets

default:
    @just --list

# Normal targets - Developer interface (REQUIRED)
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

# Bootstrap recipes (REQUIRED)
bootstrap:
    devbox shell bootstrap

EOF

    # Add language-specific bootstrap-internal
    echo "bootstrap-internal:" >> justfile
    if echo "$detected_systems" | grep -q "pnpm\|npm\|yarn\|bun"; then
        echo "	pnpm install" >> justfile
    elif echo "$detected_systems" | grep -q "cargo\|rust"; then
        echo "	cargo build" >> justfile
    elif echo "$detected_systems" | grep -q "poetry\|python"; then
        echo "	poetry install" >> justfile
    elif echo "$detected_systems" | grep -q "go\|golang"; then
        echo "	go mod download" >> justfile
        echo "	go mod tidy" >> justfile
    elif echo "$detected_systems" | grep -q "maven\|gradle"; then
        echo "	./gradlew compileJava || mvn compile" >> justfile
    fi
    echo "	echo \"Development environment ready!\"" >> justfile
    echo "" >> justfile

    # Add internal targets
    echo "# Internal targets (REQUIRED)" >> justfile

    # build-internal
    echo "build-internal:" >> justfile
    if echo "$detected_systems" | grep -q "pnpm\|npm\|yarn\|bun"; then
        echo "	pnpm run build" >> justfile
    elif echo "$detected_systems" | grep -q "cargo\|rust"; then
        echo "	cargo build --release" >> justfile
    elif echo "$detected_systems" | grep -q "poetry\|python"; then
        echo "	poetry build" >> justfile
    elif echo "$detected_systems" | grep -q "go\|golang"; then
        echo "	go build ./..." >> justfile
    elif echo "$detected_systems" | grep -q "maven\|gradle"; then
        echo "	./gradlew build || mvn package" >> justfile
    fi
    echo "" >> justfile

    # test-internal
    echo "test-internal:" >> justfile
    if echo "$detected_systems" | grep -q "pnpm\|npm\|yarn\|bun"; then
        echo "	pnpm test" >> justfile
    elif echo "$detected_systems" | grep -q "cargo\|rust"; then
        echo "	cargo test" >> justfile
    elif echo "$detected_systems" | grep -q "poetry\|python"; then
        echo "	poetry run pytest" >> justfile
    elif echo "$detected_systems" | grep -q "go\|golang"; then
        echo "	go test ./..." >> justfile
    elif echo "$detected_systems" | grep -q "maven\|gradle"; then
        echo "	./gradlew test || mvn test" >> justfile
    fi
    echo "" >> justfile

    # dev-internal
    echo "dev-internal:" >> justfile
    if echo "$detected_systems" | grep -q "pnpm\|npm\|yarn\|bun"; then
        echo "	pnpm run dev" >> justfile
    elif echo "$detected_systems" | grep -q "cargo\|rust"; then
        echo "	cargo run" >> justfile
    elif echo "$detected_systems" | grep -q "poetry\|python"; then
        echo "	poetry run python -m src || poetry run python main.py" >> justfile
    elif echo "$detected_systems" | grep -q "go\|golang"; then
        echo "	go run ./cmd/... || go run ./..." >> justfile
    elif echo "$detected_systems" | grep -q "maven\|gradle"; then
        echo "	./gradlew bootRun || mvn exec:java" >> justfile
    fi
    echo "" >> justfile

    # lint-internal
    echo "lint-internal:" >> justfile
    if echo "$detected_systems" | grep -q "pnpm\|npm\|yarn\|bun"; then
        echo "	pnpm run lint" >> justfile
    elif echo "$detected_systems" | grep -q "cargo\|rust"; then
        echo "	cargo clippy -- -D warnings" >> justfile
    elif echo "$detected_systems" | grep -q "poetry\|python"; then
        echo "	poetry run ruff check . || poetry run flake8 ." >> justfile
    elif echo "$detected_systems" | grep -q "go\|golang"; then
        echo "	golangci-lint run || go vet ./..." >> justfile
    elif echo "$detected_systems" | grep -q "maven\|gradle"; then
        echo "	./gradlew checkstyle:main || echo \"Lint not configured\"" >> justfile
    fi
    echo "" >> justfile

    # typecheck-internal
    echo "typecheck-internal:" >> justfile
    if echo "$detected_systems" | grep -q "pnpm\|npm\|yarn\|bun"; then
        echo "	pnpm run typecheck || pnpm run tsc --noEmit" >> justfile
    elif echo "$detected_systems" | grep -q "cargo\|rust"; then
        echo "	cargo check" >> justfile
    elif echo "$detected_systems" | grep -q "poetry\|python"; then
        echo "	poetry run mypy . || echo \"MyPy not configured\"" >> justfile
    elif echo "$detected_systems" | grep -q "go\|golang"; then
        echo "	go build ./..." >> justfile
    elif echo "$detected_systems" | grep -q "maven\|gradle"; then
        echo "	./gradlew compileJava || mvn compile" >> justfile
    fi
    echo "" >> justfile

    # clean-internal
    echo "clean-internal:" >> justfile
    if echo "$detected_systems" | grep -q "pnpm\|npm\|yarn\|bun"; then
        echo "	rm -rf node_modules/ dist/ .next/ .nuxt/ .vite/" >> justfile
    elif echo "$detected_systems" | grep -q "cargo\|rust"; then
        echo "	cargo clean" >> justfile
    elif echo "$detected_systems" | grep -q "poetry\|python"; then
        echo "	rm -rf __pycache__/ *.egg-info/ dist/ build/" >> justfile
        echo "	find . -type d -name __pycache__ -delete" >> justfile
        echo "	find . -type f -name \"*.pyc\" -delete" >> justfile
    elif echo "$detected_systems" | grep -q "go\|golang"; then
        echo "	rm -rf bin/" >> justfile
        echo "	go clean" >> justfile
    elif echo "$detected_systems" | grep -q "maven\|gradle"; then
        echo "	./gradlew clean || mvn clean" >> justfile
    fi
    echo "" >> justfile

    # Add loop targets
    echo "# Development loop targets" >> justfile
    echo "loop: || (bootstrap build test dev)" >> justfile
    echo "ci: || (bootstrap lint typecheck test build)" >> justfile

    log_info "✓ Integrated justfile created with language-specific *-internal targets"
}

# Create generic justfile
create_generic_justfile() {
    log_info "Creating generic justfile"

    cat > justfile << 'EOF'
# Standard development targets

default:
    @just --list

# Clean build artifacts
clean:
    @echo "Cleaning build artifacts..."
    @rm -rf dist/ build/ target/ node_modules/.cache/ __pycache__/ bin/

# Development server
dev:
    @echo "Starting development server..."
    @echo "Configure this target based on your project type"

# Build project
build:
    @echo "Building project..."
    @echo "Configure this target based on your project type"

# Run tests
test:
    @echo "Running tests..."
    @echo "Configure this target based on your project type"

# Run linting
lint:
    @echo "Running linter..."
    @echo "Configure this target based on your project type"

# Type checking
typecheck:
    @echo "Running type checker..."
    @echo "Configure this target based on your project type"

# Install dependencies
install:
    @echo "Installing dependencies..."
    @echo "Configure this target based on your project type"

# Bootstrap project
bootstrap:
    @just install
    @echo "Project bootstrapped!"

# Development loop
loop: || (install build lint test dev)

EOF
    log_info "✓ Generic justfile created"
}

# Generate AGENTS.md with project-specific AI agent configuration
generate_agents_md() {
    local project_path="${1:-.}"
    local detected_systems="$2"

    log_info "Generating AGENTS.md for project: $project_path"

    cd "$project_path" || {
        log_error "Failed to change to directory: $project_path"
        return 1
    }

    # Determine project type and language
    local project_type="Unknown"
    local language="Unknown"
    local build_system="Unknown"

    if echo "$detected_systems" | grep -q "pnpm\|npm\|yarn\|bun"; then
        project_type="Node.js/TypeScript"
        language="TypeScript"
        build_system="npm/pnpm"
    elif echo "$detected_systems" | grep -q "cargo\|rust"; then
        project_type="Rust"
        language="Rust"
        build_system="cargo"
    elif echo "$detected_systems" | grep -q "poetry\|python"; then
        project_type="Python"
        language="Python"
        build_system="poetry/pip"
    elif echo "$detected_systems" | grep -q "go\|golang"; then
        project_type="Go"
        language="Go"
        build_system="go modules"
    elif echo "$detected_systems" | grep -q "maven\|gradle"; then
        project_type="Java"
        language="Java"
        build_system="maven/gradle"
    fi

    # Get project name from directory
    local project_name
    project_name=$(basename "$PWD")

    # Create AGENTS.md
    cat > AGENTS.md << EOF
# AI Agent Documentation: $project_name

This document provides detailed technical information for automated code assistants and developers working with this $project_type project.

## Quick Reference

- Read \`README.md\` for user-focused documentation
- This is a $project_type project using $build_system
- **Development Commands**: \`just --list\` for available targets
- **Environment**: Uses Devbox for consistent development environment
- **Bootstrap**: Run \`just bootstrap\` to prepare the project

## Repository Structure

### Core Directories

EOF

    # Add language-specific structure
    if [[ "$project_type" == "Node.js/TypeScript" ]]; then
        cat >> AGENTS.md << 'EOF'
```
src/                     # Source code
├── components/          # React/Vue/Angular components
├── lib/                  # Library code
├── types/                # TypeScript type definitions
├── utils/                # Utility functions
└── index.ts             # Main entry point

tests/                   # Test files
├── unit/                 # Unit tests
├── integration/          # Integration tests
└── e2e/                  # End-to-end tests

dist/                    # Build output
node_modules/            # Dependencies (auto-generated)
```
EOF
    elif [[ "$project_type" == "Rust" ]]; then
        cat >> AGENTS.md << 'EOF'
```
src/                     # Source code
├── main.rs              # Application entry point
├── lib.rs               # Library root
├── bin/                 # Binary executables
├── models/              # Data models
├── services/            # Business logic
└── utils/               # Utility modules

tests/                   # Test files
├── unit/                 # Unit tests
├── integration/          # Integration tests
└── common/              # Test utilities

target/                  # Build output (auto-generated)
├── debug/               # Debug builds
├── release/             # Release builds
└── doc/                 # Documentation
```
EOF
    elif [[ "$project_type" == "Python" ]]; then
        cat >> AGENTS.md << 'EOF'
```
src/                     # Source code
├── main.py              # Application entry point
├── models/              # Data models
├── services/            # Business logic
├── utils/               # Utility functions
└── config/              # Configuration

tests/                   # Test files
├── unit/                 # Unit tests
├── integration/          # Integration tests
└── fixtures/             # Test data

__pycache__/             # Python cache (auto-generated)
dist/                    # Build output
*.egg-info/              # Package metadata (auto-generated)
```
EOF
    elif [[ "$project_type" == "Go" ]]; then
        cat >> AGENTS.md << 'EOF'
```
cmd/                     # Application entry points
├── main.go              # Main application
└── server/              # Server components

pkg/                     # Library code
├── models/              # Data models
├── services/            # Business logic
├── handlers/            # HTTP handlers
└── utils/               # Utility functions

internal/                # Internal packages
├── config/              # Configuration
└── database/            # Database access

bin/                     # Build output (auto-generated)
vendor/                  # Dependencies (auto-generated)
```
EOF
    elif [[ "$project_type" == "Java" ]]; then
        cat >> AGENTS.md << 'EOF'
```
src/                     # Source code
├── main/java/           # Main application code
│   ├── com/example/     # Package structure
│   ├── controller/      # Controllers
│   ├── service/         # Business logic
│   ├── model/           # Data models
│   └── util/            # Utilities
└── test/java/           # Test code
    └── com/example/     # Test packages

build/                   # Build output (auto-generated)
target/                  # Gradle build output (auto-generated)
```
EOF
    fi

    # Add development workflow section
    cat >> AGENTS.md << EOF

### Configuration Files

EOF

    # Add language-specific config files
    if [[ "$project_type" == "Node.js/TypeScript" ]]; then
        cat >> AGENTS.md << 'EOF'
- **package.json** - Dependencies and scripts
- **tsconfig.json** - TypeScript configuration
- **jest.config.js** - Test configuration
- **.eslintrc.js** - Linting configuration
- **tailwind.config.js** - CSS framework configuration
- **next.config.js** - Next.js configuration (if applicable)
EOF
    elif [[ "$project_type" == "Rust" ]]; then
        cat >> AGENTS.md << 'EOF'
- **Cargo.toml** - Dependencies and configuration
- **rustfmt.toml** - Code formatting configuration
- **clippy.toml** - Linting configuration
- **.rustfmt.toml** - Rust formatter settings
EOF
    elif [[ "$project_type" == "Python" ]]; then
        cat >> AGENTS.md << 'EOF'
- **pyproject.toml** - Dependencies and project configuration
- **poetry.lock** - Dependency lock file
- **pytest.ini** - Test configuration
- **ruff.toml** - Linting configuration
- **mypy.ini** - Type checking configuration
EOF
    elif [[ "$project_type" == "Go" ]]; then
        cat >> AGENTS.md << 'EOF'
- **go.mod** - Go modules definition
- **go.sum** - Dependency checksums
- **.golangci.yml** - Linting configuration
EOF
    elif [[ "$project_type" == "Java" ]]; then
        cat >> AGENTS.md << 'EOF'
- **build.gradle** - Gradle build configuration
- **settings.gradle** - Gradle settings
- **checkstyle.xml** - Code style configuration
EOF
    fi

    # Add tools and commands section
    cat >> AGENTS.md << EOF

## Development Tools

### Environment Management
- **Devbox** - Consistent development environment
- **Just** - Command runner and task automation
- **direnv** - Automatic environment loading

### Essential Tools

EOF

    # Add language-specific tools
    if [[ "$project_type" == "Node.js/TypeScript" ]]; then
        cat >> AGENTS.md << EOF
- **pnpm** - Fast package manager
- **TypeScript** - Type-safe JavaScript
- **ESLint** - Code linting
- **Prettier** - Code formatting
- **Jest** - Testing framework
EOF
    elif [[ "$project_type" == "Rust" ]]; then
        cat >> AGENTS.md << EOF
- **Cargo** - Package manager and build system
- **Rustfmt** - Code formatting
- **Clippy** - Linting and code analysis
- **rust-analyzer** - Language server
EOF
    elif [[ "$project_type" == "Python" ]]; then
        cat >> AGENTS.md << EOF
- **Poetry** - Dependency management
- **Black** - Code formatting
- **Ruff** - Linting and code analysis
- **MyPy** - Type checking
- **pytest** - Testing framework
EOF
    elif [[ "$project_type" == "Go" ]]; then
        cat >> AGENTS.md << EOF
- **Go modules** - Dependency management
- **gofmt** - Code formatting
- **golangci-lint** - Linting
- **go test** - Testing framework
EOF
    elif [[ "$project_type" == "Java" ]]; then
        cat >> AGENTS.md << EOF
- **Gradle** - Build automation
- **Checkstyle** - Code style checking
- **JUnit** - Testing framework
EOF
    fi

    # Add AI-specific tools
    cat >> AGENTS.md << EOF

### AI Development Tools
- **yq-go** - YAML/JSON/TOML processing
- **jq** - JSON processing
- **ripgrep** - Fast text search
- **fd** - File finding
- **bat** - Enhanced cat with syntax highlighting

## Development Workflow

### Bootstrap Process
1. \`cd\` into project directory
2. direnv automatically loads Devbox environment
3. Devbox runs \`just bootstrap-internal\`
4. Dependencies are installed and project is ready

### Daily Development
\`\`\`bash
# Start development
just dev

# Run tests
just test

# Check code quality
just lint
just typecheck

# Build project
just build

# Full development loop
just loop
\`\`\`

### Testing Strategy
EOF

    # Add language-specific testing
    if [[ "$project_type" == "Node.js/TypeScript" ]]; then
        cat >> AGENTS.md << EOF
- **Unit tests**: \`just test\` (Jest)
- **Integration tests**: \`just test:integration\`
- **E2E tests**: \`just test:e2e\` (Playwright)
- **Type checking**: \`just typecheck\`
EOF
    elif [[ "$project_type" == "Rust" ]]; then
        cat >> AGENTS.md << EOF
- **Unit tests**: \`just test\` (cargo test)
- **Integration tests**: \`just test:integration\`
- **Documentation tests**: \`just test:doc\`
- **Benchmarks**: \`just test:bench\`
EOF
    elif [[ "$project_type" == "Python" ]]; then
        cat >> AGENTS.md << EOF
- **Unit tests**: \`just test\` (pytest)
- **Integration tests**: \`just test:integration\`
- **Type checking**: \`just typecheck\` (mypy)
- **Coverage**: \`just test:coverage\`
EOF
    elif [[ "$project_type" == "Go" ]]; then
        cat >> AGENTS.md << EOF
- **Unit tests**: \`just test\` (go test)
- **Integration tests**: \`just test:integration\`
- **Race detection**: \`just test:race\`
- **Coverage**: \`just test:coverage\`
EOF
    elif [[ "$project_type" == "Java" ]]; then
        cat >> AGENTS.md << EOF
- **Unit tests**: \`just test\` (JUnit)
- **Integration tests**: \`just test:integration\`
- **Code quality**: \`just checkstyle\`
EOF
    fi

    # Add build and deployment section
    cat >> AGENTS.md << EOF

### Build Process
EOF

    if [[ "$project_type" == "Node.js/TypeScript" ]]; then
        cat >> AGENTS.md << EOF
- **Development build**: \`just build\` (npm run build)
- **Production build**: \`just build:prod\`
- **Package analysis**: \`just analyze\`
EOF
    elif [[ "$project_type" == "Rust" ]]; then
        cat >> AGENTS.md << EOF
- **Debug build**: \`just build\` (cargo build)
- **Release build**: \`just build:release\` (cargo build --release)
- **Documentation**: \`just doc\` (cargo doc)
EOF
    elif [[ "$project_type" == "Python" ]]; then
        cat >> AGENTS.md << EOF
- **Development build**: \`just build\` (poetry build)
- **Production build**: \`just build:prod\`
- **Documentation**: \`just doc\`
EOF
    elif [[ "$project_type" == "Go" ]]; then
        cat >> AGENTS.md << EOF
- **Development build**: \`just build\` (go build)
- **Release build**: \`just build:release\`
- **Cross-platform**: \`just build:all\`
EOF
    elif [[ "$project_type" == "Java" ]]; then
        cat >> AGENTS.md << EOF
- **Development build**: \`just build\` (gradle build)
- **Production build**: \`just build:prod\`
- **Fat jar**: \`just jar\`
EOF
    fi

    # Add AI agent guidelines
    cat >> AGENTS.md << EOF

## AI Agent Guidelines

### Code Style
- Follow existing code patterns and conventions
- Use language-specific formatting tools
- Maintain consistent naming conventions
- Add appropriate comments and documentation

### File Organization
- Keep related functionality together
- Use clear, descriptive file and directory names
- Follow established project structure
- Separate concerns appropriately

### Testing Requirements
- Write tests for all new functionality
- Maintain high test coverage
- Use appropriate test types (unit, integration, e2e)
- Ensure tests are deterministic and fast

### Commit Standards
- Use conventional commit messages
- Include relevant issue numbers
- Keep commits focused and atomic
- Ensure CI passes before merging

### Dependencies
- Use approved package versions
- Update dependencies regularly
- Review security implications
- Document any special requirements

## Common Tasks

### Adding New Features
1. Create feature branch
2. Implement functionality with tests
3. Run \`just ci\` to verify quality
4. Update documentation
5. Submit pull request

### Debugging Issues
1. Use \`just dev\` for development server
2. Check logs and error messages
3. Use language-specific debugging tools
4. Run targeted tests

### Performance Optimization
1. Profile application performance
2. Identify bottlenecks
3. Optimize critical paths
4. Validate improvements

## Memory References

Key memory entries for reference:

EOF

    # Add language-specific memory references
    if [[ "$project_type" == "Node.js/TypeScript" ]]; then
        cat >> AGENTS.md << EOF
- Node.js package management patterns
- TypeScript configuration best practices
- React/Vue/Angular component guidelines
- Testing strategies for JavaScript
EOF
    elif [[ "$project_type" == "Rust" ]]; then
        cat >> AGENTS.md << EOF
- Rust ownership and borrowing patterns
- Cargo workspace management
- Error handling best practices
- Performance optimization techniques
EOF
    elif [[ "$project_type" == "Python" ]]; then
        cat >> AGENTS.md << EOF
- Python packaging with Poetry
- Type checking with MyPy
- Testing with pytest
- Virtual environment management
EOF
    elif [[ "$project_type" == "Go" ]]; then
        cat >> AGENTS.md << EOF
- Go modules and dependency management
- Interface design patterns
- Concurrency with goroutines
- Error handling patterns
EOF
    elif [[ "$project_type" == "Java" ]]; then
        cat >> AGENTS.md << EOF
- Gradle build configuration
- Spring Boot patterns
- Java package structure
- Testing with JUnit
EOF
    fi

    log_info "✓ AGENTS.md created with project-specific AI agent configuration"
}
adopt_project() {
    local mode="${1:-adopt}"

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            --mode)
                mode="$2"
                shift 2
                ;;
            --no-loop-prevention)
                LOOP_DETECTION_ENABLED=false
                shift
                ;;
            --force)
                FORCE_ADOPTION=true
                shift
                ;;
            --verbose|-v)
                set -x  # Enable verbose output
                shift
                ;;
            --)
                shift
                break
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done

    # Set mode based on parameter or default
    if [[ "$mode" != "adopt" && "$mode" != "standardize" ]]; then
        log_error "Invalid mode: $mode. Use --mode adopt or --mode standardize"
        show_help
        exit 1
    fi

    # Store mode globally for other functions
    ADOPTION_MODE="$mode"

    log_info "Starting project adoption in $mode mode for: $PROJECT_PATH"
    log_info "Project name: $PROJECT_NAME"

    # Run pre-adoption health review
    log_step "Running pre-adoption repository health review"
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local health_review_script="$script_dir/../repository-health-review/scripts/repository-health-review.sh"

    if [[ -f "$health_review_script" ]]; then
        local pre_adoption_health="$PROJECT_PATH/.pre-adoption-health.json"
        if "$health_review_script" --report "$pre_adoption_health" "$PROJECT_PATH" "$PROJECT_NAME"; then
            log_info "Pre-adoption health review completed: $pre_adoption_health"

            # Show health score if available
            if command -v jq >/dev/null 2>&1 && [[ -f "$pre_adoption_health" ]]; then
                local health_score
                health_score=$(jq -r '.health_score' "$pre_adoption_health" 2>/dev/null || echo "unknown")
                local critical_issues
                critical_issues=$(jq -r '.issues.critical' "$pre_adoption_health" 2>/dev/null || echo "0")
                log_info "  Health Score: $health_score/100"
                log_info "  Critical Issues: $critical_issues"

                if [[ $critical_issues -gt 0 ]]; then
                    log_warn "  ⚠️  Critical issues detected - review health report before proceeding"
                fi
            fi
        else
            log_warn "Pre-adoption health review failed, continuing with adoption"
        fi
    else
        log_info "Repository health review skill not found, skipping pre-adoption analysis"
    fi

    # Load skill functions
    if ! load_project_detection; then
        log_error "Failed to load project detection"
        exit 1
    fi

    if ! load_surgical_config; then
        log_error "Failed to load surgical config"
        exit 1
    fi

    # Detect project characteristics
    local detection_result
    detection_result=$(detect_project)
    local detected_characteristics="$detection_result"

    # Apply surgical configurations using per-language scripts
    apply_surgical_configs "$detected_characteristics"

    # Create configuration files
    create_config_files "$detected_characteristics"

    # Run post-adoption health review
    log_step "Running post-adoption repository health review"
    if [[ -f "$health_review_script" ]]; then
        local post_adoption_health="$PROJECT_PATH/.post-adoption-health.json"
        if "$health_review_script" --report "$post_adoption_health" "$PROJECT_PATH" "$PROJECT_NAME"; then
            log_info "Post-adoption health review completed: $post_adoption_health"

            # Show improvement if available
            if command -v jq >/dev/null 2>&1 && [[ -f "$pre_adoption_health" ]] && [[ -f "$post_adoption_health" ]]; then
                local pre_score
                local post_score
                pre_score=$(jq -r '.health_score' "$pre_adoption_health" 2>/dev/null || echo "0")
                post_score=$(jq -r '.health_score' "$post_adoption_health" 2>/dev/null || echo "0")

                if [[ $post_score -gt $pre_score ]]; then
                    local improvement=$((post_score - pre_score))
                    log_info "  🎉 Health score improved by +$improvement points ($pre_score → $post_score)"
                elif [[ $post_score -lt $pre_score ]]; then
                    local degradation=$((pre_score - post_score))
                    log_warn "  ⚠️  Health score decreased by -$degradation points ($pre_score → $post_score)"
                else
                    log_info "  ➡️  Health score unchanged: $post_score/100"
                fi
            fi
        else
            log_warn "Post-adoption health review failed"
        fi
    fi

    log_info "✅ Project adoption completed successfully!"
    log_info "Next steps:"
    log_info "  1. Review the generated configuration files"
    log_info "  2. Review health reports (.pre-adoption-health.json and .post-adoption-health.json)"
    log_info "  3. Run 'just bootstrap' to install dependencies"
    log_info "  4. Run 'just dev' to start development"
    log_info "  5. Address any critical issues identified in health reviews"
}

# Show help
show_help() {
    cat << EOF
Project Adopter - Intelligent project setup with surgical-config integration

Usage: $0 [options] [project_path] [project_name]

Options:
  --help, -h              Show this help message
  --no-loop-prevention   Disable infinite loop detection
  --force-adoption       Force adoption even if loops detected
  --verbose, -v          Show detailed output

Arguments:
  project_path    Path to the project directory (default: .)
  project_name    Name of the project (default: basename of project_path)

Examples:
  # Adopt current directory
  $0

  # Adopt specific project
  $0 /path/to/my-project my-project

  # Adopt with custom name
  $0 ./my-cool-app cool-app

Features:
  - Automatic project detection (build systems, CI/CD, workspace tools)
  - Surgical configuration updates (preserves comments, formatting)
  - Standard developer UX setup (devbox, justfile, .envrc)
  - Multi-context support (chezmoi templates, deployed config, AI tools)
  - Loop prevention for safe skill integration
  - Recursive call protection
  - Process tree analysis

Loop Prevention:
  The script includes automatic infinite loop detection:
  - Detects if project-adopter is already running
  - Prevents nested calls from the same process tree
  - Checks for surgical-config execution conflicts
  - Can be disabled with --no-loop-prevention
  - Can be forced with --force-adoption

Requirements:
  - project-detection skill
  - surgical-config skill
  - devbox (recommended)

EOF
}

# Main execution
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            --justfile-only)
                create_justfile_only "$2"
                exit $?
                ;;
            --no-loop-prevention)
                LOOP_DETECTION_ENABLED=false
                shift
                ;;
            --force)
                FORCE_ADOPTION=true
                shift
                ;;
            --verbose|-v)
                set -x  # Enable verbose output
                shift
                ;;
            --)
                shift
                break
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done

    case "${1:-}" in
        "")
            adopt_project
            ;;
        "justfile-only")
            create_justfile_only "$2"
            ;;
        *)
            adopt_project "$@"
            ;;
    esac
}

# Run main function with all arguments
main "$@"
