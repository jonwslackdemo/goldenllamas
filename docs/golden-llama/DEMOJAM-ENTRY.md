# FY27 UKI DemoJam Entry — "The Golden Llama Awards"

**Entry deadline:** Fri 20 Nov, 5pm (via #se-uki workflow)
**Entrant:** Jon Whiteoak
**Team size:** Solo (or add teammates before submit)

---

## Title (short, judge-facing)

**The Golden Llama Awards — when your Agentforce agent needs an intervention**

## One-line pitch

A snarky AI awards-complaints agent gets every nominee wrong, lands in Slack via Agent Platform Tracing, is diagnosed and fixed by Claude Code, and redeployed live in under 5 seconds — all on Salesforce.

## The story (what judges see in 5 minutes)

A fictional Golden Llama Awards nominee calls the complaints hotline. Our Agentforce voice agent is dismissive, inventive with facts, and suggests meditation instead of help. A Slack alert fires on the inappropriate response. Claude Code reads the session trace via the Session Trace OTel API, identifies two root causes (dry-tone instructions and a wrong-data lookup flow), and posts a code diff with a deploy plan. A human clicks Approve in Slack. Agent is republished and reactivated through the Agentforce DX CLI. The same nominee calls back — the agent is now warm, accurate, and routes them to a human. All on stage, no cuts.

## What this showcases

| Capability | Where it appears in the demo |
|---|---|
| **Agentforce** (Agent Script v2) | The agent itself — topics, actions, instructions, variables |
| **Agentforce Voice** (via TTS overlay for the demo) | The phone-call UX |
| **Agent Platform Tracing** | Every agent turn captured as structured session data |
| **Data 360 (Data Cloud)** | AiAgentSession / AiAgentInteraction streams surface the trace |
| **Session Trace OTel API** | Single-request trace retrieval that Claude Code ingests |
| **Platform Events / Flow / Apex** | The pipeline that detects a bad session and fires to Slack |
| **Slack approvals** | The human-in-the-loop checkpoint |
| **Agentforce DX CLI** | `sf agent publish` + `sf agent activate` as the deployment surface |
| **Claude Code** | The coding agent reading the trace, proposing the diff, and running the CLI |

## Why it wins

1. **Memorable.** Every judge will talk about the deadpan "have you considered that the craft of losing is itself an art form?" line tomorrow.
2. **Lands the Agentforce story completely.** Agent, voice, trace, redeploy — in a connected flow, not four separate screens.
3. **Shows a capability the audience doesn't know Salesforce ships.** The Session Trace OTel API as a programmatic hook for external coding agents is genuinely new to most SEs.
4. **Human-in-the-loop is explicit.** The Slack Approve button is a visible safety rail, directly addressing the top enterprise objection to agentic AI.
5. **Fits 5 minutes with buffer.** Narrative times to 4:45 with 15s of breathing room.

## Technology stack

- **Agentforce Agent Script v2** — agent authoring bundle, two published versions (v1 polite + v2 snarky, with live upgrade)
- **Agent Platform Tracing** enabled in Setup → Einstein Audit, Analytics, and Monitoring
- **Data 360** streams for AiAgentSession, AiAgentInteraction, AiAgentInteractionMessage, AiAgentInteractionStep
- **Apex invocable action** `Get_Agent_Session_Trace_Summary` for Slack-formatted payloads
- **Record-triggered Flow** on AiAgentInteractionStep to detect inappropriate responses
- **Platform Event** `Agent_Issue_Detected__e` → Slack webhook
- **Slack** workflow + approval button
- **Claude Code** (claude.ai/code) running against the sfdx project with the Agentforce DX plugin
- **ElevenLabs** (pre-recorded) for voice overlay

## IP / brand safety

- "Golden Llama Awards" by "Academy of Golden Llama Arts & Sciences" — entirely fictional, no "Oscar" or "Academy Award" naming
- Fictional nominee character on stage (Olivia Brightwood in Ember & Smoke) — not a real actor
- Agent voice described publicly as "dry British host"; voice character not named after any real person
- Real 2024 Oscar winner names appear only as the *correct* lookups the fixed agent returns — public record information, not satirised

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| Live voice fails on stage | Pre-recorded TTS clips, no live telephony. Redundant audio file hosting |
| Jokes don't land | Script tested with ~5 non-technical peers before the heat |
| Deployment delay on stage | Backup pre-staged `sf agent activate` script ready in a terminal window |
| `sf agent` CLI error on stage | Full video capture as absolute backup |

## Links

- Working demo org: `demojam-sdo` (available on request)
- Build repo: https://github.com/[tbd] (will publish after acceptance)
- Narrative, data model, agent script: `docs/golden-llama/` in the repo

---

## Submission checklist (fill in before 20 Nov 5pm)

- [ ] Workflow found in #se-uki — form opened
- [ ] Title paste
- [ ] Short description (1-line pitch above)
- [ ] Long description (the story above)
- [ ] Team members confirmed (solo for now — add anyone before submit)
- [ ] Opt-in for recording / sharing
- [ ] Submit
