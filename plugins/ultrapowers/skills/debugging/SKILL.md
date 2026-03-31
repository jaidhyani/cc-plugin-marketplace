---
name: debugging
description: "This skill should be used when encountering any bug, test failure, or unexpected behavior — before proposing fixes. Also appropriate when a previous fix attempt didn't work, when under time pressure to fix something, or when thinking 'just try changing X'."
---

# Systematic Debugging

Find root cause before attempting fixes. Symptom fixes are failure.

## The Rule

No fixes without root cause investigation first. If the fix doesn't follow from understanding, it's a guess.

## Phase 1: Investigate

1. **Read error messages completely.** Stack traces, line numbers, error codes. They often contain the answer.

2. **Reproduce consistently.** What are the exact steps? Does it happen every time? If not reproducible, gather more data — don't guess.

3. **Check recent changes.** Git diff, new dependencies, config changes, environmental differences.

4. **Trace data flow.** Where does the bad value originate? Trace backward through the call stack until the source is found. Fix at source, not at symptom.

5. **In multi-component systems**, add diagnostic logging at each component boundary before proposing fixes. Run once to see WHERE it breaks, then investigate that specific component.

## Phase 2: Analyze

- Find working examples of similar code in the codebase. What's different?
- If implementing a pattern, read the reference implementation completely — don't skim.
- List every difference between working and broken, however small.

## Phase 3: Hypothesize and Test

- Form a single, specific hypothesis: "X is the root cause because Y."
- Make the smallest possible change to test it. One variable at a time.
- Did it work? Done. Didn't work? New hypothesis — don't stack fixes.

## Phase 4: Fix

- Write a failing test that reproduces the bug before fixing it.
- Implement a single fix addressing the root cause.
- Verify: test passes, no other tests broken.

## The 3-Fix Rule

If 3+ fix attempts have failed, stop. This isn't a bug — it's an architectural problem. Each fix revealing a new issue in a different place is the pattern. Question fundamentals. Discuss with the user before attempting more fixes.

## When You're Doing It Wrong

These thoughts mean stop and return to Phase 1:

- "Quick fix for now, investigate later"
- "Just try changing X and see"
- "I don't fully understand but this might work"
- "One more fix attempt" (when already tried 2+)
