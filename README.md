# Claude Marketplace

Claude Code plugins by jaidhyani.

## Installation

Add this marketplace:
```bash
/plugin marketplace add jaidhyani/claude-marketplace
```

## Available Plugins

### claude-archivist

Automatically archive Claude Code session transcripts to prevent data loss.

**Install:**
```bash
/plugin install claude-archivist@cc-plugin-marketplace
```

**Features:**
- Archives sessions on SessionEnd, PreCompact, and periodically during long sessions
- Incremental backup - only copies changed files
- Gzip compression
- Mirrors source directory structure to `~/.claude-archive/`
- Restore deleted sessions without overwriting existing ones

**Commands:**
- `/claude-archivist:archive` - Force immediate backup
- `/claude-archivist:archive-status` - Show backup statistics
- `/claude-archivist:restore-from-archive` - Restore deleted sessions
- `/claude-archivist:configure-archive` - Configure settings

**Configuration:**

Create `~/.claude/claude-archivist.local.md`:
```yaml
---
archive_path: ~/.claude-archive
backup_interval_minutes: 30
enabled: true
---
```
