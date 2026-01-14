---
description: Force immediate archive of all session transcripts
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*)
---

# Archive Command

Run the archive script to back up all session transcripts now.

Execute:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/archive.sh --full
```

After running, report:
- Whether the archive completed successfully
- The archive location (default: ~/.claude-archive)
