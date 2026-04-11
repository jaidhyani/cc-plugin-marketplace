#!/bin/bash
# Canonical environment for cron-invoked scripts.
#
# Usage: source at the top of any script that runs under cron:
#   source "$(dirname "$(readlink -f "$0")")/lib/cron-env.sh"
#
# Cron's default PATH is `/usr/bin:/bin` — it does not see anything in $HOME
# or any language version manager. Scripts that call `uv`, `node`, `qmd`, etc.
# will die with `command not found` unless PATH is extended here.
#
# Tool inventory is enforced by scripts/test-cron-env.sh — update the
# REQUIRED_TOOLS list there when adding a new external dependency.

# nvm: resolve the default node version dynamically so node upgrades don't
# bitrot hardcoded paths.
_nvm_default=""
if [[ -r "$HOME/.nvm/alias/default" ]]; then
  _nvm_default=$(cat "$HOME/.nvm/alias/default" 2>/dev/null || true)
fi
_nvm_node_dir=""
if [[ -n "$_nvm_default" ]]; then
  # alias may be "22" or "v22.19.0" — try exact match then glob
  if [[ -d "$HOME/.nvm/versions/node/$_nvm_default" ]]; then
    _nvm_node_dir="$HOME/.nvm/versions/node/$_nvm_default"
  else
    _nvm_node_dir=$(ls -d "$HOME/.nvm/versions/node/v${_nvm_default}"* 2>/dev/null | sort -V | tail -1)
  fi
fi
# Fallback: newest installed version.
if [[ -z "$_nvm_node_dir" ]]; then
  _nvm_node_dir=$(ls -d "$HOME/.nvm/versions/node/v"* 2>/dev/null | sort -V | tail -1)
fi

# Build PATH. Order matters: user-local bins first, then nvm, then system.
_cron_path="$HOME/.local/bin"
[[ -n "$_nvm_node_dir" && -d "$_nvm_node_dir/bin" ]] && _cron_path="$_cron_path:$_nvm_node_dir/bin"
_cron_path="$_cron_path:/usr/local/bin:/usr/bin:/bin"

export PATH="$_cron_path"

unset _nvm_default _nvm_node_dir _cron_path
