#!/usr/bin/env bash
# configure-generic.sh
# Generic project configuration script
# Fallback for unknown or unsupported project types

set -euo pipefail

# Import common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/config-functions.sh
if [[ -f "$SCRIPT_DIR/../common/config-functions.sh" ]]; then
    source "$SCRIPT_DIR/../common/config-functions.sh"
fi

# Configure generic project
configure_generic_project() {
    local project_path="$1"
    local mode="${2:-adopt}"     # adopt | standardize
    local app_type="${3:-unknown}" # web | cli | api | library
    local project_type="${4:-unknown}" # frontend-web | api-service | cli-tool | library

    log_info "Configuring generic project (mode: $mode, app_type: $app_type)"

    # Create basic project structure
    configure_generic_structure "$project_path" "$mode"

    # Create basic configuration files
    configure_generic_configs "$project_path" "$mode" "$app_type" "$project_type"

    # Create basic documentation
    configure_generic_docs "$project_path" "$mode"
}

# Configure generic project structure
configure_generic_structure() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]]; then
        # Create standard directory structure
        mkdir -p "$project_path/src"
        mkdir -p "$project_path/docs"
        mkdir -p "$project_path/tests"
        mkdir -p "$project_path/scripts"
        mkdir -p "$project_path/config"

        # Create basic files
        if [[ ! -f "$project_path/src/main" ]]; then
            touch "$project_path/src/main"
            chmod +x "$project_path/src/main"
            log_info "✓ Created src/main"
        fi

        if [[ ! -f "$project_path/README.md" ]]; then
            cat > "$project_path/README.md" << 'EOF'
# Project Name

A generic project.

## Getting Started

1. Clone the repository
2. Install dependencies
3. Run the project

## Usage

```bash
./src/main
```

## Development

```bash
# Run tests
./scripts/test

# Build project
./scripts/build
```

## License

MIT
EOF
            log_info "✓ Created README.md"
        fi

        # Create basic scripts
        if [[ ! -f "$project_path/scripts/build" ]]; then
            cat > "$project_path/scripts/build" << 'EOF'
#!/bin/bash
# Build script

echo "Building project..."
# Add build commands here
echo "Build complete"
EOF
            chmod +x "$project_path/scripts/build"
            log_info "✓ Created scripts/build"
        fi

        if [[ ! -f "$project_path/scripts/test" ]]; then
            cat > "$project_path/scripts/test" << 'EOF'
#!/bin/bash
# Test script

echo "Running tests..."
# Add test commands here
echo "Tests complete"
EOF
            chmod +x "$project_path/scripts/test"
            log_info "✓ Created scripts/test"
        fi
    fi
}

# Configure generic configurations
configure_generic_configs() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]]; then
        # Create .gitignore
        if [[ ! -f "$project_path/.gitignore" ]]; then
            cat > "$project_path/.gitignore" << 'EOF'
# Build artifacts
build/
dist/
target/
bin/
*.exe
*.dll
*.so
*.dylib

# Dependencies
node_modules/
vendor/
__pycache__/
*.pyc
*.pyo
*.pyd
.Python

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Environment files
.env
.env.local
.env.*.local

# Coverage reports
coverage/
*.coverage
.coverage
.nyc_output

# Temporary files
tmp/
temp/
*.tmp
EOF
            log_info "✓ Created .gitignore"
        fi

        # Create basic Makefile
        if [[ ! -f "$project_path/Makefile" ]] && [[ ! -f "$project_path/makefile" ]]; then
            cat > "$project_path/Makefile" << 'EOF'
.PHONY: help build test clean install run

# Default target
help:
	@echo "Available targets:"
	@echo "  build    - Build the project"
	@echo "  test     - Run tests"
	@echo "  clean    - Clean build artifacts"
	@echo "  install  - Install dependencies"
	@echo "  run      - Run the project"

# Build the project
build:
	@echo "Building project..."
	# Add build commands here

# Run tests
test:
	@echo "Running tests..."
	# Add test commands here

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf build/ dist/ target/ bin/

# Install dependencies
install:
	@echo "Installing dependencies..."
	# Add install commands here

# Run the project
run: build
	@echo "Running project..."
	./src/main
EOF
            log_info "✓ Created Makefile"
        fi

        # Create editor configuration
        configure_editor_configs "$project_path" "$mode"
    fi
}

# Configure editor configurations
configure_editor_configs() {
    local project_path="$1"
    local mode="$2"

    # VS Code configuration
    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/.vscode/settings.json" ]]; then
        mkdir -p "$project_path/.vscode"
        cat > "$project_path/.vscode/settings.json" << 'EOF'
{
    "editor.formatOnSave": true,
    "editor.insertSpaces": true,
    "editor.tabSize": 4,
    "editor.detectIndentation": false,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "files.trimFinalNewlines": true,
    "search.exclude": {
        "**/node_modules": true,
        "**/build": true,
        "**/dist": true,
        "**/target": true,
        "**/vendor": true
    }
}
EOF
        log_info "✓ Created .vscode/settings.json"
    fi

    # Vim configuration
    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/.vimrc" ]]; then
        cat > "$project_path/.vimrc" << 'EOF'
" Basic Vim configuration for this project
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent
set number
set relativenumber
set ruler
set laststatus=2
set background=dark
syntax on
EOF
        log_info "✓ Created .vimrc"
    fi
}

# Configure generic documentation
configure_generic_docs() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]]; then
        # Create contributing guide
        if [[ ! -f "$project_path/CONTRIBUTING.md" ]]; then
            cat > "$project_path/CONTRIBUTING.md" << 'EOF'
# Contributing

Thank you for your interest in contributing to this project!

## Getting Started

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## Development Guidelines

- Follow the existing code style
- Write clear, descriptive commit messages
- Add documentation for new features
- Update tests as needed

## Testing

Run the test suite before submitting:

```bash
make test
```

## Code Style

This project uses automatic code formatting. Please run:

```bash
make format
```

Before committing your changes.
EOF
            log_info "✓ Created CONTRIBUTING.md"
        fi

        # Create license file
        if [[ ! -f "$project_path/LICENSE" ]]; then
            cat > "$project_path/LICENSE" << 'EOF'
MIT License

Copyright (c) 2024

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
            log_info "✓ Created LICENSE"
        fi

        # Create changelog
        if [[ ! -f "$project_path/CHANGELOG.md" ]]; then
            cat > "$project_path/CHANGELOG.md" << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project setup

### Changed

### Deprecated

### Removed

### Fixed

### Security
EOF
            log_info "✓ Created CHANGELOG.md"
        fi
    fi
}

# Export functions for use by adopt-project.sh
export -f configure_generic_project
export -f configure_generic_structure
export -f configure_generic_configs
export -f configure_editor_configs
export -f configure_generic_docs
