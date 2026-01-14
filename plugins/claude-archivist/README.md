# claude-archivist

Automatically archive Claude Code session transcripts to prevent data loss from automatic cleanup.

## Features

- **Automatic archival** on SessionEnd and PreCompact hooks
- **Periodic backup** during long sessions (configurable interval, default 30 min)
- **Incremental** - only archives files that have changed
- **Gzip compression** to save disk space
- **Safe restore** - never overwrites existing sessions

## Commands

| Command | Description |
|---------|-------------|
| `/claude-archivist:archive` | Force immediate backup of all sessions |
| `/claude-archivist:archive-status` | Show archive statistics |
| `/claude-archivist:restore-from-archive` | Restore deleted sessions |
| `/claude-archivist:configure-archive` | Configure plugin settings |

## Configuration

Settings are stored in `~/.claude/claude-archivist.local.md`:

```yaml
---
archive_path: ~/.claude-archive
backup_interval_minutes: 30
enabled: true
---
```

| Setting | Default | Description |
|---------|---------|-------------|
| `archive_path` | `~/.claude-archive` | Where archives are stored |
| `backup_interval_minutes` | `30` | Minutes between periodic backups |
| `enabled` | `true` | Enable/disable automatic archiving |

## How It Works

1. **SessionEnd hook**: Archives all sessions when you exit Claude Code
2. **PreCompact hook**: Archives before context compaction trims transcripts
3. **Stop hook**: Checks elapsed time after each response, backs up if interval exceeded

Archives mirror the source structure:
```
~/.claude-archive/
└── [encoded-project-path]/
    └── [session-uuid].jsonl.gz
```
