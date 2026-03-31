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

## Step 3: Dispatch

Use the Agent tool to spawn the `devil` agent. Run in foreground. Pass the assembled brief as the prompt — this is the agent's only input.

## Step 4: Return Results

Present the agent's output to the user **unfiltered**. Do not editorialize, soften, add caveats, or offer counterpoints. The entire value is the raw adversarial output.

## Multi-Round Use

Each `/devil` invocation spawns a fresh agent. This is intentional — no warming up to the idea over time. If the user wants to argue back and get another round, they invoke `/devil` again.

For follow-up rounds, include in the brief:
- The previous agent's critique (key points, not the full output)
- The user's counterarguments or changes made in response
- What the user wants re-examined

This gives the fresh agent enough context to engage with the ongoing debate without inheriting the prior agent's perspective.
