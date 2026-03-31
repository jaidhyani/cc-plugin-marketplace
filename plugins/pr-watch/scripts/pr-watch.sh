#!/bin/bash
# pr-watch.sh - Block until open PR state changes
#
# Captures a baseline snapshot of open PRs (commit count, mergeable status,
# updatedAt) and polls every INTERVAL seconds. Exits with the before/after
# diff as soon as any PR changes.
#
# Usage: pr-watch.sh [--author AUTHOR] [--interval SECONDS]
#   --author   GitHub author filter (default: "@me")
#   --interval Seconds between checks (default: 60)

set -euo pipefail

AUTHOR="@me"
INTERVAL=60

while [[ $# -gt 0 ]]; do
    case "$1" in
        --author)  AUTHOR="$2"; shift 2 ;;
        --interval) INTERVAL="$2"; shift 2 ;;
        *) echo "Unknown arg: $1" >&2; exit 1 ;;
    esac
done

snapshot() {
    gh pr list --author "$AUTHOR" --state open \
        --json number,title,mergeable,commits,updatedAt \
        --jq '[.[] | {number, title, mergeable, commits: (.commits | length), updatedAt}] | sort_by(.number)'
}

BASELINE=$(snapshot)

while true; do
    sleep "$INTERVAL"
    CURRENT=$(snapshot) || continue
    if [ "$CURRENT" != "$BASELINE" ]; then
        echo "=== CHANGE DETECTED ==="
        echo "BEFORE:"
        echo "$BASELINE"
        echo "AFTER:"
        echo "$CURRENT"
        exit 0
    fi
done
