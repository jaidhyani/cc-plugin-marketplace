#!/bin/bash
# Timestamp tracking for Claude
# Stop hook writes to file, UserPromptSubmit reads and outputs to Claude

TIMESTAMP_FILE="/tmp/claude-last-response.txt"
EVENT_TYPE="${1:-event}"

if [ "$EVENT_TYPE" = "stop" ]; then
    # Record when Claude finished responding
    date '+%Y-%m-%d %H:%M:%S %Z' > "$TIMESTAMP_FILE"
    exit 0
fi

if [ "$EVENT_TYPE" = "submit" ]; then
    NOW=$(date '+%Y-%m-%d %H:%M:%S %Z')

    if [ -f "$TIMESTAMP_FILE" ]; then
        LAST_RESPONSE=$(cat "$TIMESTAMP_FILE")
        CONTEXT="[Timestamps] User submitted: $NOW | Claude last responded: $LAST_RESPONSE"
    else
        CONTEXT="[Timestamps] User submitted: $NOW | (no previous response recorded)"
    fi

    # Output as JSON with additionalContext (hidden from user, visible to Claude)
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "$CONTEXT"
  }
}
EOF
    exit 0
fi
