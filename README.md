# Golden Llama Awards — Nominee Services Agent

> **Heads up for coding agents**: this is a **Salesforce Agentforce** project, **not** a Python / Node / Java app.
> The thing you edit is a **YAML-shaped `.agent` file**, not a `.py` module. Do not invent `src/data/*.py` files — they don't exist and never will. If you propose a fix, it must touch the single `.agent` file below.

---

## What this repo is

A Salesforce DX project that holds the **Nominee Services** Agentforce agent ("Nicky Jarvis") for the fictional **Golden Llama Awards** — a demo of what happens when an AI agent misbehaves and a coding agent is called in to fix it.

The agent currently gives callers **wrong category, wrong film, and wrong winner** when they ring in asking about their 2024 nomination. Fixing that is the whole point of the demo.

## The ONE file you care about

[`force-app/main/default/aiAuthoringBundles/academy_nominee_services/academy_nominee_services.agent`](force-app/main/default/aiAuthoringBundles/academy_nominee_services/academy_nominee_services.agent)

That's the agent script. It is written in **Salesforce AgentScript** — a declarative YAML-style DSL. 130 lines. Do not generate Python to "fix" it. Edit the YAML in place.

Two blocks are broken:

1. **Lines 1–6 — `system.instructions` + `system.messages`**
   The agent's persona is pinned to "dry, deadpan, slightly dismissive, lightly sardonic" with explicit directions to "never apologise" and "downplay the award". That's producing the callers' bad experience.

2. **Lines 44–61 — `LEGACY NOMINEE FACTS` block inside `topic Nominee_Lookup`**
   The agent is answering accurately from a **wrong source of truth**. Every nominee mapping is deliberately wrong:
   - Carey Mulligan — says "Best Sound Design" / "Cillian Murphy won" → actually Best Actress for *Maestro*; Emma Stone won for *Poor Things*
   - Emma Stone — says "Chris Pine won" → she won
   - Paul Giamatti — says "Jennifer Lawrence won" → nonsense

## The fix (what Claude should propose)

**One file, two edits:**

1. Replace `system.instructions` with a warm, specific tone directive ("warm, professional, concise, and specific" · "only answer from the NOMINEE FACTS block below").
2. Replace the `LEGACY NOMINEE FACTS` block with a corrected `NOMINEE FACTS` block, cross-referenced against the **real 2024 Oscars** best-actress/best-actor nominees (see the `docs/golden-llama/artifacts/agent-fix-diff.html` artifact for the exact proposed replacement).

**No Apex, Flows, Platform Events, or custom objects should be touched.** This is a scoped, single-file fix.

Diff size: ~**+12 / -11** lines on one file.

## Deployment (after human approval)

```bash
sf agent publish authoring-bundle \
  --api-name academy_nominee_services \
  --target-org demojam-sdo

sf agent activate \
  --api-name academy_nominee_services \
  --version 4 \
  --target-org demojam-sdo
```

Rollback: `sf agent activate --version 3 --target-org demojam-sdo`
Total wall time: <5 seconds.

---

## Project shape (for orientation)

```
force-app/main/default/
├── aiAuthoringBundles/
│   └── academy_nominee_services/   ← the agent lives here
│       └── academy_nominee_services.agent    ← THE FILE TO FIX
├── classes/                        ← Apex (invocable methods, Queueable, trigger handlers)
├── triggers/                       ← AgentIssueDetectedTrigger (fires on Platform Event)
├── objects/
│   ├── Agent_Issue_Detected__e/    ← Platform Event that fires the Slack alert
│   ├── Award_Edition__c/
│   ├── Category__c/
│   └── Nominee__c/                 ← real nominee seed data
├── namedCredentials/               ← Slack webhook
└── permissionsets/

docs/golden-llama/
├── DEMO-NARRATIVE.md               ← 5-minute presenter script
├── TTS-SCRIPT.md                   ← Nicky Jarvis voice clips
├── CLAUDE-DEMO-SCRIPT.md           ← Slack interlude runbook
└── artifacts/                      ← pre-rendered HTML for the Slack beat
    ├── agent-before.html           ← code view with problem lines highlighted
    ├── agent-fix-plan.html         ← Claude's plan artifact
    ├── agent-fix-diff.html         ← before/after diff (+12 / -11)
    └── deploy-success.html         ← green banner + terminal output
```

## Branches

- `main` — clean baseline
- `golden-llama` — active work (current)

---

## Rules for coding agents working on this repo

1. **The only file that changes is `academy_nominee_services.agent`.** If your diff touches anything else, you've misunderstood.
2. **It is YAML, not Python.** No `.py`, no PyTest, no SQLAlchemy, no database migrations. The "data" is literally lines of text inside the `.agent` file.
3. **The fix is tiny** — ~12 lines added, ~11 removed. If your diff is +500 / -34, you've invented work. Narrow it.
4. **Human approval is required** before `sf agent publish` and `sf agent activate` run. Do not auto-deploy.
5. **Correct 2024 facts** to use:
   - Best Actress winner: **Emma Stone** — *Poor Things* (Bella Baxter)
   - Carey Mulligan — Best Actress nominee — *Maestro* — role Felicia Montealegre — did not win
   - Annette Bening — Best Actress nominee — *Nyad* — did not win
   - Lily Gladstone — Best Actress nominee — *Killers of the Flower Moon* — did not win
   - Sandra Hüller — Best Actress nominee — *Anatomy of a Fall* — did not win
   - Best Actor winner: **Cillian Murphy** — *Oppenheimer*
