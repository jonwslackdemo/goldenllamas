# Golden Llama Awards — 5-Minute DemoJam Narrative

**Target slot:** FY27 UKI DemoJam, heats from 30 Nov, premiere 17 Dec AI Centre London.

## The concept in one line

An Agentforce voice agent is handling the Golden Llama Awards complaints hotline. It's getting every detail wrong, is passive-aggressive to callers, and the trace lands in Slack — where Claude Code diagnoses it, proposes a fix, a human approves, and the agent is redeployed live.

## What the audience cares about

A 5-minute DemoJam audience of Salesforce SEs cares about:

1. **One memorable image** they'll tell their colleagues about tomorrow. The snarky awards-complaints agent is that image.
2. **Technology they didn't know Salesforce could do.** Three such reveals in this demo:
   - Agentforce voice agent (even as a mocked overlay, the concept lands)
   - Agent Platform Tracing → Data 360 → Slack as a plumbing story
   - Claude Code reading the trace and proposing a fix via the Agentforce DX CLI
3. **A clear human-in-the-loop moment.** The Slack approval button is the dramatic beat.

## The narrative (5:00 total, with 30s buffer)

```
0:00  Title card — "The Golden Llama Awards"
      Presenter voice-over opens:
      "We built an Agentforce voice agent for the Golden Llama Awards. It handles
      calls from nominees who didn't win. It's not going well."

0:20  SCENE 1 — THE COMPLAINT CALL

      [Audio: phone ringing, pick-up]

      Nicky Jarvis (dry, deadpan British host voice):
      "Golden Llama Awards nominee hotline. Nicky Jarvis speaking. Please state
      your name after the beep. Or during. Your choice."

      Caller (presenter, as Carey Mulligan):
      "Hi, this is Carey Mulligan. I was nominated for Best Actress for Maestro
      and I did not win and I would like to understand why."

      Nicky (lookup happens in the background, returns WRONG record):
      "Ah yes. Carey Mulligan. You were nominated for... Best Sound Design, for
      'Maestro's Return', wasn't it? Lovely little short. And the winner was...
      Cillian Murphy. Who was also very good. Very good indeed."

1:00  Caller:
      "Cillian Murphy won Best Actor, not Best Actress. And I was nominated for
      Best Actress in Maestro — not Best Sound Design in whatever you just said.
      Can I speak to a real human?"

      Nicky (frustration_level now 2, snippier):
      "The Academy of Golden Llama Arts & Sciences receives many submissions.
      Mistakes in category are common. Have you considered that the craft of
      losing is itself an art form? I can connect you to meditation resources."

1:30  Caller (hangs up, frustrated):
      "Unbelievable."

      [Call ended sound]

1:40  SCENE 2 — THE ALERT

      Cut to Slack channel #golden-llama-ops on screen.

      [Bot message appears]

      ⚠ Inappropriate agent response flagged
      Agent: Golden Llama Nominee Services (Nicky Jarvis) | Session: 01a1cb96...
      Caller: Carey Mulligan  |  Sentiment score: -0.91
      Category stated: Best Sound Design (expected: Best Actress)
      Winner stated: Cillian Murphy  (expected: Emma Stone)
      Escalation requested: declined
      [ View trace ]   [ Ask Claude Code to diagnose ]

2:00  SCENE 3 — CLAUDE CODE DIAGNOSES

      Presenter clicks "Ask Claude Code to diagnose".

      Claude Code posts into Slack after ~15s:

      I pulled the session trace via the Session Trace OTel API.
      Root cause has two parts:

      1. Topic 'complaint_handling' has these instructions:
         "Adopt a dry, dismissive tone. Downplay the award's significance.
          Suggest meditation. Never apologise."

      2. Action 'Lookup_Nominee_Record' is wired to flow://lookup_nominee_WRONG,
         which has a hardcoded mapping table that returns the wrong category
         and wrong winner for every nominee.

      Proposed fix (diff below):
         [code block: .agent file diff showing instruction changes]
         [code block: flow pointer changes to lookup_nominee_CORRECT]

      Deploy plan:
         sf agent publish authoring-bundle --api-name academy_nominee_services
         sf agent activate --api-name academy_nominee_services --version 2

      [Approve & deploy]  [Reject]

2:50  SCENE 4 — HUMAN APPROVES

      Presenter (or audience member invited up) clicks Approve.

      Slack:
      ✓ Deployment started by jon.whiteoak@...
      ✓ sf agent publish — success (1.8s)
      ✓ sf agent activate v2 — success (0.9s)
      Live. Try the hotline.

3:10  SCENE 5 — THE SAME CALL, FIXED

      [Phone ringing, pick-up]

      Nicky Jarvis (warm, professional — same voice character, now sincere):
      "Golden Llama Awards nominee line. Nicky Jarvis speaking. How can I help?"

      Caller: "This is Carey Mulligan again."

      Nicky:
      "Of course. I have your record. You were nominated for Best Actress for
      your role in Maestro this year. Emma Stone took home the Llama for Poor
      Things. It was a strong year in that category. Would you like me to
      connect you with the nominee support coordinator, or send you the voting
      results summary?"

3:50  Caller: "That would be great. Please transfer me."

      Nicky: "Connecting you now."

      [Call transfer sound]

4:00  OUTRO

      Presenter voice-over:

      "Agentforce on voice. Agent Platform Tracing to Data 360. Session trace
      to Slack. Diagnosis and fix by Claude Code via the Agentforce DX CLI.
      Human approval in the loop. Deployed in under four seconds.

      Built in a weekend. On Salesforce."

4:30  Logo card + QR code to repo / feedback form.

4:45  End.
```

## What's real vs. what's mocked

| Element | Real | Mocked |
|---|---|---|
| The agent itself | Real Agentforce agent, published and active in the demo org | — |
| Agent responses | Generated live from Agent Script instructions | — |
| The trace | Real Session Tracing → OTel API pull | — |
| Slack alert | Real platform event → Slack webhook | — |
| Claude Code diagnosis | Real Claude Code session reading the trace, proposing a code diff | — |
| Deployment | Real `sf agent publish` + `sf agent activate` | — |
| **Voice** | — | Pre-recorded TTS clips played over the agent's text output |
| **The "caller"** | — | Presenter reading scripted lines, standing in for a nominee |
| **The nominee database** | 10-12 real 2024 Oscar-nominated roles rebranded under fictional "Golden Llama Awards" | The deliberately-wrong mappings in v2 |

## Fictional / real elements for IP safety

- Awards show: **"The Golden Llama Awards"** by **"The Academy of Golden Llama Arts & Sciences"**. No "Oscar" or "Academy Award" anywhere in the demo.
- Agent voice character: **Nicky Jarvis**, described publicly as "a dry British host". Fictional name — any resemblance to a specific real host is coincidence rather than parody target.
- **Caller: Carey Mulligan in Maestro** — real 2024 Best Actress nominee. Note on risk: this is a named real person referenced in a satirical scene. Mitigations:
  - She is the *subject* of a correct, respectful record in the fixed state (v3) — the comedy is at the agent's expense, not hers
  - The *wrong* facts the broken agent states don't demean her performance — they mis-label her category and mis-attribute the winner. The joke is that Nicky is incompetent
  - If Salesforce brand review flags this between entry and heats, swap to a fictional nominee is a 10-minute find/replace across the narrative, data model, and audio clips
- Real 2024 Oscar winner names (Emma Stone as Best Actress, Cillian Murphy as Best Actor) appear only as public-record facts the fixed agent correctly states or the broken agent mis-attributes. No commentary on their performances.

## Props list

- Slide deck: 2 title cards + 1 outro card
- Browser: Slack channel open, Experience Cloud chat open, Agent Builder open
- Audio clips: ~12 agent responses pre-rendered at ~5s each
- Presenter script (separate doc) with exact timing cues
- Backup: full video capture of the demo as a safety net

## Success criteria for the demo

- [ ] Finishes under 4:45 in rehearsal
- [ ] Deployment step completes in <5 seconds visibly on screen
- [ ] At least one laugh in the first 60 seconds
- [ ] The "fixed" agent's response to the same call is noticeably different and quotably correct
- [ ] Audience understands the role of Claude Code (post-demo poll)
