#!/bin/bash
set -e

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

if [[ -z "$SESSION_ID" ]]; then
    exit 0
fi

META_FILE="$HOME/.claude/tracked-sessions/$SESSION_ID/meta.json"

if [[ ! -f "$META_FILE" ]]; then
    exit 0
fi

ENDED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

TMP=$(mktemp)
jq --arg ended "$ENDED_AT" '.ended_at = $ended | .status = "stopped"' "$META_FILE" > "$TMP"
mv "$TMP" "$META_FILE"
