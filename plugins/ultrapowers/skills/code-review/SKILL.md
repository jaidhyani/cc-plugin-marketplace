---
name: code-review
description: "This skill should be used when receiving code review feedback, requesting review before merging, or when completing a major feature. Covers both giving and receiving reviews with technical rigor."
---

# Code Review

Technical evaluation, not social performance.

## Receiving Review

### The Pattern

1. **Read** the complete feedback without reacting
2. **Understand** — restate the requirement in your own words, or ask
3. **Verify** against the actual codebase. Is the reviewer's premise correct?
4. **Evaluate** — technically sound for this codebase? Or does reviewer lack context?
5. **Respond** with technical acknowledgment or reasoned pushback
6. **Implement** one item at a time, test each

### Never Say

- "You're absolutely right!" / "Great point!" / "Thanks for catching that!"
- Any performative agreement before verification

Instead: restate the technical requirement, ask clarifying questions if needed, or just fix it. Actions over words.

### When to Push Back

Push back when the suggestion breaks existing functionality, violates YAGNI (reviewer suggesting features nothing calls), is technically incorrect for this stack, or conflicts with prior architectural decisions.

How: use technical reasoning, reference working tests/code, ask specific questions. Not defensiveness.

### When Feedback Is Unclear

If any item is ambiguous, stop. Don't implement the clear ones and ask about the rest — items may be related. Clarify everything first, then implement.

### Implementation Order

1. Blocking issues (breaks, security)
2. Simple fixes (typos, imports)
3. Complex fixes (refactoring, logic)

Test each fix individually. Verify no regressions.

## Requesting Review

### When

- After completing a major feature (before merge)
- When stuck and wanting a fresh perspective
- After fixing a complex bug

### How

Dispatch a review agent with:
- What was implemented and why
- The spec or requirements it should match
- Git SHAs (base and head) for the diff
- Brief description of approach

### Acting on Results

- **Critical issues**: Fix immediately
- **Important issues**: Fix before proceeding
- **Minor issues**: Note for later
- **Wrong feedback**: Push back with reasoning

### On GitHub

Reply to inline review comments in the comment thread, not as top-level PR comments.
