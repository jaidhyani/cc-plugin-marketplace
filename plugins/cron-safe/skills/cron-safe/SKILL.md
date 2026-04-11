---
name: cron-safe
description: This skill should be used when the user asks to "add a cron job", "create a cron script", "write a cron entry", "schedule a recurring script", "set up a crontab", "add to crontab", "fix cron PATH", "cron command not found", "cron job not running", "works manually but fails in cron", or when editing any script that is invoked from `crontab -l`. Ensures cron-invoked scripts use a shared PATH setup and verifies required tools are resolvable in cron's minimal environment.
---

# cron-safe

Cron runs with a near-empty environment — PATH is `/usr/bin:/bin`, so nvm/pyenv/`~/.local/bin` tools fail with `command not found`. This skill installs a shared env file for the cron script you're currently working on, plus a static test that verifies the tools it needs are resolvable. The infra is reusable: other cron scripts in the repo can opt in later, but this skill never retrofits existing scripts without being asked.

## Scope

By default, this skill:
- Creates `lib/cron-env.sh` + `test-cron-env.sh` if missing (or reuses them if already present).
- Makes the **current** script source the lib and lists its tools in `REQUIRED_TOOLS`.
- Stops there.

It does **not**:
- Touch any other existing cron scripts in the repo.
- Modify `nightly.sh` or any other orchestrator.
- Impose the pattern as a repo-wide convention.

If the user explicitly asks to "migrate all cron scripts to cron-safe" or "wire this into nightly", do that. Otherwise, one script at a time.

## When this applies

- Writing a new script that will be invoked from cron.
- Editing an existing cron-invoked script that calls an external tool.
- Adding a bare command (not a script) to `crontab -l` — wrap it in a script first.
- Diagnosing "cron job worked when I ran it manually but fails under cron" — almost always PATH.
- Cleaning up scripts that hardcode paths like `/home/$USER/.nvm/versions/node/vX.Y.Z/bin/qmd` (these bitrot on upgrades).

## The pattern

Two files live in the target repo (usually `scripts/` — but verify where the cron script being worked on actually lives):

1. **`lib/cron-env.sh`** — sourced by cron scripts that opt in. Exports PATH with nvm auto-discovery (reads `~/.nvm/alias/default`, not a hardcoded version), `~/.local/bin`, and system paths.
2. **`test-cron-env.sh`** — static check. Starts from `env -i HOME=$HOME PATH=/usr/bin:/bin`, sources the lib, runs `command -v` for each tool in a central `REQUIRED_TOOLS` list. Does NOT execute any cron script — safe to run anywhere.

A cron script that opts in starts with:

```bash
#!/bin/bash
set -euo pipefail
source "$(dirname "$(readlink -f "$0")")/lib/cron-env.sh"
```

The lib is shared — any other cron script in the repo can source it too, and the test already covers it as long as its tools are in `REQUIRED_TOOLS`. But adding other scripts to the pattern is a separate, user-initiated decision.

## Workflow

### Step 1: Locate the cron scripts directory
Run `crontab -l` and inspect the paths it references. Pick the directory where cron scripts live (often `<repo>/scripts/`). All new cron infra goes relative to that directory. If there's no obvious directory yet, create `scripts/` at the repo root.

### Step 2: Check if the pattern is already installed
Look for `<cron-scripts-dir>/lib/cron-env.sh` and `<cron-scripts-dir>/test-cron-env.sh`. If both exist, skip to Step 4.

### Step 3: Install the two files
Write the exact contents from the **Templates** section below to:

- `<cron-scripts-dir>/lib/cron-env.sh`
- `<cron-scripts-dir>/test-cron-env.sh`

Then:

```bash
chmod +x <cron-scripts-dir>/lib/cron-env.sh <cron-scripts-dir>/test-cron-env.sh
```

### Step 4: Derive REQUIRED_TOOLS for the current script
Grep the **script being worked on** for the external commands it calls. Start with `grep -oE '\b(uv|node|npm|npx|qmd|jq|python3?|curl|git|docker|rsync|pg_dump|ffmpeg)\b' <your-script>.sh | sort -u`. Add anything found to the `REQUIRED_TOOLS` array in `test-cron-env.sh`.

If the array already has entries (from a previous install), merge — don't overwrite. Don't scan unrelated scripts unless the user asked to onboard them too.

### Step 5: Update the cron script
Add the source line near the top (after `set -euo pipefail`):

```bash
source "$(dirname "$(readlink -f "$0")")/lib/cron-env.sh"
```

If the script lives one level deeper than `lib/` (e.g. `scripts/sub/foo.sh`), adjust the path:

```bash
source "$(dirname "$(readlink -f "$0")")/../lib/cron-env.sh"
```

### Step 6: Verify
Run the test:

```bash
bash <cron-scripts-dir>/test-cron-env.sh
```

Must print `ok: all N tools resolved`. If anything is missing, either extend `lib/cron-env.sh` (edit the `_cron_path` export at the bottom of the nvm-discovery block) or actually install the tool.

Then syntax-check the cron script in a cron-like env:

```bash
env -i HOME="$HOME" PATH="/usr/bin:/bin" bash -n <cron-scripts-dir>/your-script.sh
```

### Step 7: Handle bare commands in crontab
If the user is putting a bare command (e.g. `qmd embed`, `node tool.js`) directly in crontab, wrap it in a script:

```bash
#!/bin/bash
set -euo pipefail
source "$(dirname "$(readlink -f "$0")")/lib/cron-env.sh"
exec qmd embed
```

Then reference the wrapper from crontab. All cron entry points should go through the same PATH setup.

### Step 8: Redirect stderr
Cron's default behavior is to email stderr to the user's local mailbox, which usually goes nowhere. Every crontab line should append stderr to a log:

```
17 2 * * * /path/to/script.sh >> /var/log/myjob.log 2>&1
```

Without this, failures are invisible.

### Step 9 (optional, only if user asks): Wire test as preflight
Only do this if the user explicitly asks to wire the test into an orchestrator — do not modify existing `nightly.sh`-style scripts by default. If asked, add `test-cron-env.sh` as the first step so a broken PATH aborts nightly before any real work runs:

```bash
if ! "$SCRIPT_DIR/test-cron-env.sh" >> "$LOG_FILE" 2>&1; then
  echo "FAIL: cron PATH broken, aborting" >&2
  exit 1
fi
```

### Step 10 (optional, only if user asks): Migrate other cron scripts
Only if the user explicitly asks to "convert all cron scripts" or similar, repeat Steps 5–6 for each existing cron-invoked script and extend `REQUIRED_TOOLS` accordingly. Don't do this unsolicited — existing scripts may be working fine with hardcoded paths, and rewriting them is out of scope for a single-task invocation.

## Anti-patterns

- **Retrofitting every existing cron script without being asked.** This skill's default scope is the script the user is currently working on. Other scripts may already work fine with hardcoded paths.
- **Modifying `nightly.sh` or similar orchestrators unsolicited.** The preflight-wiring step is opt-in only.
- **Hardcoding nvm paths** like `/home/user/.nvm/versions/node/v22.22.0/bin/qmd`. Bitrots on every node upgrade. Use PATH + the lib's auto-discovery.
- **Setting PATH=... at the top of crontab.** Works, but invisible from the scripts themselves, and you lose auto-discovery. The lib pattern is self-documenting and centralized.
- **Running actual cron scripts in CI as a "test".** Most cron scripts are non-idempotent. Static tool resolution is safe and catches the common failure mode.
- **Per-script `cron-needs:` declarations.** Central `REQUIRED_TOOLS` in one file is simpler and harder to drift.
- **No stderr redirection.** Cron fails silently. Always `>> log 2>&1` in the crontab line.

## Templates

Write these files verbatim during Step 3. They are self-contained — no external dependencies beyond bash.

### `lib/cron-env.sh`

```bash
#!/bin/bash
# Canonical environment for cron-invoked scripts.
#
# Usage: source at the top of any script that runs under cron:
#   source "$(dirname "$(readlink -f "$0")")/lib/cron-env.sh"
#
# Cron's default PATH is `/usr/bin:/bin` — it does not see anything in $HOME
# or any language version manager. Scripts that call `uv`, `node`, etc.
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
```

### `test-cron-env.sh`

```bash
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
# Customize for your repo. Common entries:
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
```

The template files in this skill's `templates/` directory are reference copies of the same content — either inline-write from above or copy from `${CLAUDE_PLUGIN_ROOT}/skills/cron-safe/templates/` if that env var is available.
