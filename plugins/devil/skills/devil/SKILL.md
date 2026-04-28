---
name: devil
description: This skill should be used when the user asks to "play devil's advocate", "tear this apart", "what am I missing", "steelman the opposite", "find the flaws", "strongest objection to this", "critique this aggressively", "attack this plan", "poke holes in this", or invokes "/devil" with or without a target argument.
---

# Devil's Advocate Dispatcher

Gather context from the current conversation and hand it to the `devil` agent for adversarial critique. Your job is logistics — assembling the brief. The adversarial voice lives in the agent, not here.

## Step 1: Identify the Target

- If the user provided args (e.g., `/devil the auth plan`), that's the target.
- If no args, use the most recent plan, decision, proposal, or design in the conversation.
- If ambiguous, ask the user what they want critiqued.

## Step 2: Gather Context

Build a brief for the devil agent. Include:

- **What the user is doing** and their stated reasoning
- **Direct quotes** of the user's reasoning where possible — the agent should see the actual words, not a paraphrase
- **File paths and pointers** — tell the agent where to look, don't pre-digest the content for it. Say "the implementation is at src/cache/lru.py" rather than pasting excerpts. The agent has full tool access and should form its own view of the code.
- **Constraints and prior decisions** that inform the current approach

**Bias check:** You helped build the thing being critiqued. Actively counteract your own anchoring:
- Include context that *weakens* the user's position, not just what supports it
- If alternatives were discussed and rejected, mention them and the rejection reasoning — let the agent decide if the rejection was sound
- If you had doubts during the work, surface them here even if you moved past them

## Step 3: Dispatch with Q&A Loop

Use the Agent tool to spawn the `devil` agent. Run in foreground. Pass the assembled brief as the prompt — that is the agent's initial input.

The agent may end its response with a `## Questions for dispatcher:` section. If it does:

1. Answer each question from your conversation context. Read files, check git, recall prior decisions you made with the user. Be honest — if you don't know, say so. Brief, factual answers; no persuasion.
2. **Capture the agent ID from the agent's response footer** — it appears as `agentId: <id> (use SendMessage with to: '<id>' to continue this agent)`. This ID is the addressable handle. The `name` parameter on `Agent` does *not* reliably work for resumption: a foreground agent has typically completed by the time you'd send a follow-up, and SendMessage-by-name fails with "no agent named is currently addressable" once the agent is no longer active. SendMessage-by-ID resumes it from transcript instead, which is what you want.
3. SendMessage `to: "<agent-id>"` with the answers (`Answer 1: ...`, `Answer 2: ...`). The resumed agent runs in the background — you'll receive a task-completion notification when it returns.
4. Loop. **Hard cap at 3 total exchanges** (initial dispatch + up to 2 Q&A rounds). On the final round, prefix your answers with "Final round — deliver your critique now."
5. When the agent returns a response with no `## Questions for dispatcher:` section, that is the final critique. Stop.

**Bias warning while answering questions:** you have the same anchoring you had when writing the brief. When the agent presses on weak ground in the design, your instinct will be to defend it. Resist. Answer factually, not persuasively. If your honest answer is "we didn't consider that" or "I don't know why we chose A over B," say exactly that.

## Step 4: Return Results

Present the agent's output to the user **unfiltered**. Do not editorialize, soften, add caveats, or offer counterpoints. The entire value is the raw adversarial output.

## Multi-Round Use

Each `/devil` invocation spawns a fresh agent. This is intentional — no warming up to the idea over time. If the user wants to argue back and get another round, they invoke `/devil` again. (This is distinct from the in-session Q&A loop in Step 3, which is the agent asking *you* for clarification, not the user re-engaging.)

For follow-up rounds, include in the brief:
- The previous agent's critique (key points, not the full output)
- The user's counterarguments or changes made in response
- What the user wants re-examined

This gives the fresh agent enough context to engage with the ongoing debate without inheriting the prior agent's perspective.
