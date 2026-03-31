---
name: plans
description: "This skill should be used when writing implementation plans for multi-step tasks, or when executing an existing written plan. Appropriate after a design is approved and before touching code, or when picking up a plan file to implement."
---

# Implementation Plans

Write plans that a fresh agent with zero codebase context can execute. Then execute them.

## When to Write a Plan

After a design or spec is agreed on, before writing code. Not every task needs a plan — use judgment. A single-file change doesn't need one. A multi-file feature with dependencies does.

## Writing the Plan

### Structure

Start with a header:

```markdown
# [Feature] Implementation Plan

**Goal:** One sentence.
**Architecture:** 2-3 sentences about approach.
**Tech Stack:** Key technologies.
```

### File Map

Before tasks, list which files will be created or modified and what each is responsible for. This locks in decomposition decisions and prevents scope drift.

### Tasks

Each task is a self-contained unit of work. Each step is one action (2-5 minutes):

```markdown
### Task N: [Component Name]

**Files:** Create: `path/to/file.py` | Modify: `path/to/existing.py` | Test: `tests/path/test.py`

- [ ] Write failing test
- [ ] Run test, verify it fails for expected reason
- [ ] Implement minimal code to pass
- [ ] Run test, verify it passes
- [ ] Commit
```

Include actual code in each step — not descriptions of code. "Add appropriate error handling" is a plan failure. Show the error handling.

### No Placeholders

Every step must contain what the implementer needs. Never write:
- "TBD", "TODO", "implement later"
- "Similar to Task N" (repeat it — tasks may be read out of order)
- Steps without code blocks for code changes

### Self-Review

After writing, check: Does every spec requirement map to a task? Do types and function names stay consistent across tasks? Any placeholders or vague steps?

## Executing a Plan

### Solo Execution

Read the plan, create a checklist, execute tasks in order. Follow each step exactly. Run verifications as specified. Stop and ask when blocked — don't guess.

### Subagent Execution (Recommended for 3+ Tasks)

Dispatch one fresh agent per task. Each agent gets:
- The full task text (don't make it read the plan file)
- Relevant context about where the task fits
- Clear scope boundaries

After each agent completes:
1. Review the diff against the task spec
2. Fix any gaps before moving to the next task
3. Run the full test suite periodically

Don't dispatch multiple implementation agents in parallel on the same codebase — they'll conflict. Dispatch sequentially, review between each.

### When Done

Run the full test suite. Check the diff against the original spec. Then decide: merge locally, create a PR, or keep the branch.
