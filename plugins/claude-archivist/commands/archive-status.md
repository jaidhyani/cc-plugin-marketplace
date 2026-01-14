---
description: Show archive status and statistics
allowed-tools: Bash(find:*), Bash(wc:*), Bash(du:*), Bash(cat:*), Bash(stat:*), Bash(date:*)
---

# Archive Status Command

Show statistics about the session archive.

Gather and report the following information:

1. **Configuration**:
   - Read from `~/.claude/claude-archivist.local.md` if it exists
   - Show archive path (default: ~/.claude-archive)
   - Show backup interval setting

2. **Archive Statistics**:
   - Total number of archived sessions: `find ~/.claude-archive -name "*.jsonl.gz" -type f | wc -l`
   - Total archive size: `du -sh ~/.claude-archive`
   - Last backup timestamp: read from `~/.claude-archive/.last-backup-timestamp`

3. **Source Statistics**:
   - Total sessions in source: `find ~/.claude/projects -name "*.jsonl" -type f | wc -l`
   - Sessions not yet archived (if any)

4. **Restorable Sessions**:
   - Count of sessions that exist in archive but not in source (can be restored)

Present this information in a clear, readable format.
