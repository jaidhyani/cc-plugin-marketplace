#!/bin/bash
set -e

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

if [[ -z "$SESSION_ID" ]]; then
    exit 0
fi

SESSION_DIR="$HOME/.claude/tracked-sessions/$SESSION_ID"
mkdir -p "$SESSION_DIR"

STARTED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
PID=$PPID

jq -n \
  --arg sid "$SESSION_ID" \
  --arg cwd "$CWD" \
  --arg started "$STARTED_AT" \
  --argjson pid "$PID" \
  '{session_id: $sid, pid: $pid, cwd: $cwd, started_at: $started, ended_at: null, status: "running"}' \
  > "$SESSION_DIR/meta.json"
