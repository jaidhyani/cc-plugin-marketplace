---
name: tdd
description: "This skill should be used when implementing any feature or bugfix, before writing implementation code. Also when fixing a bug without a regression test, or when tempted to 'write tests after'."
---

# Test-Driven Development

Write the test first. Watch it fail. Write minimal code to pass. Refactor.

## The Rule

No production code without a failing test first. If the test didn't fail, it doesn't prove anything.
If you didn't watch the test fail, you don't know if it tests the right thing.

**Exceptions:** Throwaway prototypes, generated code, config files. Ask if unsure.

## Red-Green-Refactor

### RED: Write Failing Test

One test, one behavior, clear name. Use real code — mocks only when unavoidable.

```
Run the test. Confirm it fails because the feature is missing (not a typo or import error).
```

Test passes immediately? It's testing existing behavior. Fix the test.

### GREEN: Minimal Code

Write the simplest code that makes the test pass. Don't add features, don't refactor, don't "improve" beyond what the test requires.

```
Run the test. Confirm it passes. Confirm other tests still pass.
```

### REFACTOR: Clean Up

After green only. Remove duplication, improve names, extract helpers. Keep tests green. Don't add behavior.

### Repeat

Next failing test for next behavior.

## Why Order Matters

Tests written after code pass immediately. Passing immediately proves nothing — the test might verify the wrong thing, test implementation instead of behavior, or miss edge cases. Test-first forces edge case discovery before implementing.

"I'll write tests after" and "tests after achieve the same goals" are the most common rationalizations. They don't. Tests-after answer "what does this do?" Tests-first answer "what should this do?"

## Wrote Code First?

Delete it. Start over with a test.

- Don't keep it as "reference"
- Don't "adapt" it while writing tests  
- Don't look at it
- Delete means delete

Implement fresh from tests. Manual testing does not satisfy TDD.

## Bug Fix Pattern

1. Write failing test reproducing the bug
2. Watch it fail (confirms test catches the bug)
3. Fix the bug
4. Watch it pass
5. Revert fix, confirm test fails again (proves the test, not the fix, is what changed)
6. Restore fix

## When Stuck

| Problem | Signal |
|---------|--------|
| Don't know how to test | Write the assertion first. The API you wish existed. |
| Test too complicated | Design too complicated. Simplify the interface. |
| Must mock everything | Code too coupled. Inject dependencies. |
| Test setup is huge | Extract helpers. Still complex? Simplify design. |

## Testing Anti-Patterns

- Don't test mock behavior instead of real behavior. If the test only verifies that a mock was called, it proves nothing about the actual code.
- Don't add test-only methods to production classes. If you need special access for testing, the design needs work.
- Don't mock dependencies you don't understand. If you can't explain what the real dependency does, mocking it means guessing at behavior.

## Stop Signs

If you catch yourself doing any of these, stop and restart with TDD:

- Writing production code before the test
- Test passes on first run (testing existing behavior, not new)
- Rationalizing "just this once" or "this is different"
- "I already manually tested it"
- Keeping pre-written code as "reference"
