#!/bin/bash
# Validate Role IDs
# Checks for duplicate role IDs in organization structure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
YAML_FILE="$SKILL_DIR/references/organization-structure.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging
log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
warn() { echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"; }
error() { echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"; exit 1; }

# Check for duplicate role IDs
check_duplicates() {
    log "Checking for duplicate role IDs..."
    
    local duplicates
    duplicates=$(awk '/id: / {print $2}' "$YAML_FILE" | sort | uniq -d)
    
    if [[ -n "$duplicates" ]]; then
        error "Duplicate role IDs found:"
        echo "$duplicates"
        return 1
    else
        log "No duplicate role IDs found"
        return 0
    fi
}

# Check that all reports_to references exist
check_references() {
    log "Checking reference validity..."
    
    local temp_dir="/tmp/role-validation-$$"
    mkdir -p "$temp_dir"
    
    # Extract all role IDs
    awk '/id: / {print $2}' "$YAML_FILE" | sort -u > "$temp_dir/ids"
    
    # Extract all reports_to references
    grep -o "reports_to: [^\"]*" "$YAML_FILE" | sed 's/reports_to: //' | sort -u > "$temp_dir/references"
    
    # Find references that don't exist as IDs
    local invalid_refs
    invalid_refs=$(comm -23 "$temp_dir/references" "$temp_dir/ids")
    
    if [[ -n "$invalid_refs" ]]; then
        error "Invalid references found (reports_to values that don't exist as role IDs):"
        echo "$invalid_refs"
        rm -rf "$temp_dir"
        return 1
    else
        log "All references are valid"
        rm -rf "$temp_dir"
        return 0
    fi
}

# Check ID format compliance
check_format() {
    log "Checking ID format compliance..."
    
    local invalid_ids
    invalid_ids=$(grep -o "id: [^\"]*" "$YAML_FILE" | grep -v "id: [a-z0-9-]*$")
    
    if [[ -n "$invalid_ids" ]]; then
        error "Invalid ID formats found (should only contain lowercase letters, numbers, and hyphens):"
        echo "$invalid_ids"
        return 1
    else
        log "All ID formats are valid"
        return 0
    fi
}

# Main validation
main() {
    log "Starting role ID validation..."
    
    if [[ ! -f "$YAML_FILE" ]]; then
        error "YAML file not found: $YAML_FILE"
    fi
    
    local errors=0
    
    check_duplicates || ((errors++))
    check_references || ((errors++))
    check_format || ((errors++))
    
    if [[ $errors -eq 0 ]]; then
        log "All validations passed!"
    else
        error "$errors validation(s) failed"
    fi
}

main "$@"
