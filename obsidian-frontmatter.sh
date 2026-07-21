#!/usr/bin/env bash
set -euo pipefail

VAULT_DIR="$HOME/...."
TEMPLATE="$HOME/..../obsidian-frontmatter-template.md"
INDEX_TEMPLATE="$HOME/...../obsidian-index-frontmatter-template.md"
DRY_RUN=true
added=0
skipped=0
warnings=0

# Cyberpunk colors
GREEN='\033[38;5;82m'   # INFO
PINK='\033[38;5;213m'   # DEBUG  — [ADD]
BLUE='\033[38;5;51m'    # DEBUG2 — [SKIP]
ORANGE='\033[38;5;208m' # WARN — naming convention violation
RESET='\033[0m'

log_info()   { echo -e "${GREEN}[INFO]${RESET}  $*"; }
log_add()    { echo -e "${PINK}[ADD]${RESET}   $*"; }
log_skip()   { echo -e "${BLUE}[SKIP]${RESET}  $*"; }
log_warn()   { echo -e "${ORANGE}[WARN]${RESET}  $*"; }

usage() {
    echo "Usage: $0 [--run]"
    echo "  default: dry-run — no files modified"
    echo "  --run:   apply changes"
}

# Naming rule: folders ALL_CAPS_WITH_UNDERSCORE, files PascalCase.
# Exception: files named exactly "_index_.md" (folder index/MOC marker).
# See FRONTMATTER.md — "Naming Convention".
find_md_files() {
    find "$VAULT_DIR" -mindepth 1 -maxdepth 1 -type d -name '[0-9]*' -print0 \
        | xargs -0 -I{} find {} -name "*.md" -type f \
            -not -path "*/.obsidian/*" \
            -not -path "*/_*/*" \
        | sort
}

has_frontmatter() {
    local file="$1"
    [[ "$(head -1 "$file")" == "---" ]]
}

is_index_file() {
    local file="$1"
    [[ "$(basename "$file")" == "_index_.md" ]]
}

prepend_frontmatter() {
    local file="$1"
    local template="$2"
    local tmp
    tmp=$(mktemp)
    cat "$template" "$file" > "$tmp"
    mv "$tmp" "$file"
}

lint_naming() {
    local file="$1"
    local rel_path="${file#"$VAULT_DIR/"}"
    local base
    base=$(basename "$file" .md)
    local dir_path
    dir_path=$(dirname "$rel_path")

    # Folder segments must be ALL_CAPS_WITH_UNDERSCORE (digits/underscore allowed for numeric prefixes)
    local IFS='/'
    local seg
    for seg in $dir_path; do
        [[ "$seg" == "." ]] && continue
        if ! [[ "$seg" =~ ^[0-9]*[A-Z0-9_]+$ ]]; then
            log_warn "$rel_path — folder '$seg' not ALL_CAPS_WITH_UNDERSCORE"
            warnings=$((warnings + 1))
        fi
    done

    # Filenames must be PascalCase, except the literal "_index_" marker
    if [[ "$base" != "_index_" ]] && ! [[ "$base" =~ ^[A-Z][A-Za-z0-9]*$ ]]; then
        log_warn "$rel_path — filename not PascalCase"
        warnings=$((warnings + 1))
    fi
}

process_file() {
    local file="$1"

    lint_naming "$file"

    if has_frontmatter "$file"; then
        log_skip "$file"
        skipped=$((skipped + 1))
        return
    fi

    local template="$TEMPLATE"
    is_index_file "$file" && template="$INDEX_TEMPLATE"

    if $DRY_RUN; then
        log_add "$file"
    else
        prepend_frontmatter "$file" "$template"
        log_add "$file"
    fi

    added=$((added + 1))
}

main() {
    for arg in "$@"; do
        case "$arg" in
            --run)    DRY_RUN=false ;;
            --help|-h) usage; exit 0 ;;
            *) echo "unknown flag: $arg"; usage; exit 1 ;;
        esac
    done

    if $DRY_RUN; then
        log_info "dry-run mode — no files modified, pass --run to apply"
        log_info "frontmatter that would be prepended (from $TEMPLATE):"
        while IFS= read -r line; do
            log_info "  $line"
        done < "$TEMPLATE"
        echo ""
    else
        log_info "run mode — files will be modified"
        echo ""
    fi

    while IFS= read -r file; do
        process_file "$file"
    done < <(find_md_files)

    echo ""
    log_info "done. added: $added | skipped (has frontmatter): $skipped | naming warnings: $warnings"
}

main "$@"
