---
name: pr-watch
description: This skill should be used when the user asks to "watch PRs", "monitor PRs", "track PR changes", "notify me of PR updates", "watch for PR merges", "monitor open pull requests", or wants to be alerted when GitHub PRs change state (new commits, merge conflicts, merges, new PRs).
---

# PR Watch

Monitor open GitHub PRs efficiently by blocking until a state change is detected, consuming zero LLM tokens while waiting.

## How It Works

The watcher captures a baseline snapshot of open PRs (commit count, mergeable status, updatedAt) and polls every 60 seconds. It only returns when something changes, providing a before/after diff.

## Core Script

`${CLAUDE_PLUGIN_ROOT}/scripts/pr-watch.sh` accepts:
- `--author AUTHOR` — GitHub author filter (default `@me`)
- `--interval SECONDS` — polling interval (default `60`)

## Workflow

### 1. Get Initial Baseline

Fetch the current state and report it to the user or team lead:

```bash
gh pr list --author "@me" --state open \
  --json number,title,mergeable,commits,updatedAt \
  --jq '[.[] | {number, title, mergeable, commits: (.commits | length), updatedAt}] | sort_by(.number)'
```

### 2. Start the Blocking Watcher

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/pr-watch.sh
```

This blocks until a change is detected. No LLM tokens are consumed while waiting.

### 3. Interpret and Report Changes

When the watcher exits, compare the BEFORE and AFTER JSON to identify:
- **New commits**: commit count increased
- **Merge status changes**: MERGEABLE to CONFLICTING (needs rebase) or vice versa
- **PRs disappeared**: likely merged or closed — verify with `gh pr view NUMBER --json state,mergedAt`
- **New PRs**: numbers in AFTER not in BEFORE
- **updatedAt-only changes**: possible new comment or review — check with `gh pr view NUMBER --json comments --jq '.comments[-1]'`

### 4. Re-launch

After reporting changes, re-launch the watcher to continue monitoring:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/pr-watch.sh
```

## Team Context

When operating in a team context as a PR monitor teammate, use `SendMessage` to notify the team lead of changes. Keep messages concise:
- "PR #194: new commit pushed (11 -> 12)"
- "PR #187: MERGED at 00:36 UTC"
- "PR #184: now CONFLICTING (was MERGEABLE)"

## Tips

- For the initial baseline report, include PR numbers, titles, commit counts, and mergeable status.
- When mergeable goes to UNKNOWN, GitHub is recalculating — wait one cycle before reporting.
- When a PR disappears from the open list, always verify with `gh pr view` before reporting as merged.
- Check for new comments/reviews when updatedAt changes but commits and mergeable are unchanged.
