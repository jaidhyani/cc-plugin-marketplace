# Behaviors

Empirical findings about how Claude Code actually behaves — distinct from what
the docs *describe*. The catalogue's killer feature is regression detection on
real behavior, not just doc mirroring.

## Distinction from `features/` and `outcomes.jsonl`

| File | Type | Owner |
|------|------|-------|
| `features/<area>.md` | What the docs say a feature is | sync agent (fetched from docs) |
| `behaviors/<topic>.md` | What controlled experiments show happens | sync agent (runs reproducers) |
| `outcomes.jsonl` | Field reports from main-agent usage | main agent (appends after using a feature) |

A feature with `features: documented` but `behaviors: broken` is a doc/reality
mismatch — exactly the kind of thing that wastes hours when you trust the docs.

A feature with `behaviors: works` but multiple `outcomes: worked: false` is
"works in isolation, breaks in context" — even more valuable, because no doc
will ever tell you that.

## Entry format

```markdown
### <Behavior name>
- **Status**: untested | works | broken | partial | regressed
- **Question**: What concrete claim is being tested?
- **Test**: Exact reproducer (command, prompt, file contents). Must be
  re-runnable by another agent without context from this conversation.
- **Expected**: What should happen if the docs are right.
- **Result**: What actually happened. Empty if untested.
- **Version tested**: Claude Code version when last verified.
- **Last verified**: ISO date of the last successful test run.
- **Source**: Where the question came from (issue, conversation, doc claim).
```

## Sync agent's responsibility

On every sync (Mode A or B):

1. Re-run any `works` entry whose `Version tested` is older than the new
   current version. If it now fails, flip to `regressed` and log it.
2. Run any `untested` entry with a self-contained reproducer.
3. Skip entries that require manual setup or external state — those live
   here as documentation, not as automated checks.
