#!/bin/bash

CONFIG_FILE="$HOME/.claude/claude-archivist.local.md"
ARCHIVE_DIR="$HOME/.claude-archive"
SETUP_MARKER="$ARCHIVE_DIR/.setup-complete"
DEFER_MARKER="$ARCHIVE_DIR/.setup-deferred"

# Check if setup is complete or user declined
if [ -f "$SETUP_MARKER" ]; then
    exit 0
fi

# Check if user deferred - if so, remove defer marker so we ask again
if [ -f "$DEFER_MARKER" ]; then
    rm -f "$DEFER_MARKER"
fi

# Check if archive directory exists and has content (user may have run manually)
if [ -d "$ARCHIVE_DIR" ] && [ "$(find "$ARCHIVE_DIR" -name "*.jsonl.gz" -type f 2>/dev/null | head -1)" ]; then
    # Already has archives, mark as complete
    mkdir -p "$ARCHIVE_DIR"
    touch "$SETUP_MARKER"
    exit 0
fi

# First run - output JSON with context for Claude
cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "The claude-archivist plugin is installed but hasn't done an initial archive yet.\n\nAsk the user if they'd like to run a full archive of all existing sessions now. Present these options:\n\n1. **Archive now** - Run a full backup of all sessions (recommended)\n2. **Remind me later** - Skip for now, ask again next session\n3. **Don't ask again** - Skip and never prompt about this\n\nBased on their choice:\n- If \"Archive now\": Run `/archive-all` then run `touch ~/.claude-archive/.setup-complete`\n- If \"Remind me later\": Run `mkdir -p ~/.claude-archive && touch ~/.claude-archive/.setup-deferred`\n- If \"Don't ask again\": Run `mkdir -p ~/.claude-archive && touch ~/.claude-archive/.setup-complete`"
  }
}
EOF
