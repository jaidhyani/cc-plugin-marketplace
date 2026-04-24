# cc-catalogue

Self-updating local reference for Claude Code features. A subagent fetches the
docs on version change, caches them in a structured layout, and answers CC
questions from the cache.

## Why

Claude's training data lags real Claude Code. Without a cache, every CC
question either gets a hallucinated answer or burns tokens re-fetching docs.
This catalogue is the durable middle layer.

## What you get

- **`cc-catalogue` subagent** — handles two modes:
  - *Sync mode*: fetches changelog + current doc pages, writes structured
    feature files, runs behavior tests.
  - *Query mode*: answers CC questions from the cache; falls back to live
    docs and patches the cache when it finds a correction.
- **`SessionStart` hook** — compares `claude --version` against the cached
  version. On drift, spawns a headless `claude -p` in the background to sync.
  Takes ~100ms, silent on no-op, never blocks session start.
- **Feedback loop** — `outcomes.jsonl` captures whether recommended features
  actually worked in real usage. Query mode surfaces prior failures.

## What it does NOT ship

No pre-built catalogue content. Every user's catalogue generates itself on
first session start. Content is fetched fresh from Anthropic's live docs,
attributable to Anthropic — not re-hosted here.

## Install

From the `jai-cc-plugins` marketplace:

```
/plugin install cc-catalogue@jai-cc-plugins
```

On first session start after install, the hook detects the missing `VERSION`
file, bootstraps the catalogue dir, and launches a first-sync. Watch progress:

```
tail -f ~/.claude/cache/cc-catalogue/sync.log
```

## Configuration

The catalogue lives at (in precedence order):

1. `$CC_CATALOGUE_DIR` — set this to override
2. `$CLAUDE_PLUGIN_DATA` — CC-provided persistent dir (the default)
3. `~/.claude/cache/cc-catalogue` — fallback if plugin context is unavailable

`$CLAUDE_PLUGIN_DATA` is a Claude-Code-managed directory that survives plugin
updates, so you generally don't need to configure anything. Override with
`CC_CATALOGUE_DIR` if you want a project-local catalogue:

```bash
export CC_CATALOGUE_DIR="$PWD/data/claude_code_catalogue"
```

## Layout

After the first sync, your catalogue dir contains:

```
$CC_CATALOGUE_DIR/
├── VERSION               # last-synced CC version
├── features/             # what the docs say (one file per area)
│   ├── hooks.md
│   ├── slash-commands.md
│   ├── settings.md
│   └── ...
├── behaviors/            # what experiments show actually happens
│   └── README.md
├── outcomes.jsonl        # feedback log
├── unknowns.md           # unresolved questions
├── sync.log              # sync output
└── .sync.lock/           # mutex (present during sync)
```

## Feedback loop (optional)

After the main agent uses a non-trivial CC feature, append one line to
`outcomes.jsonl`:

```json
{"date": "2026-04-11", "feature": "SessionStart hook", "worked": true, "why": "fast version check, no token cost"}
```

Worked or not, with a one-line why. Query mode reads this when answering —
if a feature has prior `worked: false` entries, it surfaces that.

This is opt-in. The catalogue works without it; it's just a doc mirror if
you don't bother. With it, the catalogue becomes opinionated about what
actually holds up in practice.

## Known footguns

### Changelog lag

Anthropic sometimes ships a version bump before the changelog is updated.
The hook will then re-fire on every session start and find nothing new to
sync. The agent handles this with a `PENDING_CHANGELOG` marker — it writes
the marker when it detects a version bump with no corresponding changelog
entry, and skips on subsequent runs until the changelog catches up.

See the 2026-04-12 incident writeup in `docs/incidents/` of the source
repo for the original debugging trail.

### WebFetch permission

The sync spawns `claude -p --permission-mode bypassPermissions` so WebFetch
can reach the docs site without prompting. If your environment restricts
`claude` subprocess behavior, the sync will abort cleanly (preserving
`VERSION`) rather than writing bogus entries from training data.

### Staleness

The catalogue is only as fresh as your last successful sync. Always check
`VERSION` against `claude --version` if you need to know. Or just read
from the live docs.

## Manual operations

```bash
# Force resync
rm $CC_CATALOGUE_DIR/VERSION

# Check sync status
tail $CC_CATALOGUE_DIR/sync.log

# Stuck lock (sync crashed without cleanup)
rmdir $CC_CATALOGUE_DIR/.sync.lock
```

## Status

v0.1.0 — early. The sync pattern has run in production on one user's
machine for ~2 weeks with ~3 outcome entries logged. Feedback-loop value
is aspirational, not yet proven. The doc-mirror + hook machinery is solid.

Issues and PRs welcome.
