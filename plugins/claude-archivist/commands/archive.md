---
description: Archive the current session transcript
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*), Bash(find:*), Bash(head:*)
---

# Archive Current Session

Archive the most recently modified session in the current project.

First, find the current project's session directory and most recent session:
```bash
PROJECT_DIR=$(echo "$PWD" | sed 's|/|-|g')
SESSION_DIR="$HOME/.claude/projects/$PROJECT_DIR"
LATEST=$(find "$SESSION_DIR" -name "*.jsonl" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
```

Then archive it:
```bash
echo "{\"transcript_path\": \"$LATEST\"}" | ${CLAUDE_PLUGIN_ROOT}/scripts/archive.sh
```

Report whether the archive completed successfully.
