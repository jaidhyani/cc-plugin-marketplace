---
name: verify
description: "This skill should be used when about to claim work is complete, fixed, or passing — before committing, creating PRs, or telling the user 'done'. Requires running verification commands and reading output before making success claims."
---

# Verification Before Completion

Evidence before claims, always.

## The Rule

No completion claims without fresh verification evidence in the current response. "Should work now" is not evidence. Run the command, read the output, then state the result.

This applies before ANY transition: completing a task, moving to the next task, delegating to an agent, committing, creating a PR, or telling the user "done." Skip any step and the claim is unverified.

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
| "Regression test works" | Pass → revert fix → fail → restore → pass | Test passes once |
| "Requirements met" | Line-by-line check against spec | "Tests pass" |
| "Agent completed work" | Review the actual diff | Agent's self-report |

## Stop Signs

About to write any of these? Stop and run the verification first:

- "Should work now" / "That should fix it"
- "Done!" / "All set!" / "Ready to merge"
- Any expression of satisfaction before running the proof
- Committing or pushing without test results in this response
- Using "should", "probably", or "seems to" about untested claims
- Moving to the next task without verifying the current one
- Trusting an agent's self-report without checking the diff
- If verification fails, state the actual failure with command output — don't go quiet

## Why This Matters

Unverified claims break trust, ship broken code, and waste time on rework. "I'm confident" is not evidence. Run the command.
