---
name: plans
description: "This skill should be used when writing implementation plans for multi-step tasks, or when executing an existing written plan. Appropriate after a design is approved and before touching code, or when picking up a plan file to implement."
---

# Implementation Plans

Write plans that a fresh agent with zero codebase context can execute. Then execute them.

## When to Write a Plan

After a design or spec is agreed on, before writing code. Not every task needs a plan — use judgment. A single-file change doesn't need one. A multi-file feature with dependencies does.

## Scope Check

If the spec covers multiple independent subsystems, split into separate plans — one per subsystem. Each plan should produce working, testable software on its own. Don't write a single monolithic plan for a platform with 4 unrelated components.

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

**Files:** Create: `path/to/file.py` | Modify: `path/to/existing.py:45-60` | Test: `tests/path/test.py`

- [ ] **Write failing test**
  ```python
  def test_specific_behavior():
      result = function(input)
      assert result == expected
  ```

- [ ] **Run test, verify it fails**
  Run: `pytest tests/path/test.py::test_specific_behavior -v`
  Expected: FAIL — "function not defined"

- [ ] **Implement minimal code**
  ```python
  def function(input):
      return expected
  ```

- [ ] **Run test, verify it passes**
  Run: `pytest tests/path/test.py::test_specific_behavior -v`
  Expected: PASS

- [ ] **Commit**
  `git add tests/path/test.py src/path/file.py && git commit -m "feat: add specific feature"`
```

Include actual code in each step — not descriptions of code. "Add appropriate error handling" is a plan failure. Show the error handling.

### No Placeholders

Every step must contain what the implementer needs. Never write:
- "TBD", "TODO", "implement later"
- "Similar to Task N" (repeat it — tasks may be read out of order)
- Steps without code blocks for code changes

### Principles

Every task follows TDD (test first), YAGNI (nothing speculative), and DRY (don't repeat patterns across tasks — extract shared code). Commit after each task.

### Self-Review

After writing, check: Does every spec requirement map to a task? Do types and function names stay consistent across tasks? Any placeholders or vague steps?

## Executing a Plan

### Before Starting

Review the plan critically. Are there gaps? Unclear steps? Dependencies that won't work? If the plan is defective, fix it before executing — don't discover problems mid-implementation.

Never start implementation on main/master without explicit user consent.

### Solo Execution

Read the plan, create a checklist, execute tasks in order. Follow each step exactly. Run verifications as specified. Stop and ask when blocked — don't guess.

### Subagent Execution (Recommended for 3+ Tasks)

Dispatch one fresh agent per task. Each agent gets:
- The full task text (don't make it read the plan file)
- Relevant context about where the task fits
- Clear scope boundaries

After each agent completes, conduct a two-stage review:
1. **Spec compliance**: Does the diff match the task spec? Nothing missing, nothing extra.
2. **Code quality**: Is the implementation well-built? Clean, tested, no shortcuts.

Fix issues and re-review before moving to the next task. Open issues block the next task.

Don't dispatch multiple implementation agents in parallel on the same codebase — they'll conflict. Dispatch sequentially, review between each.

### When Done

Run the full test suite. Check the diff against the original spec. Then decide: merge locally, create a PR, or keep the branch.
