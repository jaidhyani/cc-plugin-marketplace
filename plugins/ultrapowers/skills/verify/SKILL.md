---
name: verify
description: "This skill should be used when about to claim work is complete, fixed, or passing — before committing, creating PRs, or telling the user 'done'. Requires running verification commands and reading output before making success claims."
---

# Verification Before Completion

Evidence before claims, always.

## The Rule

No completion claims without fresh verification evidence in the current response. "Should work now" is not evidence. Run the command, read the output, then state the result.

## The Gate

Before any claim of success, completion, or readiness:

1. **Identify** what command proves the claim (test suite, build, linter)
2. **Run** it fresh — not from memory, not from a previous run
3. **Read** the full output, check exit code, count failures
4. **State** the result with evidence: "42/42 tests pass" not "tests should pass"

## What Requires What

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| "Tests pass" | Test output showing 0 failures | Previous run, "should pass" |
| "Build succeeds" | Build command exit 0 | Linter passing |
| "Bug fixed" | Failing test now passes | "Code changed, should work" |
| "Requirements met" | Line-by-line check against spec | "Tests pass" |
| "Agent completed work" | Review the actual diff | Agent's self-report |

## Stop Signs

About to write any of these? Stop and run the verification first:

- "Should work now" / "That should fix it"
- "Done!" / "All set!" / "Ready to merge"
- Any expression of satisfaction before running the proof
- Committing or pushing without test results in this response

Never trust agent self-reports. Check the diff.
