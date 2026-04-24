#!/usr/bin/env bash
# SessionStart hook — detect cc-catalogue staleness and spawn background sync.
#
# Design: fast (<100ms), silent on no-op, never blocks session start.
# The actual sync runs in a detached headless `claude -p` instance so this
# hook returns immediately and adds zero token cost to the live session.
#
# Logic:
#   cached == current  → skip
#   lock present       → skip (another sync in progress)
#   else               → acquire lock, spawn background sync, return
#
# State tracking IS the throttle: the sync only fires when the version
# actually changes. No time-based ceiling needed.

set -u

# Catalogue location precedence:
#   1. CC_CATALOGUE_DIR  — user override (e.g. project-local catalogue)
#   2. CLAUDE_PLUGIN_DATA — CC-managed persistent dir (survives plugin updates)
#   3. ~/.claude/cache/cc-catalogue — fallback if plugin context unavailable
CATALOGUE_DIR="${CC_CATALOGUE_DIR:-${CLAUDE_PLUGIN_DATA:-$HOME/.claude/cache/cc-catalogue}}"
VERSION_FILE="$CATALOGUE_DIR/VERSION"
LOCK_DIR="$CATALOGUE_DIR/.sync.lock"
LOG_FILE="$CATALOGUE_DIR/sync.log"

# First-run bootstrap: create the catalogue dir and seed from the plugin's
# scaffold so the agent has the expected layout on first sync.
if [ ! -d "$CATALOGUE_DIR" ]; then
  mkdir -p "$CATALOGUE_DIR/features" "$CATALOGUE_DIR/behaviors" 2>/dev/null || exit 0
  # Copy scaffold seeds if present (README, behaviors schema, empty outcomes).
  if [ -d "${CLAUDE_PLUGIN_ROOT:-}/features" ]; then
    cp -rn "$CLAUDE_PLUGIN_ROOT/features/." "$CATALOGUE_DIR/features/" 2>/dev/null || true
  fi
  if [ -d "${CLAUDE_PLUGIN_ROOT:-}/behaviors" ]; then
    cp -rn "$CLAUDE_PLUGIN_ROOT/behaviors/." "$CATALOGUE_DIR/behaviors/" 2>/dev/null || true
  fi
  [ -f "$CATALOGUE_DIR/outcomes.jsonl" ] || : > "$CATALOGUE_DIR/outcomes.jsonl"
fi

# `claude --version` outputs e.g. "2.1.101 (Claude Code)"
current=$(claude --version 2>/dev/null | awk '{print $1}')
[ -z "$current" ] && exit 0

cached=$(cat "$VERSION_FILE" 2>/dev/null || echo "none")

[ "$current" = "$cached" ] && exit 0

# Atomic lock acquisition. mkdir is atomic on POSIX filesystems —
# if another session got here first, we bail.
mkdir "$LOCK_DIR" 2>/dev/null || exit 0

# Spawn the sync, fully detached. The trap removes the lock on exit
# so a crashed sync doesn't leave us stuck.
#
# MCP_CONNECTION_NONBLOCKING=true (added 2.1.89) skips the MCP server connection
# wait at startup — caps server connection at 5s and lets the sync proceed
# without blocking on slow MCP servers. Pure perf, no auth implications.
nohup bash -c "
  trap 'rmdir \"$LOCK_DIR\" 2>/dev/null' EXIT
  echo \"[\$(date -Iseconds)] sync starting: $cached -> $current\" >> '$LOG_FILE'
  CC_CATALOGUE_DIR='$CATALOGUE_DIR' MCP_CONNECTION_NONBLOCKING=true claude -p 'Run cc-catalogue sync mode. cached_version=$cached current_version=$current. The catalogue lives at \$CC_CATALOGUE_DIR. Read the cc-catalogue agent definition for the full sync protocol, then execute it.' \
    --permission-mode bypassPermissions \
    --output-format json >> '$LOG_FILE' 2>&1
  echo \"[\$(date -Iseconds)] sync exited\" >> '$LOG_FILE'
" </dev/null >/dev/null 2>&1 &
disown

# Surface the launch in stderr so it shows up in session-start context.
echo "[cc-catalogue] sync launched in background ($cached -> $current)" >&2
exit 0
