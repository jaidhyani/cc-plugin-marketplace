---
description: Archive all session transcripts (full scan)
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*)
---

# Archive All Sessions

Run a full scan and archive all session transcripts.

Execute:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/archive.sh --full
```

After running, report:
- Whether the archive completed successfully
- The archive location (default: ~/.claude-archive)
