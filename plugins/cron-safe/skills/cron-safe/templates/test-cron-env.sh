#!/bin/bash
# Static check: verify every tool required by cron-invoked scripts is
# resolvable in a cron-like environment after sourcing lib/cron-env.sh.
#
# This does NOT execute any cron script — it only checks `command -v` for
# each required tool in the central list below. Safe to run anywhere.
#
# Wire this as the first step of any nightly orchestrator so a broken cron
# PATH aborts before any real work runs. Run manually with:
#   bash scripts/test-cron-env.sh
#
# When adding a new tool to any cron-invoked script, add it to
# REQUIRED_TOOLS below.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB="$SCRIPT_DIR/lib/cron-env.sh"

# Central list of tools any cron-invoked script may call.
# Keep this in sync with what's actually used — missing tools here mean
# missing coverage, not a test failure.
#
# Customize this list for your repo. Common entries:
#   python3 jq curl git    — almost always needed
#   uv pipx                — if using Python tool installers
#   node npm npx           — if using nvm-managed node tools
#   docker docker-compose  — if cron manages containers
#   rsync pg_dump ffmpeg   — domain-specific tools
REQUIRED_TOOLS=(
  python3
  jq
  curl
)

if [[ ! -r "$LIB" ]]; then
  echo "FAIL: $LIB not found" >&2
  exit 1
fi

# Run the check in a cron-like environment: empty env, only HOME + minimal PATH.
# Pass the lib path and tool list as positional args to avoid quoting hell.
output=$(env -i HOME="$HOME" PATH="/usr/bin:/bin" bash -c '
  set -euo pipefail
  source "$1"
  shift
  missing=()
  for tool in "$@"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      missing+=("$tool")
    fi
  done
  if (( ${#missing[@]} > 0 )); then
    echo "PATH=$PATH"
    echo "missing: ${missing[*]}"
    exit 1
  fi
  echo "PATH=$PATH"
  echo "ok: all $# tools resolved"
' _ "$LIB" "${REQUIRED_TOOLS[@]}" 2>&1) && status=0 || status=$?

echo "$output"
exit "$status"
