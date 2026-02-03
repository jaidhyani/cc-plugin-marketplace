# Claude Code Plugin Marketplace

This is Jai's personal plugin marketplace for Claude Code plugins.

## Plugin Structure

Each plugin lives in `plugins/<plugin-name>/` with:
- `.claude-plugin/plugin.json` - manifest with name, version, description
- `hooks/hooks.json` - hook definitions (if using hooks)
- `hooks/*.sh` - hook scripts
- `commands/*.md` - slash commands
- `skills/*.md` - skills

## Hooks

### hooks.json Structure

**IMPORTANT:** The hooks.json file MUST have a top-level `hooks` key wrapping the event types.

Correct structure:
```json
{
  "hooks": {
    "EventName": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/script.sh"
          }
        ]
      }
    ]
  }
}
```

Wrong (missing `hooks` wrapper):
```json
{
  "EventName": [...]
}
```

### Hook Events

Available events: `PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop`, `SessionStart`, `SessionEnd`, `UserPromptSubmit`, `PreCompact`, `Notification`

### Session-Specific State

Hooks receive JSON input on stdin with `session_id`. Use this for session-specific state files:

```bash
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')
STATE_FILE="/tmp/myplugin-${SESSION_ID}.txt"
```

Never use a single global file for state that should be per-session.

## Versioning

Bump the version in `plugin.json` for each release so users can see updates are available.
