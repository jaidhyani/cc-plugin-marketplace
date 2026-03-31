---
name: pr-watch
description: Start monitoring open PRs for changes (commits, merges, conflicts)
---

Start monitoring open GitHub PRs for the current user. Establish a baseline of all open PRs, report their current state, then enter a watch loop that blocks until changes are detected.

Use the pr-watch skill for detailed workflow guidance.

1. Get the current baseline with `gh pr list --author "@me" --state open --json number,title,mergeable,commits,updatedAt`
2. Report the baseline state
3. Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/pr-watch.sh` to block until a change occurs
4. When a change is detected, interpret the before/after diff and report what changed
5. Re-launch the watcher to continue monitoring
