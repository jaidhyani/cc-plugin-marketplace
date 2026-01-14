---
description: Restore deleted sessions from archive
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*)
---

# Restore From Archive Command

Restore sessions that have been deleted from the source but exist in the archive.

## Default Behavior

Restore all sessions that are missing from the source:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/restore.sh
```

## List Restorable Sessions

To see what can be restored without actually restoring:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/restore.sh --list
```

## Restore Specific Session

To restore a specific session by ID:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/restore.sh --session <session-id>
```

## Important Notes

- This command NEVER overwrites existing sessions in the source
- Only sessions that no longer exist in ~/.claude/projects/ will be restored
- Restored sessions will be available in Claude Code after restart

Ask the user what they want to do:
1. List restorable sessions first
2. Restore all missing sessions
3. Restore a specific session
