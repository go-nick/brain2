#!/usr/bin/env bash
set -euo pipefail

VAULT_DIR="$HOME/...."
OBSIDIAN_MD="$VAULT_DIR/OBSIDIAN.md"
indexed=0
skipped=0

# Cyberpunk colors
GREEN='\033[38;5;82m'
PINK='\033[38;5;213m'
BLUE='\033[38;5;51m'
RESET='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${RESET}  $*"; }
log_idx()  { echo -e "${PINK}[IDX]${RESET}   $*"; }
log_skip() { echo -e "${BLUE}[SKIP]${RESET}  $*"; }

find_md_files() {
    find "$VAULT_DIR" -mindepth 1 -maxdepth 1 -type d -name '[0-9]*' -print0 \
        | xargs -0 -I{} find {} -name "*.md" -type f \
            -not -path "*/.obsidian/*" \
            -not -path "*/_*/*" \
            -not -name "_index_.md" \
        | sort
}

extract_frontmatter() {
    local file="$1"
    awk 'NR==1 && /^---$/{found=1; next} found && /^---$/{exit} found' "$file"
}

extract_tags() {
    local fm="$1"
    local tags_line
    tags_line=$(echo "$fm" | grep "^tags:" || true)
    if [[ -n "$tags_line" ]]; then
        echo "$tags_line" | sed 's/^tags:[[:space:]]*//' | sed 's/^\[//; s/\]$//'
    else
        echo "$fm" | grep "^[[:space:]]*- " | sed 's/^[[:space:]]*- //' | tr '\n' ',' | sed 's/,$//'
    fi
}

extract_keywords() {
    local fm="$1"
    echo "$fm" | grep "^keywords:" | sed 's/^keywords:[[:space:]]*//' || true
}

generate_table() {
    local outfile="$1"

    {
        echo "| file | tags | keywords |"
        echo "|------|------|----------|"
    } > "$outfile"

    while IFS= read -r file; do
        local rel_path="${file#"$VAULT_DIR/"}"
        local fm
        fm=$(extract_frontmatter "$file")

        if [[ -z "$fm" ]]; then
            log_skip "$rel_path (no frontmatter)"
            skipped=$((skipped + 1))
            continue
        fi

        local tags keywords
        tags=$(extract_tags "$fm")
        keywords=$(extract_keywords "$fm")

        echo "| $rel_path | $tags | $keywords |" >> "$outfile"
        log_idx "$rel_path"
        indexed=$((indexed + 1))
    done < <(find_md_files)
}

update_index() {
    local table_file="$1"
    local tmp
    tmp=$(mktemp)

    awk -v tf="$table_file" '
        /<!-- INDEX:START -->/ {
            print
            print ""
            while ((getline line < tf) > 0) print line
            print ""
            skip=1; next
        }
        /<!-- INDEX:END -->/ { skip=0 }
        !skip { print }
    ' "$OBSIDIAN_MD" > "$tmp"

    mv "$tmp" "$OBSIDIAN_MD"
}

main() {
    log_info "building index → $OBSIDIAN_MD"
    echo ""

    local table_file
    table_file=$(mktemp)

    generate_table "$table_file"

    echo ""
    log_info "injecting table into OBSIDIAN.md"
    update_index "$table_file"
    rm -f "$table_file"

    echo ""
    log_info "done. indexed: $indexed | skipped (no frontmatter): $skipped"
}

main "$@"
