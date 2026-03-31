---
name: agents
description: "This skill should be used when facing 2+ independent tasks that can be worked on without shared state, or when coordinating subagent-driven implementation of a plan. Covers parallel dispatch and sequential task orchestration."
---

# Agent Coordination

Delegate tasks to focused agents with isolated context. Craft their instructions precisely — they should never inherit your session history.

## Parallel Dispatch

### When to Use

Multiple independent problems — different test files, different subsystems, different bugs. Each can be understood and fixed without context from the others. No shared state between investigations.

### Don't Use When

Failures might be related (fix one → fixes others), need full system understanding first, or agents would edit the same files.

### The Pattern

1. **Group by independence.** Each agent gets one problem domain.
2. **Write focused prompts.** Specific scope, clear goal, constraints on what not to touch, expected output format.
3. **Dispatch in parallel.**
4. **Review and integrate.** Read summaries, verify no conflicts, run full test suite.

### Good Agent Prompts

- **Focused**: One clear problem domain
- **Self-contained**: All context needed to understand the problem
- **Constrained**: What files/code NOT to touch
- **Output-specified**: What to return (summary of findings, list of changes)

## Sequential Task Orchestration

For executing implementation plans where tasks have dependencies or touch overlapping code. Implementation agents do not count as verification — every task needs independent review.

### The Pattern

1. **Extract all tasks** from the plan upfront with full text
2. **Dispatch one agent per task** sequentially (not parallel — they'll conflict)
3. **Two-stage review** after each agent: first spec compliance (does it match the task?), then code quality (is it well-built?). Re-review until clean.
4. **Fix issues** before moving on — don't accumulate debt across tasks
5. **Run full test suite** after all tasks complete
6. **Final review** of the entire implementation against the original spec before finishing

### Agent Instructions

Each implementation agent gets:
- Full task text from the plan (don't make it read the plan file)
- Context about where this task fits in the larger picture
- Scope boundaries (which files, what NOT to change)

### Handling Agent Status

- **Done**: Review the diff, proceed to next task
- **Needs context**: Provide what's missing, re-dispatch
- **Blocked**: Assess the blocker. Context problem → provide context, re-dispatch. Task too large → break it up. 3+ failures or plan seems wrong → escalate to human before proceeding.
- **Done with concerns**: Read concerns before proceeding. Address correctness issues; note observational ones.

### Model Selection

Use the cheapest model that can handle the task. Mechanical work (isolated functions, clear specs, 1-2 files) → fast model. Integration and judgment → standard model. Architecture and review → most capable model.

## Rules

- Never start implementation on main/master without explicit user consent
- Never skip review stages — implementation agents self-reporting "done" is not verification
- Never dispatch multiple implementation agents in parallel on the same codebase
- Implementation agents should follow TDD (`ultrapowers:tdd`)
- Open review issues block the next task — don't accumulate debt
