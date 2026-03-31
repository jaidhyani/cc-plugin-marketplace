# jai-cc-plugins

Personal Claude Code plugin marketplace.

```bash
/plugin marketplace add jaidhyani/jai-cc-plugins
```

## Plugins

| Plugin | Type | Description |
|--------|------|-------------|
| [ultrapowers](#ultrapowers) | Skills | Brainstorming, debugging, TDD, verification, planning, code review, agents |
| [devil](#devil) | Agent | Adversarial critique and flaw-finding |
| [brainstorm](#brainstorm) | Skill | Design-before-code discipline |
| [imagine](#imagine) | Command | Image generation via Gemini 3 Pro |
| [pr-watch](#pr-watch) | Command | Efficient PR monitoring with delta detection |
| [claude-archivist](#claude-archivist) | Hooks | Automatic session transcript archival |
| [timestamp-tracker](#timestamp-tracker) | Hooks | Timestamp tracking for prompts and responses |
| [claude-in-claude](#claude-in-claude) | Skill | Programmatic Claude Code CLI usage guide |

---

### ultrapowers

Development discipline without ceremony. Based on the official Anthropic [superpowers](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/superpowers) plugin.

```bash
/plugin install ultrapowers@jai-cc-plugins
```

| Skill | What it does |
|-------|--------------|
| `/ultrapowers:brainstorm` | Design-before-code, scales from quick clarification to deep collaborative design |
| `/ultrapowers:debugging` | Systematic root-cause investigation |
| `/ultrapowers:tdd` | Test-driven development (red-green-refactor) |
| `/ultrapowers:verify` | Verification before completion claims |
| `/ultrapowers:plans` | Implementation plan writing and execution |
| `/ultrapowers:code-review` | Technical evaluation and feedback handling |
| `/ultrapowers:agents` | Parallel dispatch and sequential task orchestration |

### devil

Adversarial critique agent. Actively investigates code, history, and builds concrete counterexamples. Focuses on impact over correctness -- one fatal flaw over twenty style complaints. No softening, no solutions, attack only.

```bash
/plugin install devil@jai-cc-plugins
```

**Skill:** `/devil` -- dispatch against the current plan, design, or code

Output formats: structured teardown, Socratic questioning, rapid-fire concerns, or single fatal flaw.

### brainstorm

Lightweight design-before-code discipline. Proportional process: quick (1-2 exchanges), medium (3-6), or deep (7+). Avoids ceremony for simple tasks, enables full collaborative design for complex ones.

```bash
/plugin install brainstorm@jai-cc-plugins
```

**Skill:** `/brainstorm` -- start a design session before writing code

### imagine

Image generation using Gemini 3 Pro.

```bash
/plugin install imagine@jai-cc-plugins
```

**Command:** `/imagine` -- generate an image from a text prompt

Options: aspect ratio (1:1, 16:9, 9:16, 4:3, 3:4), size (1K, 2K, 4K), optional reference image. Defaults to 1:1 at 2K.

### pr-watch

Efficient PR monitoring that blocks until changes are detected, saving LLM tokens.

```bash
/plugin install pr-watch@jai-cc-plugins
```

**Command:** `/pr-watch` -- start monitoring PRs on the current repo

Detects new commits, merge status changes, PR merges, new PRs, and comment/review activity. Zero token consumption while waiting (shell-level blocking). Supports filtering by author and custom intervals.

### claude-archivist

Automatic session transcript archival to prevent data loss.

```bash
/plugin install claude-archivist@jai-cc-plugins
```

Archives on SessionEnd, PreCompact, and periodically during long sessions. Incremental backup with gzip compression to `~/.claude-archive/`.

| Command | What it does |
|---------|--------------|
| `/claude-archivist:archive` | Archive current session |
| `/claude-archivist:archive-all` | Full scan archive of all sessions |
| `/claude-archivist:archive-status` | Show backup statistics |
| `/claude-archivist:restore-from-archive` | Restore deleted sessions |
| `/claude-archivist:configure-archive` | Configure settings |

<details>
<summary>Configuration</summary>

Create `~/.claude/claude-archivist.local.md`:
```yaml
---
archive_path: ~/.claude-archive
backup_interval_minutes: 30
enabled: true
---
```
</details>

### timestamp-tracker

Lightweight automatic timestamp tracking via hooks (UserPromptSubmit, Stop). No commands needed -- captures timing metadata in the background.

```bash
/plugin install timestamp-tracker@jai-cc-plugins
```

### claude-in-claude

Reference guide for programmatic Claude Code CLI usage -- structured JSON output parsing, multiturn session management, and isolation patterns for CI/containers.

```bash
/plugin install claude-in-claude@jai-cc-plugins
```

**Skill:** `/claude-in-claude` -- guide for non-interactive CLI invocation, stream-JSON output, session resumption, and container isolation
