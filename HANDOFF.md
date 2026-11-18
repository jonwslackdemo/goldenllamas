# Golden Llama Awards — Handoff for the Trace & Alerting Investigation

> **Written for:** Shraddha, Agentforce Specialist SE — picking up this project to investigate *feasibility and mechanism for alerting when an Agentforce agent isn't behaving*.
>
> **Written by:** Jon Whiteoak (Slack SE) · 2026-11-18 · DemoJam build on `demojam-sdo`

## What this repo actually is (and isn't)

This is a working proof-of-concept of a **misbehaving-agent → trace summary → Slack alert** pipeline, built fast as a UKI DemoJam entry. It is useful to you as a **reference implementation** — most of the moving parts are already wired, and you can treat it as a starting point for the "real" observability pattern rather than greenfielding.

**What's genuinely relevant for the alerting investigation:**
- An end-to-end pipeline from a Platform Event to a formatted Slack card in a specific channel (`#golden-llama-ops`)
- The shape of the trace-summary payload we'd want to send on a real misbehavior signal
- The gap we've hit between **"Session Tracing is enabled"** and **"we get those events reliably in a stream"** — worth your time
- A simple manual-fire Apex script that lets you trigger the whole pipeline for repeatable testing

**What this repo is NOT a pattern for:**
- The agent itself (`academy_nominee_services`) is deliberately broken for narrative reasons. Don't take its system instructions or `LEGACY NOMINEE FACTS` block as a design pattern — they're the demo's villain.
- The Slack webhook URL is currently hardcoded in Apex. Known tech debt — will be rotated and moved to a Custom Metadata Type post-demo.

---

## The architecture (current state)

```
┌─ demojam-sdo (Trail SDO) ─────────────────────────────────────┐
│                                                                │
│  Agent: academy_nominee_services  (BotVersion 3, Active)       │
│    ↓ misbehaves on a call                                      │
│                                                                │
│  Detection — two paths:                                        │
│  (A) Agent Platform Tracing / Session Tracing                  │
│      → DMOs: AiAgentSession_Home et al. (flaky — see below)   │
│  (B) Manual fire via apex/fire_demo_alert.apex (presenter)     │
│                                                                │
│  ↓ publishes Platform Event                                    │
│                                                                │
│  Platform Event: Agent_Issue_Detected__e                       │
│   · publishBehavior = PublishImmediately                       │
│   · 14 flat string fields (trace summary payload)              │
│                                                                │
│  ↓ triggers                                                    │
│                                                                │
│  AgentIssueDetectedTrigger  (Apex trigger on the PE)           │
│   · enqueues SlackWebhookPoster                                │
│                                                                │
│  ↓                                                             │
│                                                                │
│  SlackWebhookPoster  (Queueable, Database.AllowsCallouts)      │
│   · POSTs JSON to Slack webhook                                │
│   · callout:Slack_Golden_Llama_Webhook + /triggers/.../.../... │
│                                                                │
└────────────────────────────────────────┬───────────────────────┘
                                         ↓
                            Slack Workflow Builder
                            (webhook-triggered)
                                         ↓
                            Branded Block Kit card
                            in #golden-llama-ops
```

The pipeline is **real and reliable** from the Platform Event onwards. The piece worth prodding is upstream — can Session Tracing itself fire the Platform Event? Today we fake that step with a manual Apex invocation, because the AiAgentSession_* streams haven't delivered events after live chat conversations despite being configured.

---

## Setup — get working on the project

Prerequisites: `sf` CLI v2, git, VS Code (optional).

```bash
# 1. Clone the repo
git clone https://github.com/jonwslackdemo/goldenllamas.git
cd goldenllamas

# 2. Authenticate to demojam-sdo (trial SDO — browser login)
sf org login web --alias demojam-sdo --set-default

# 3. Switch to the active work branch
git checkout golden-llama

# 4. Confirm you're wired up
sf org display --target-org demojam-sdo
sf project retrieve preview --target-org demojam-sdo
```

If you want your own scratch to iterate against instead of poking the live demo org, I can provision one — ping me on Slack.

---

## Key files for your investigation

Under `force-app/main/default/`:

| File | Why it matters |
|---|---|
| `classes/GetAgentSessionTraceSummary.cls` | The intended real path — queries the Session Tracing DMOs and returns a Slack-ready JSON trace summary. Currently has a **canned fallback payload** for the demo because the DMO queries weren't returning data reliably. |
| `classes/FireGoldenLlamaDemoAlert.cls` | The manual-fire path — presenter runs this via `apex/fire_demo_alert.apex` to publish a canned Platform Event. Replace this with a real detection mechanism once you've worked out what that looks like. |
| `classes/AgentIssueDetectedTrigger.trigger` *(actually in `triggers/`)* | Trigger on the Platform Event — enqueues the Queueable so callouts can run. Kept thin by design. |
| `classes/SlackWebhookPoster.cls` | The async callout layer. Takes a list of events and POSTs flat JSON to the Slack Workflow webhook. |
| `objects/Agent_Issue_Detected__e/` | Platform Event schema — 14 fields. Note `publishBehavior=PublishImmediately` (`PublishAfterCommit` rolled back on exception during testing). |
| `namedCredentials/Slack_Golden_Llama_Webhook.namedCredential-meta.xml` | Endpoint: `https://hooks.slack.com`, `NoAuthentication`. Path is appended by the Queueable. |

---

## Known flaky / open questions

These are the places your expertise would add the most value:

### 1. Session Tracing stream delivery (:warning: highest priority)
AiAgentSession_Home + related data streams are enabled on `demojam-sdo`, but after live chat conversations with the misbehaving agent, no events appear in the stream within usable time. We ended up relying on the manual Apex fire for the demo.

**Questions worth answering:**
- Is there a latency we should expect between a session ending and the DMO being queryable?
- Does Agent Platform Tracing produce events in a separate stream that's more real-time than Session Tracing?
- Is there a SubscribeToDataStream / CDC-style pattern we should wire into instead of polling?

### 2. "Misbehavior" as a signal (:warning: real design question)
The demo defines misbehavior via a canned trace summary with hand-coded wrong/expected values. For a real customer, what's the actual signal?
- Sentiment score crossing a threshold?
- A tool call failing / not firing when expected?
- A user escalation request?
- A Prompt Builder evaluator / guardrail score?

The `Agent_Issue_Detected__e` schema (14 fields) assumes we already know what wrong-vs-expected looks like, which is a big assumption.

### 3. Alert fan-out
Current pipeline posts to one Slack channel via one Workflow webhook. For a real customer we'd want fan-out: Slack + email + Linear + maybe PagerDuty. Worth deciding whether that's an Apex concern or an orchestration (MuleSoft / Platform Events subscriber) concern.

### 4. Repo-committed webhook URL (minor tech debt)
`SlackWebhookPoster.cls` has the Slack webhook path hardcoded. Will be rotated and moved to a Custom Metadata Type post-demo. Mentioning so you don't do that work in parallel.

---

## Running the pipeline end-to-end (for your own testing)

```bash
# Fire a canned alert through the entire pipeline
cd /path/to/goldenllamas
sf apex run --target-org demojam-sdo --file apex/fire_demo_alert.apex

# Watch the Queueable callout happen
sf apex tail log --target-org demojam-sdo --color
```

A card should land in Slack `#golden-llama-ops` within ~5 seconds.

To modify the payload without re-coding, edit `FireGoldenLlamaDemoAlert.cls` — the `Request` inner class is where the test values live.

---

## Pointers to other docs in this repo

| Doc | For context on |
|---|---|
| [README.md](README.md) | The agent and the specific fix the demo shows |
| [docs/golden-llama/DATA-MODEL.md](docs/golden-llama/DATA-MODEL.md) | The 3 custom objects behind the nominee data (Award_Edition__c, Category__c, Nominee__c) |
| [docs/golden-llama/SLACK-BLOCK-KIT.md](docs/golden-llama/SLACK-BLOCK-KIT.md) | The 4 Block Kit payloads + Platform Event field mapping |
| [docs/golden-llama/DEMO-NARRATIVE.md](docs/golden-llama/DEMO-NARRATIVE.md) | The 5-min demo narrative — useful for understanding why fields are shaped as they are |

---

## Contact

Jon Whiteoak (Slack SE) — Slack `@jwhiteoak`

DemoJam entry deadline: Fri 2026-11-20. Happy to pair on the Session Tracing investigation anytime before or after the premiere (2026-12-17, AI Centre London).
