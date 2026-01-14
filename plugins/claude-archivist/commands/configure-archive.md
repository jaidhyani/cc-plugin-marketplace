---
description: Configure archive settings
allowed-tools: Read(*), Write(~/.claude/claude-archivist.local.md)
---

# Configure Archive Command

Configure the claude-archivist plugin settings.

## Configuration File

Settings are stored in `~/.claude/claude-archivist.local.md` with YAML frontmatter.

## Available Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `archive_path` | `~/.claude-archive` | Directory where archives are stored |
| `backup_interval_minutes` | `30` | Minutes between periodic backups during long sessions |
| `enabled` | `true` | Enable or disable automatic archiving |

## Example Configuration

```yaml
---
archive_path: ~/.claude-archive
backup_interval_minutes: 30
enabled: true
---
```

## Instructions

1. First, check if the config file exists and read current settings
2. Ask the user what they want to change
3. Write the updated configuration

If the file doesn't exist, create it with the user's desired settings or defaults.
