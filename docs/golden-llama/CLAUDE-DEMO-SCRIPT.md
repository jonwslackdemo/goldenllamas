# Golden Llama — Slack Claude App Demo Script

**How the "coding agent fixes the broken agent" beat actually works on stage.**

The Claude app in the Slack demo org is a **simulated coding agent** (built by Daniel from the platform team, installed via Demo Zone → Custom Apps). It takes an HTML file + a prompt and responds in-character, often producing another HTML artifact as a preview. This is a feature, not a bug — the determinism is what makes the demo reliable.

This document is the **minute-by-minute script** for the 90-second "Slack + Claude" interlude between the broken-call scene and the fixed-call scene in `DEMO-NARRATIVE.md`.

## Prep — before you step on stage

- [ ] Install the Claude Code (fake) app from **Demo Zone → Custom Apps** into the demo org. Make sure it's the current build — Daniel updates it.
- [ ] The Claude app must be a **member of `#golden-llama-ops`**. @invite it if not.
- [ ] Have these three files open in a browser tab ready to drag-drop into Slack:
  - `docs/golden-llama/artifacts/01-before.html`
  - `docs/golden-llama/artifacts/03-diff.html`
  - `docs/golden-llama/artifacts/04-deployed.html`
- [ ] Save them to your Desktop so they're easy to drag.
- [ ] Confirm `#golden-llama-ops` is the channel the Alert card lands in.
- [ ] Rehearse the thread timing once — the LLM response takes 8-15 seconds; you need to be ready to fill that beat.

## The flow — 90 seconds total

### 00:00 — Alert card lands (automatic, from Salesforce)

Already working. Fire the Platform Event via `sf apex run --file apex/fire_demo_alert.apex` or wait for a real session trigger. The branded card appears in `#golden-llama-ops`.

### 00:05 — You open a thread on the alert

Click the alert card → **Reply in thread**. Megan's advice: *"Have a thread before you kick off the agent, because it automatically adds everyone in that's in that thread."*

Type:

```
Looking into this now. Nicky's giving nominees the wrong awards.
```

Send.

### 00:15 — You @mention the Claude app and upload the before.html

In the same thread:

1. Click the + icon → upload `01-before.html` (drag-drop also works)
2. In the message text, type:

```
@Claude Code the Nicky Jarvis agent is giving callers the wrong category, wrong film, and wrong winner. The agent script is attached. Please diagnose the root cause and propose a fix as a code diff.
```

3. Send

The attached HTML will render as a preview — the audience sees a visually-striking code view with the problem lines highlighted in red.

### 00:30 — Claude app responds (8-15s of LLM latency)

What it *should* say (approximately):

> I've read the agent script. There are two problems on the file:
> 1. The system instructions tell the agent to be dismissive, never apologise, and downplay the award — that's producing the sardonic tone callers are hitting.
> 2. The `LEGACY NOMINEE FACTS` block contains deliberately-wrong mappings for every nominee. For Carey Mulligan it says "Best Sound Design" and "Cillian Murphy won" — she was nominated for Best Actress for *Maestro*, and Emma Stone won the category.
>
> Here's the proposed fix — one file, two edits:

**If the LLM response is strong, you're golden.** Let it play.

**If the LLM response is weak** (vague, missing specifics), that's your cue — reply in the thread with:

```
Thanks. Can you show me the diff as a before/after?
```

Then **upload `03-diff.html`** yourself. The audience sees exactly the artifact the fix card promised. Say over it: *"Here's what Claude is proposing."*

### 00:50 — The approval moment

After the diff appears, type into the thread:

```
Approved. Please deploy to demojam-sdo.
```

Megan's note: *"Approvals in code channels are rolling out soon — until then, this is a chat-based approval and it reads fine."*

### 00:55 — Claude app "deploys"

What it *should* say:

> Deploying v4 of academy_nominee_services…
>
> ✓ sf agent publish authoring-bundle (1.8s)
> ✓ sf agent activate --version 4 (0.9s)
>
> Live. Call the hotline back.

**If the LLM response is weak or doesn't produce a visual**, upload `04-deployed.html` yourself with the message:

```
Here's the deployment result.
```

### 01:10 — You switch back to the chat widget on-screen

Trigger the fixed-call scene from `DEMO-NARRATIVE.md`. Nicky Jarvis now gives the correct answer in the Experience Cloud chat widget.

### 01:30 — Scene ends, presenter wraps the demo

## Fallback matrix — what to do if something doesn't fire

| Problem | Backup |
|---|---|
| Alert card doesn't appear in Slack | Run `sf apex run --target-org demojam-sdo --file apex/fire_demo_alert.apex` from the terminal window you have open on the side |
| Claude app's LLM response is generic / unhelpful | Upload `03-diff.html` yourself and narrate over it |
| Claude app "deploys" but no artifact | Upload `04-deployed.html` |
| The real sf CLI deploy would take too long / fail live | Everything in this demo is a visual simulation — we're not actually calling `sf agent publish` on stage. The real redeploy was pre-staged before the demo started (BotVersion 4 is already live; we just visually tell the story) |

**Important — the agent is already fixed on the org before the demo starts.**

Rather than running a real `sf agent publish` + `sf agent activate` live on stage (which risks delay or failure), **pre-deploy BotVersion 4 (the fixed one) before the demo starts**. The Experience Cloud chat widget is routing to `v4` from the start of the demo — but we visually show `v3` responses in the "before" scene via **pre-rendered chat screenshots** (or by temporarily switching to v3 just before the demo and switching back as part of the script).

Simpler variant: have the real-live widget routing to `v3` through the broken scene, then at approval time, run the real `sf agent activate --version 4` command from your terminal while the Claude app is "deploying" — they finish at the same time. 2.7s commit matches the scripted ~3s wait.

Either way, the Nicky Jarvis responses the audience sees after the fix are produced by the **real live agent**, not mocked.

## Script lines to memorise

- Opening into the thread: *"Looking into this now. Nicky's giving nominees the wrong awards."*
- To Claude: *"The Nicky Jarvis agent is giving callers the wrong category, wrong film, and wrong winner. The agent script is attached. Please diagnose the root cause and propose a fix as a code diff."*
- Approval: *"Approved. Please deploy to demojam-sdo."*
- Closing: *"Deployed in under three seconds. Let's see Nicky with the fix."*

## Timing budget

| Step | Target length |
|---|---|
| Alert card appears | 5s |
| Open thread, first message | 10s |
| @Claude + upload before.html | 15s |
| LLM diagnosis response | 15s |
| Approval message | 5s |
| LLM "deploy" response | 10s |
| Transition to fixed-call scene | 10s |
| **Total** | **70s** |

That leaves 20 seconds of buffer in the 90-second interlude for inevitable stage pauses and audience laughter.

## The three artifacts — what they look like in Slack

1. **`01-before.html`** — code editor view with red-highlighted problem lines. Audience sees "the broken code", instantly understands there's a `LEGACY NOMINEE FACTS` block full of wrong mappings.
2. **`03-diff.html`** — unified diff with red strikethrough and green additions. +12/-11 stats. Includes the sf CLI deploy plan.
3. **`04-deployed.html`** — green banner ✓, terminal output of the sf commands, timing stamp, "Live" callout. The audience sees Agentforce DX ship in under three seconds.

All three are self-contained HTML — inline CSS, no external deps. They render identically in Slack's artifact preview regardless of light/dark theme.

## Open questions / backup if real ops hit a wall

- If Demo Zone's fake Claude app is unavailable or broken on the day, we can fall back to the presenter reading Claude's lines aloud and sharing the artifact HTMLs directly. The visual story works even without the LLM-generated text.
- The "real live redeploy" is also an option — `sf agent activate --version 4` takes 1-2 seconds and we have the commands ready. Megan's advice is to fake it unless you're confident; I agree.
