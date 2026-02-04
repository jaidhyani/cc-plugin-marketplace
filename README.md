# Claude Marketplace

Claude Code plugins by jaidhyani.

## Installation

Add this marketplace:
```bash
/plugin marketplace add jaidhyani/cc-plugin-marketplace
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
- `/claude-archivist:archive` - Archive current session
- `/claude-archivist:archive-all` - Archive all sessions (full scan)
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

### tracked-sessions

Track Claude Code session lifecycle for monitoring and resume workflows across git worktrees.

**Install:**
```bash
/plugin install tracked-sessions@cc-plugin-marketplace
```

**Features:**
- Tracks session start/end with metadata (session ID, PID, working directory, timestamps)
- Session data stored at `~/.claude/tracked-sessions/<session-id>/meta.json`
- Integrates with `wt` worktree slots (a-f)

**CLI Tool (separate install):**

The `cs` command-line tool for listing and managing sessions is available from [jaidhyani/claude-config](https://github.com/jaidhyani/claude-config):

```bash
# Copy to your ~/.claude/bin/
curl -o ~/.claude/bin/cs https://raw.githubusercontent.com/jaidhyani/claude-config/main/bin/cs
chmod +x ~/.claude/bin/cs
```

**CLI Commands:**
- `cs list` - Show all tracked sessions with git status
- `cs start <slot> "<prompt>"` - Launch headless session in worktree
- `cs attach <slot>` - Resume session interactively
- `cs resume <slot> "<prompt>"` - Continue session headless
- `cs stop <slot>` - Kill running session
- `cs clean` - Remove stale session directories
