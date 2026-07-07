#!/usr/bin/env bash
# configure-nodejs.sh
# Node.js/TypeScript project configuration script
# Handles package.json, tsconfig.json, and framework-specific configs

set -euo pipefail

# Import common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/config-functions.sh
if [[ -f "$SCRIPT_DIR/../common/config-functions.sh" ]]; then
    source "$SCRIPT_DIR/../common/config-functions.sh"
fi

# Check for yq availability and version
check_yq() {
    if ! command -v yq >/dev/null 2>&1; then
        return 1
    fi

    local yq_version
    yq_version=$(yq --version 2>/dev/null)

    if echo "$yq_version" | grep -q "https://github.com/mikefarah/yq/"; then
        echo "WARNING: Python yq detected ($yq_version), which may not preserve comments. Consider installing yq-go package for better comment preservation."
        return 2  # Python mikefarah/yq
    elif echo "$yq_version" | grep -q "yq (https://github.com/kislyuk/yq/)"; then
        echo "WARNING: Python kislyuk/yq detected, which may not preserve comments. Consider installing yq-go package for better comment preservation."
        return 3  # Python kislyuk/yq
    else
        echo "Using yq for package.json modifications"
        return 0  # Go yq or other preferred version
    fi
}

# Configure Node.js/TypeScript project
configure_nodejs_project() {
    local project_path="$1"
    local mode="${2:-adopt}"     # adopt | standardize
    local app_type="${3:-unknown}" # web | cli | api | library
    local project_type="${4:-unknown}" # frontend-web | api-service | cli-tool | library

    log_info "Configuring Node.js/TypeScript project (mode: $mode, app_type: $app_type)"

    # Handle package.json
    if [[ -f "$project_path/package.json" ]]; then
        configure_package_json "$project_path" "$mode" "$app_type" "$project_type"
    elif [[ "$mode" == "standardize" ]]; then
        create_package_json "$project_path" "$mode" "$app_type" "$project_type"
    fi

    # Handle tsconfig.json
    if [[ -f "$project_path/tsconfig.json" ]] || [[ "$mode" == "standardize" ]]; then
        configure_tsconfig_json "$project_path" "$mode" "$app_type"
    fi

    # Handle framework-specific configs (Next.js, Vite, etc.)
    configure_framework_configs "$project_path" "$mode" "$app_type" "$project_type"

    # Handle ESLint configuration (based on boilerplate)
    if [[ -f "$project_path/.eslintrc.js" ]] || [[ -f "$project_path/.eslintrc.json" ]] || [[ -f "$project_path/eslint.config.mts" ]] || [[ "$mode" == "standardize" ]]; then
        configure_eslint_config "$project_path" "$mode" "$app_type"
    fi

    # Handle Prettier configuration
    if [[ -f "$project_path/.prettierrc" ]] || [[ -f "$project_path/.prettierrc.json" ]] || [[ "$mode" == "standardize" ]]; then
        configure_prettier_config "$project_path" "$mode"
    fi

    # Handle Tailwind CSS configuration (based on boilerplate)
    if [[ -f "$project_path/tailwind.config.ts" ]] || [[ -f "$project_path/tailwind.config.js" ]] || [[ "$mode" == "standardize" ]]; then
        configure_tailwind_config "$project_path" "$mode" "$app_type"
    fi

    # Handle PostCSS configuration (based on boilerplate)
    if [[ -f "$project_path/postcss.config.js" ]] || [[ -f "$project_path/postcss.config.mjs" ]] || [[ "$mode" == "standardize" ]]; then
        configure_postcss_config "$project_path" "$mode"
    fi

    # Handle Vitest configuration (based on boilerplate)
    if [[ -f "$project_path/vitest.config.mts" ]] || [[ -f "$project_path/vitest.config.ts" ]] || [[ "$mode" == "standardize" ]]; then
        configure_vitest_config "$project_path" "$mode" "$app_type"
    fi

    # Handle Playwright configuration (based on boilerplate)
    if [[ -f "$project_path/playwright.config.ts" ]] || [[ "$mode" == "standardize" ]]; then
        configure_playwright_config "$project_path" "$mode" "$app_type"
    fi

    # Handle testing configuration
    configure_testing_configs "$project_path" "$mode" "$app_type"
}

# Configure package.json
configure_package_json() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring package.json for Node.js project"

    if [[ "$mode" == "standardize" ]]; then
        # Standardize mode - comprehensive additions
        add_standardize_package_json_scripts "$project_path" "$app_type" "$project_type"
        add_standardize_package_json_deps "$project_path" "$app_type" "$project_type"
    else
        # Adopt mode - minimal essential additions
        add_adopt_package_json_scripts "$project_path" "$app_type" "$project_type"
        add_adopt_package_json_deps "$project_path" "$app_type" "$project_type"
    fi
}

# Add standardize mode scripts to package.json
add_standardize_package_json_scripts() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Apply surgical changes using yq if available
    if check_yq; then
        local yq_status=$?
        if [[ $yq_status -eq 2 ]] || [[ $yq_status -eq 3 ]]; then
            echo "Adding standardize scripts to package.json using yq (Python version)"
        fi

        # Base scripts for all Node.js projects (from boilerplate)
        yq eval '.scripts += {"preinstall": "npx only-allow pnpm"}' "$project_path/package.json" -i
        yq eval '.scripts += {"dev": "next dev --turbopack"}' "$project_path/package.json" -i
        yq eval '.scripts += {"build": "next build"}' "$project_path/package.json" -i
        yq eval '.scripts += {"start": "next start"}' "$project_path/package.json" -i
        yq eval '.scripts += {"lint": "eslint ."}' "$project_path/package.json" -i
        yq eval '.scripts += {"lint:fix": "eslint . --fix"}' "$project_path/package.json" -i
        yq eval '.scripts += {"clean": "rm -rf dist .next"}' "$project_path/package.json" -i
        yq eval '.scripts += {"clean:hard": "rm -rf dist .next node_modules"}' "$project_path/package.json" -i
        yq eval '.scripts += {"test": "vitest run"}' "$project_path/package.json" -i
        yq eval '.scripts += {"test:watch": "vitest"}' "$project_path/package.json" -i
        yq eval '.scripts += {"typecheck": "tsc --noEmit"}' "$project_path/package.json" -i

        # App-type specific scripts
        case "$app_type" in
            "web")
                yq eval '.scripts += {"export": "next build && next export"}' "$project_path/package.json" -i
                yq eval '.scripts += {"watchmode": "node --watch-path=. --watch-extensions=ts,tsx,js,jsx,json --eval \"console.log(\\\"Node watchmode active. Monitoring for changes...\\\")\""}' "$project_path/package.json" -i
                ;;
            "cli")
                yq eval '.scripts += {"start": "node dist/index.js"}' "$project_path/package.json" -i
                yq eval '.scripts += {"link": "npm link"}' "$project_path/package.json" -i
                ;;
            "api")
                yq eval '.scripts += {"dev:watch": "next dev --watch"}' "$project_path/package.json" -i
                ;;
        esac

        # Framework-specific scripts
        case "$project_type" in
            "frontend-web")
                if [[ -f "$project_path/next.config.js" ]]; then
                    yq eval '.scripts += {"export": "next build && next export"}' "$project_path/package.json" -i
                fi
                ;;
            "api-service")
                yq eval '.scripts += {"dev:watch": "next dev --watch"}' "$project_path/package.json" -i
                ;;
        esac

        # Additional utility scripts (from boilerplate)
        yq eval '.scripts += {"optimize-images": "node scripts/optimize-images.ts"}' "$project_path/package.json" -i
        yq eval '.scripts += {"yakbak:record": "node scripts/yakbak-proxy.mjs"}' "$project_path/package.json" -i
        yq eval '.scripts += {"yakbak:replay": "YAKBAK_NO_RECORD=1 node scripts/yakbak-proxy.mjs"}' "$project_path/package.json" -i

        # Testing scripts (from boilerplate)
        yq eval '.scripts += {"test:performance": "vitest run --project performance"}' "$project_path/package.json" -i
        yq eval '.scripts += {"test:integration": "vitest run --project integration"}' "$project_path/package.json" -i
        yq eval '.scripts += {"test:e2e:requirements": "vitest run --project e2e-requirements"}' "$project_path/package.json" -i
        yq eval '.scripts += {"test:e2e:usecases": "vitest run --project e2e-usecases"}' "$project_path/package.json" -i
        yq eval '.scripts += {"test:coverage": "vitest run --coverage"}' "$project_path/package.json" -i

        # Database scripts (if applicable)
        if [[ -f "$project_path/drizzle.config.ts" ]] || [[ -f "$project_path/package.json" ]] && grep -q "drizzle" "$project_path/package.json" 2>/dev/null; then
            yq eval '.scripts += {"db:setup": "npx tsx lib/db/setup.ts"}' "$project_path/package.json" -i
            yq eval '.scripts += {"db:seed": "npx tsx lib/db/seed.ts"}' "$project_path/package.json" -i
            yq eval '.scripts += {"db:generate": "drizzle-kit generate"}' "$project_path/package.json" -i
            yq eval '.scripts += {"db:migrate": "drizzle-kit migrate"}' "$project_path/package.json" -i
            yq eval '.scripts += {"db:studio": "drizzle-kit studio"}' "$project_path/package.json" -i
        fi

        log_info "✓ Added standardize scripts to package.json"
    else
        log_warn "yq not available, skipping package.json script updates"
    fi
}

# Add adopt mode scripts to package.json
add_adopt_package_json_scripts() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Apply surgical changes
    if check_yq; then
        local yq_status=$?
        if [[ $yq_status -eq 2 ]] || [[ $yq_status -eq 3 ]]; then
            echo "Adding adopt scripts to package.json using yq (Python version)"
        fi

        # Minimal essential scripts (from boilerplate)
        yq eval '.scripts += {"dev": "next dev --turbopack"}' "$project_path/package.json" -i
        yq eval '.scripts += {"build": "next build"}' "$project_path/package.json" -i
        yq eval '.scripts += {"test": "vitest run"}' "$project_path/package.json" -i
        yq eval '.scripts += {"lint": "eslint ."}' "$project_path/package.json" -i
        yq eval '.scripts += {"typecheck": "tsc --noEmit"}' "$project_path/package.json" -i

        log_info "✓ Added adopt scripts to package.json"
    else
        log_warn "yq not available, skipping package.json script updates"
    fi
}

# Add standardize mode dependencies
add_standardize_package_json_deps() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Apply surgical changes using yq if available
    if check_yq; then
        local yq_status=$?
        if [[ $yq_status -eq 2 ]] || [[ $yq_status -eq 3 ]]; then
            echo "Adding standardize dependencies to package.json using yq (Python version)"
        fi

        # Base dependencies (from boilerplate)
        yq eval '.dependencies += {"next": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"@job-aide/tools-platform-next-config": "workspace:*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"@antfu/ni": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"react": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"better-auth": "^1.1.1"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"@better-auth/drizzle-adapter": "^1.5.0-beta.9"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"better-all": "github.com/shuding/better-all"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"bcryptjs": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"class-variance-authority": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"clsx": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"dotenv": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"drizzle-kit": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"jose": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"lucide-react": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"only-allow": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"postgres": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"radix-ui": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"server-only": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"stripe": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"swr": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"tailwind-merge": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"tailwindcss": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"tw-animate-css": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"typescript": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"zod": "*"}' "$project_path/package.json" -i

        # Base dev dependencies (from boilerplate)
        yq eval '.devDependencies += {"@antfu/ni": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@browserbasehq/stagehand": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@job-aide/tools-lint-eslint-config": "workspace:*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@job-aide/tools-css-config": "workspace:*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@tailwindcss/postcss": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@testing-library/react": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@testing-library/jest-dom": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@testing-library/user-event": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@types/node": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@types/react": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@types/react-dom": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"autoprefixer": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"eslint": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"eslint-config-next": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"globby": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"imagemin": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"imagemin-mozjpeg": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"imagemin-pngquant": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"imagemin-webp": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"jsdom": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"modern-errors": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"modern-errors-beautiful": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"modern-errors-bugs": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"modern-errors-clean": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"modern-errors-cli": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"modern-errors-process": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"modern-errors-serialize": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"modern-errors-winston": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"only-allow": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"postcss": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"skillman": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"skills-detector": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"tailwindcss": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"typescript": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"vitest": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"yakbak": "*"}' "$project_path/package.json" -i

        # App-type specific dependencies
        case "$app_type" in
            "web")
                yq eval '.dependencies += {"@next/font": "*"}' "$project_path/package.json" -i
                ;;
            "cli")
                yq eval '.dependencies += {"commander": "^9.0.0"}' "$project_path/package.json" -i
                ;;
            "api")
                yq eval '.dependencies += {"express": "^4.18.0"}' "$project_path/package.json" -i
                yq eval '.dependencies += {"cors": "^2.8.5"}' "$project_path/package.json" -i
                ;;
        esac

        # Framework-specific dependencies
        case "$project_type" in
            "frontend-web")
                if [[ -f "$project_path/next.config.js" ]]; then
                    yq eval '.dependencies += {"@next/font": "*"}' "$project_path/package.json" -i
                fi
                ;;
            "api-service")
                yq eval '.dependencies += {"express": "^4.18.0"}' "$project_path/package.json" -i
                yq eval '.dependencies += {"helmet": "^6.0.0"}' "$project_path/package.json" -i
                ;;
        esac

        # Add engines configuration (from boilerplate)
        yq eval '.devEngines.runtime.name = "node"' "$project_path/package.json" -i
        yq eval '.devEngines.runtime.version = "*"' "$project_path/package.json" -i
        yq eval '.devEngines.packageManager.name = "pnpm"' "$project_path/package.json" -i
        yq eval '.devEngines.packageManager.version = "*"' "$project_path/package.json" -i
        yq eval '.engines.node = "*"' "$project_path/package.json" -i
        yq eval '.engines.pnpm = "*"' "$project_path/package.json" -i
        yq eval '.packageManager = "pnpm@*"' "$project_path/package.json" -i
        yq eval '.modeline = "/* vim: set ft=json: */"' "$project_path/package.json" -i

        log_info "✓ Added standardize dependencies to package.json"
    else
        log_warn "yq not available, skipping package.json dependency updates"
    fi
}

# Add adopt mode dependencies
add_adopt_package_json_deps() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Apply surgical changes
    if check_yq; then
        local yq_status=$?
        if [[ $yq_status -eq 2 ]] || [[ $yq_status -eq 3 ]]; then
            echo "Adding adopt dependencies to package.json using yq (Python version)"
        fi

        # Minimal essential dependencies (from boilerplate)
        yq eval '.dependencies += {"next": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"react": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"typescript": "*"}' "$project_path/package.json" -i
        yq eval '.dependencies += {"better-all": "github.com/shuding/better-all"}' "$project_path/package.json" -i

        # Minimal dev dependencies (from boilerplate)
        yq eval '.devDependencies += {"@types/node": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@types/react": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"@types/react-dom": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"eslint": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"eslint-config-next": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"skillman": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"skills-detector": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"typescript": "*"}' "$project_path/package.json" -i
        yq eval '.devDependencies += {"vitest": "*"}' "$project_path/package.json" -i

        log_info "✓ Added adopt dependencies to package.json"
    else
        log_warn "yq not available, skipping package.json dependency updates"
    fi
}

# Create package.json (based on boilerplate)
create_package_json() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/package.json" ]]; then
        local project_name
        project_name=$(basename "$project_path")

        cat > "$project_path/package.json" << EOF
{
  "name": "$project_name",
  "version": "0.0.1",
  "sha-version": "$Id$",
  "private": true,
  "description": "A Next.js TypeScript project",
  "type": "module",
  "scripts": {
    "preinstall": "npx only-allow pnpm",
    "dev": "next dev --turbopack",
    "build": "next build",
    "start": "next start",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "clean": "rm -rf dist .next",
    "clean:hard": "rm -rf dist .next node_modules",
    "test": "vitest run",
    "test:watch": "vitest",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "next": "*",
    "react": "*",
    "typescript": "*",
    "better-all": "github.com/shuding/better-all"
  },
  "devDependencies": {
    "@types/node": "*",
    "@types/react": "*",
    "@types/react-dom": "*",
    "eslint": "*",
    "eslint-config-next": "*",
    "skillman": "*",
    "skills-detector": "*",
    "typescript": "*",
    "vitest": "*"
  },
  "devEngines": {
    "runtime": {
      "name": "node",
      "version": "*"
    },
    "packageManager": {
      "name": "pnpm",
      "version": "*"
    }
  },
  "engines": {
    "node": "*",
    "pnpm": "*"
  },
  "packageManager": "pnpm@*",
  "modeline": "/* vim: set ft=json: */"
}
EOF

        log_info "✓ Created package.json"
    fi
}

# Configure Tailwind CSS (based on boilerplate)
configure_tailwind_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/tailwind.config.ts" ]]; then
        cat > "$project_path/tailwind.config.ts" << 'EOF'
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}

export default config
EOF
        log_info "✓ Created tailwind.config.ts"
    fi
}

# Configure PostCSS (based on boilerplate)
configure_postcss_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/postcss.config.js" ]]; then
        cat > "$project_path/postcss.config.js" << 'EOF'
module.exports = {
  plugins: {
    '@tailwindcss/postcss': {},
  },
}
EOF
        log_info "✓ Created postcss.config.js"
    fi
}

# Configure Vitest (based on boilerplate)
configure_vitest_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/vitest.config.mts" ]]; then
        cat > "$project_path/vitest.config.mts" << 'EOF'
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: {
      defineConfig: true,
    },
    environment: "node",
    setupFiles: ['./vitest.setup.ts'],
  },
  testEnvironment: "jsdom",
  include: ['src/**/*.{test,spec}.{js,ts,jsx,tsx}'],
  coverage: {
    provider: 'v8',
    reporter: ['text', 'html', 'lcov'],
    exclude: [
      'node_modules/',
      '.next/',
      'dist/',
      'coverage/'
    ]
  },
  projects: [
    {
      name: 'unit',
      testMatch: ['**/*.unit.{test,spec}.{js,ts,jsx,tsx}'],
      include: ['src/**/*'],
      exclude: ['**/node_modules/**', '**/.next/**', '**/dist/**']
    },
    {
      name: 'integration',
      testMatch: ['**/*.integration.{test,spec}.{js,ts,jsx,tsx}'],
      include: ['src/**/*'],
      exclude: ['**/node_modules/**', '**/.next/**', '**/dist/**']
    },
    {
      name: 'e2e-requirements',
      testMatch: ['**/e2e/requirements.{test,spec}.{js,ts,jsx,tsx}'],
      include: ['src/**/*'],
      exclude: ['**/node_modules/**', '**/.next/**', '**/dist/**']
    },
    {
      name: 'e2e-usecases',
      testMatch: ['**/e2e/usecases.{test,spec}.{js,ts,jsx,tsx}'],
      include: ['src/**/*'],
      exclude: ['**/node_modules/**', '**/.next/**', '**/dist/**']
    },
    {
      name: 'performance',
      testMatch: ['**/performance/**/*.{test,spec}.{js,ts,jsx,tsx}'],
      include: ['src/**/*'],
      exclude: ['**/node_modules/**', '**/.next/**', '**/dist/**']
    }
  ]
});
EOF
        log_info "✓ Created vitest.config.mts"
    fi
}

# Configure Playwright (based on boilerplate)
configure_playwright_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/playwright.config.ts" ]]; then
        cat > "$project_path/playwright.config.ts" << 'EOF'
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  timeout: 10 * 1000,
  expect: {
    timeout: 5000
  },
  use: {
    actionTimeout: 0,
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
  ],
});
EOF
        log_info "✓ Created playwright.config.ts"
    fi
}

# Configure TypeScript configuration (based on boilerplate)
configure_tsconfig_json() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"

    log_info "Configuring tsconfig.json"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/tsconfig.json" ]]; then
        # Create comprehensive tsconfig.json for standardize mode (based on boilerplate)
        cat > "$project_path/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "noEmit": true,
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", ".next"]
}
EOF
        log_info "✓ Created tsconfig.json"
    fi
}

# Configure ESLint (based on boilerplate)
configure_eslint_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/eslint.config.mts" ]]; then
        cat > "$project_path/eslint.config.mts" << 'EOF'
import { config } from '@job-aide/tools-lint-eslint-config';

export default config(config);
EOF
        log_info "✓ Created eslint.config.mts"
    fi
}

# Configure Prettier (based on boilerplate)
configure_prettier_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/.prettierrc" ]]; then
        cat > "$project_path/.prettierrc" << 'EOF'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2
}
EOF
        log_info "✓ Created .prettierrc"
    fi
}

# Configure framework-specific configs
configure_framework_configs() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    # Next.js configuration
    if [[ -f "$project_path/next.config.js" ]] || [[ -f "$project_path/next.config.mjs" ]] || [[ "$mode" == "standardize" ]]; then
        configure_nextjs_config "$project_path" "$mode" "$app_type" "$project_type"
    fi

    # Vite configuration
    if [[ -f "$project_path/vite.config.ts" ]] || [[ -f "$project_path/vite.config.js" ]] || [[ "$mode" == "standardize" ]]; then
        configure_vite_config "$project_path" "$mode" "$app_type" "$project_type"
    fi
}

# Configure Next.js (based on boilerplate)
configure_nextjs_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/next.config.js" ]]; then
        cat > "$project_path/next.config.js" << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    appDir: true,
    serverComponentsExternalPackages: ['@mui/material', '@mui/icons-material']
  },
  images: {
    domains: ['example.com'],
    formats: ['image/webp', 'image/avif']
  },
  webpack: (config, { isServer }) => {
    if (!isServer) {
      config.resolve.fallback = {
        fs: false,
        path: false,
        os: false
      }
    }
    return config
  }
}

module.exports = nextConfig
EOF
        log_info "✓ Created next.config.js"
    fi
}

# Configure Vite (based on boilerplate)
configure_vite_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/vite.config.ts" ]]; then
        cat > "$project_path/vite.config.ts" << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  build: {
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          router: ['react-router-dom']
        }
      }
    }
  },
  optimizeDeps: {
    include: ['react', 'react-dom', 'react-router-dom']
  }
})
EOF
        log_info "✓ Created vite.config.ts"
    fi
}

# Configure testing configs
configure_testing_configs() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"

    if [[ "$mode" == "standardize" ]]; then
        # Create test directories
        mkdir -p "$project_path/tests/unit"
        mkdir -p "$project_path/tests/integration"
        mkdir -p "$project_path/tests/e2e"

        # Create basic test files
        if [[ ! -f "$project_path/tests/unit/example.test.ts" ]]; then
            cat > "$project_path/tests/unit/example.test.ts" << 'EOF'
import { describe, it, expect } from 'vitest';

describe('Example test', () => {
  it('should pass', () => {
    expect(1 + 1).toBe(2);
  });
});
EOF
            log_info "✓ Created tests/unit/example.test.ts"
        fi

        # Create vitest setup file
        if [[ ! -f "$project_path/vitest.setup.ts" ]]; then
            cat > "$project_path/vitest.setup.ts" << 'EOF'
import '@testing-library/jest-dom';
EOF
            log_info "✓ Created vitest.setup.ts"
        fi
    fi
}

# Export functions for use by adopt-project.sh
export -f configure_nodejs_project
export -f configure_package_json
export -f create_package_json
export -f configure_tsconfig_json
export -f configure_eslint_config
export -f configure_prettier_config
export -f configure_tailwind_config
export -f configure_postcss_config
export -f configure_vitest_config
export -f configure_playwright_config
export -f configure_framework_configs
export -f configure_nextjs_config
export -f configure_vite_config
export -f configure_testing_configs
