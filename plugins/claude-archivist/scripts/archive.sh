#!/bin/bash
set -e

PERIODIC_MODE=false
if [ "$1" = "--periodic" ]; then
    PERIODIC_MODE=true
fi

CONFIG_FILE="$HOME/.claude/claude-archivist.local.md"
SOURCE_DIR="$HOME/.claude/projects"
DEFAULT_ARCHIVE_DIR="$HOME/.claude-archive"
DEFAULT_INTERVAL_MINUTES=30
LAST_BACKUP_FILE="$DEFAULT_ARCHIVE_DIR/.last-backup-timestamp"

read_config() {
    ARCHIVE_DIR="$DEFAULT_ARCHIVE_DIR"
    INTERVAL_MINUTES="$DEFAULT_INTERVAL_MINUTES"
    ENABLED="true"

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
                    backup_interval_minutes:*)
                        INTERVAL_MINUTES=$(echo "$line" | cut -d: -f2- | xargs)
                        ;;
                    enabled:*)
                        ENABLED=$(echo "$line" | cut -d: -f2- | xargs)
                        ;;
                esac
            fi
        done < "$CONFIG_FILE"
    fi

    LAST_BACKUP_FILE="$ARCHIVE_DIR/.last-backup-timestamp"
}

should_run_periodic() {
    if [ ! -f "$LAST_BACKUP_FILE" ]; then
        return 0
    fi

    local last_backup=$(cat "$LAST_BACKUP_FILE")
    local now=$(date +%s)
    local interval_seconds=$((INTERVAL_MINUTES * 60))
    local elapsed=$((now - last_backup))

    if [ "$elapsed" -ge "$interval_seconds" ]; then
        return 0
    fi
    return 1
}

archive_file() {
    local source_file="$1"
    local relative_path="${source_file#$SOURCE_DIR/}"
    local archive_file="$ARCHIVE_DIR/$relative_path.gz"
    local archive_parent=$(dirname "$archive_file")

    if [ -f "$archive_file" ]; then
        local source_mtime=$(stat -c %Y "$source_file" 2>/dev/null || stat -f %m "$source_file")
        local archive_mtime=$(stat -c %Y "$archive_file" 2>/dev/null || stat -f %m "$archive_file")

        if [ "$source_mtime" -le "$archive_mtime" ]; then
            return 0
        fi
    fi

    mkdir -p "$archive_parent"
    gzip -c "$source_file" > "$archive_file"
}

archive_all_sessions() {
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "Source directory $SOURCE_DIR not found" >&2
        exit 1
    fi

    local archived_count=0

    while IFS= read -r -d '' file; do
        if archive_file "$file"; then
            archived_count=$((archived_count + 1))
        fi
    done < <(find "$SOURCE_DIR" -name "*.jsonl" -type f -print0 2>/dev/null)

    date +%s > "$LAST_BACKUP_FILE"
}

main() {
    read_config

    if [ "$ENABLED" != "true" ]; then
        exit 0
    fi

    if [ "$PERIODIC_MODE" = true ]; then
        if ! should_run_periodic; then
            exit 0
        fi
    fi

    mkdir -p "$ARCHIVE_DIR"
    archive_all_sessions
}

main
