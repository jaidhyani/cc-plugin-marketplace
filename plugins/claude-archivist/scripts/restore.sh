#!/bin/bash
set -e

MODE="restore"
SESSION_FILTER=""

while [ $# -gt 0 ]; do
    case "$1" in
        --list)
            MODE="list"
            shift
            ;;
        --session)
            SESSION_FILTER="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

CONFIG_FILE="$HOME/.claude/claude-archivist.local.md"
SOURCE_DIR="$HOME/.claude/projects"
DEFAULT_ARCHIVE_DIR="$HOME/.claude-archive"

read_config() {
    ARCHIVE_DIR="$DEFAULT_ARCHIVE_DIR"

    if [ -f "$CONFIG_FILE" ]; then
        local in_frontmatter=false
        while IFS= read -r line; do
            if [ "$line" = "---" ]; then
                if [ "$in_frontmatter" = false ]; then
                    in_frontmatter=true
                else
                    break
                fi
                continue
            fi

            if [ "$in_frontmatter" = true ]; then
                case "$line" in
                    archive_path:*)
                        ARCHIVE_DIR=$(echo "$line" | cut -d: -f2- | xargs)
                        ARCHIVE_DIR="${ARCHIVE_DIR/#\~/$HOME}"
                        ;;
                esac
            fi
        done < "$CONFIG_FILE"
    fi
}

list_restorable() {
    if [ ! -d "$ARCHIVE_DIR" ]; then
        echo "No archive found at $ARCHIVE_DIR"
        return
    fi

    local count=0
    while IFS= read -r -d '' archive_file; do
        local relative_path="${archive_file#$ARCHIVE_DIR/}"
        relative_path="${relative_path%.gz}"
        local source_file="$SOURCE_DIR/$relative_path"

        if [ ! -f "$source_file" ]; then
            local session_id=$(basename -- "$relative_path" .jsonl)
            local project_path=$(dirname -- "$relative_path")
            local size=$(stat -c %s "$archive_file" 2>/dev/null || stat -f %z "$archive_file")
            local mtime=$(stat -c %Y "$archive_file" 2>/dev/null || stat -f %m "$archive_file")
            local date_str=$(date -d "@$mtime" "+%Y-%m-%d %H:%M" 2>/dev/null || date -r "$mtime" "+%Y-%m-%d %H:%M")

            echo "$session_id|$project_path|$size|$date_str"
            count=$((count + 1))
        fi
    done < <(find "$ARCHIVE_DIR" -name "*.jsonl.gz" -type f -print0 2>/dev/null)

    if [ "$count" -eq 0 ]; then
        echo "No sessions need restoration (all archived sessions exist in source)"
    fi
}

restore_sessions() {
    if [ ! -d "$ARCHIVE_DIR" ]; then
        echo "No archive found at $ARCHIVE_DIR" >&2
        exit 1
    fi

    local restored_count=0
    local skipped_count=0

    while IFS= read -r -d '' archive_file; do
        local relative_path="${archive_file#$ARCHIVE_DIR/}"
        relative_path="${relative_path%.gz}"
        local source_file="$SOURCE_DIR/$relative_path"
        local session_id=$(basename -- "$relative_path" .jsonl)

        if [ -n "$SESSION_FILTER" ] && [ "$session_id" != "$SESSION_FILTER" ]; then
            continue
        fi

        if [ -f "$source_file" ]; then
            skipped_count=$((skipped_count + 1))
            continue
        fi

        local source_parent=$(dirname "$source_file")
        mkdir -p "$source_parent"
        gunzip -c "$archive_file" > "$source_file"
        restored_count=$((restored_count + 1))
        echo "Restored: $relative_path"
    done < <(find "$ARCHIVE_DIR" -name "*.jsonl.gz" -type f -print0 2>/dev/null)

    echo "---"
    echo "Restored: $restored_count sessions"
    echo "Skipped (already exist): $skipped_count sessions"
}

main() {
    read_config

    case "$MODE" in
        list)
            list_restorable
            ;;
        restore)
            restore_sessions
            ;;
    esac
}

main
