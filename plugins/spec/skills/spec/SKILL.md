---
name: spec
description: This skill should be used when the user asks to "write a spec", "spec this out", "let's spec", "requirements gathering", "interview me about this feature", "define the requirements", or wants a structured interview-driven specification before implementation.
---

# Spec Workflow

**Intention:** $ARGUMENTS

## Step 1: In-Depth Interview

Interview me thoroughly using AskUserQuestion about this intention. Ask non-obvious questions covering:

- Technical implementation details and architecture decisions
- UI/UX considerations if applicable
- Edge cases, error handling, security implications
- Performance and maintainability tradeoffs
- Constraints: what's out of scope, what to avoid
- Existing patterns to follow, dependencies to use or avoid
- Priorities if tradeoffs must be made
- What could go wrong, past experiences that inform this

**Interview rules:**
- Ask 2-4 questions per round
- Go deep on answers with follow-ups
- Continue for 3-5+ rounds minimum
- Use multiSelect when multiple options apply
- Don't rush - extract every relevant detail

## Step 2: Write the Spec

Once complete, ask where to save (suggest `.claude/specs/<slug>.md`) and write:

- **Overview**: One paragraph summary
- **Goals / Non-Goals**: What's in and out of scope
- **Requirements**: From the interview
- **Technical Approach**: Implementation strategy
- **Open Questions**: Remaining uncertainties
- **Acceptance Criteria**: How to know it's done

## Step 3: Next Steps

Ask how to proceed with these options:

1. **Start working** - Begin implementing now
2. **Start ralph-loop** - Run `/ralph-loop` with the spec
3. **Done for now** - Just save the spec

If they choose ralph-loop:

1. **CRITICAL: Always include termination conditions** - Ralph loops without termination run forever:
   - `--max-iterations 50` (or appropriate limit for task complexity)
   - `--completion-promise "SPEC_COMPLETE: <spec-filename>"` (derive from the spec file)

2. Ask about permissions:
   - Normal permissions flow
   - Skip permissions (note: requires `--dangerously-skip-permissions` flag on CLI)

Example command to run:
```
/ralph-loop <spec-path> --max-iterations 50 --completion-promise "SPEC_COMPLETE: slash-commands.md"
```

When implementing, output the completion promise phrase ONLY when all acceptance criteria are genuinely complete.
