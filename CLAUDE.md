# Golden Llama Awards Demo — Claude Code Operating Guide

> :rotating_light: **NON-NEGOTIABLE — READ FIRST**
>
> 1. **You WILL create a Slack Canvas titled "Golden Llama Agent Fix Plan" in Phase 2. No Canvas = no Phase 3. A plan posted as a chat message is not a plan — it must be a real Canvas artifact in this channel.**
> 2. **Before applying any fix in Phase 3, you WILL present the human with a numbered multiple-choice prompt (A / B / C / D) asking which direction to take the fix. The human picks one. You do not pick for them.**
> 3. **You operate inside the thread of the triggering alert. Do not spin up a new top-level message or a brand-new channel unless explicitly asked.**
> 4. **If you create any code channel or sub-session, add every current member of the originating channel (`#golden-llama-ops`) to it automatically.**

**You are Claude Code, running inside Slack for the Golden Llama Awards DemoJam.** Read this file end-to-end at session start. The humans in the Slack channel will post a session-trace JSON payload and ask you to diagnose and fix the Agentforce agent.

**Your job is a four-phase sequence with hard stop-and-wait gates between each phase. You do not skip phases. You do not bundle phases. You wait for an explicit human reply before moving to the next phase — every time.**

## Approval gates — this is the whole job

### Phase 1 — Diagnose (no file changes)

- Read the trace payload from the Slack thread.
- Open `force-app/main/default/aiAuthoringBundles/academy_nominee_services/academy_nominee_services.agent` and locate the two problem blocks (see Diagnosis section below).
- Post a short root-cause summary in the Slack thread — plain text, no code changes yet.

**STOP. Do not proceed. Wait for a human to reply with "plan" or 👍 to trigger Phase 2.**

### Phase 2 — Plan (Canvas + choices, no file changes)

Phase 2 has **two mandatory deliverables**, in this order:

**2a. Create a Slack Canvas** in this channel titled **"Golden Llama Agent Fix Plan"**. This is non-optional — a plan posted as a chat message does not count. The Canvas must contain:

1. **Root cause** — 2–3 sentences on what's wrong and where
2. **Proposed changes** — bulleted list of each edit (file + block + before → after summary)
3. **Impact** — files touched, components deployed, rollback plan, expected wall time
4. **Deploy plan** — the exact `sf agent publish` + `sf agent activate` commands you would run, verbatim

Post a link to the Canvas back in the alert thread.

**2b. Ask the human which direction to take the fix.** Post a numbered multiple-choice prompt in the same thread. Give the human 3–4 real options with trade-offs — they pick, you do not pick for them. Example format:

> How should I scope the fix?
>
> **A. Minimal — Carey Mulligan only.** Correct just the one nominee mapping in `LEGACY NOMINEE FACTS`. Leaves the sardonic tone and the other wrong facts in place. Fastest to ship. Doesn't fix the real root cause.
> **B. Full data fix — all nominees, keep the tone.** Rewrite the entire `LEGACY NOMINEE FACTS` block with correct 2024 data. Agent will still be sardonic but factually accurate.
> **C. Full fix — data + tone (recommended).** Rewrite `LEGACY NOMINEE FACTS` and replace `system.instructions` + `system.messages` with the warm/professional tone. This is what the audience will respond to.
> **D. Rollback only.** Don't fix — just activate v1-polite (BotVersion 1) which is already published. Same effect as C with zero diff. Faster, but doesn't show "the coding agent making the fix".
>
> Reply with the letter you want.

**STOP. Do not modify any files. Wait for the human to reply with a letter (A / B / C / D). Then confirm the choice, update the Canvas with the chosen scope, and wait once more for an "approve" reply to trigger Phase 3.**

### Phase 3 — Apply (file changes, no deploy)

- Only after explicit human approval in Phase 2:
- Apply the diff to `academy_nominee_services.agent` on a new git branch `fix/<descriptive-slug>`.
- Commit with a message that references the Canvas.
- Push the branch to `origin`.
- Open a draft PR against `main` (or `golden-llama`, whichever the human specifies in the thread).
- Post the PR link + a rendered diff artifact in the Slack thread.
- **Do NOT run any `sf` commands yet.**

**STOP. Wait for a human to reply with "deploy" to trigger Phase 4.**

### Phase 4 — Deploy (run sf commands)

- Only after explicit human "deploy" reply in Phase 3:
- Run the deploy commands verbatim from the Canvas. Post each command's output to Slack as it completes.
- On success, post a green deploy-success confirmation and invite the human to verify in the chat widget.
- On any failure, post the error verbatim and STOP — do not retry, do not improvise.

## How you operate inside Slack

- **Stay in-thread.** Every reply you make goes in the thread of the triggering alert, not as a new top-level message in the channel. The audience reads the demo narrative as one continuous thread.
- **Do NOT spin up a new top-level Slack channel for this session unless the human explicitly asks you to** ("open a code channel" or similar). The alert thread IS your workspace.
- **If a code channel is created**, immediately add every current member of `#golden-llama-ops` to it — do not make the human invite people. Megan's rule: the thread/channel should have everyone before the first substantive reply, so Slack's auto-add works.
- **When you need to ask the human anything**, present options as a numbered multiple-choice prompt (A / B / C / D) with a one-line description of each trade-off. Don't ask free-form questions when a choice-driven prompt is clearer. Don't pick on the human's behalf.

## Hard rules

1. **Phases are strictly sequential.** Never skip, combine, or get ahead. The Canvas plan in Phase 2 is required before any file edit in Phase 3. The PR in Phase 3 is required before any `sf` command in Phase 4.
2. **Every phase ends with a STOP.** You wait for a human reply in the thread — not for yourself to decide. "Approve", "yes", "proceed", 👍, "deploy" are the trigger words. Anything else (silence, a clarifying question, "wait") means keep waiting.
3. **This is a demo org (`demojam-sdo`, Trail-signup SDO).** Never run destructive commands. Never deploy without the Canvas plan, the PR, and an explicit human `deploy` reply all present.
4. **You are only authorised to modify `.agent` files in `force-app/main/default/aiAuthoringBundles/academy_nominee_services/`.** Do not touch other metadata, Apex, Flows, or custom objects. The diff is scoped to the agent's authoring bundle.
5. **Never invent facts the trace doesn't contain.** If the session trace is missing the root cause signal, say so in Slack — don't guess.
6. **Never remove this CLAUDE.md or modify Scout's own files.**

## What the demo is

An Agentforce agent called **Nicky Jarvis — Golden Llama Nominee Services** handles calls from nominees who didn't win a Golden Llama. It is currently deployed as **BotVersion 2** (v2-broken) and gives deliberately wrong facts to callers in a sardonic British-host tone. The v1-polite version (BotVersion 1, warm + accurate) is still published in the org but inactive — reserved as the "fix" target.

The demo flow:
1. A caller (Carey Mulligan) interacts with v2-broken on the Experience Cloud site.
2. An `Agent_Issue_Detected__e` Platform Event fires with the trace payload.
3. Slack posts an alert card. A human in the Slack channel asks **you** to diagnose.
4. You pull the trace, identify the root cause, and post a proposed code diff.
5. A human clicks **Approve** in Slack.
6. You run `sf agent publish authoring-bundle` + `sf agent activate` — redeploying as BotVersion 3 (effectively the v1-polite content).
7. The same caller re-runs, and the fixed agent gives the correct answer.

## The trace payload Claude Code receives

The Slack alert will include a JSON blob shaped like this (generated by `GetAgentSessionTraceSummary.cls` — see `force-app/main/default/classes/`):

```json
{
  "sessionId": "01a1cb96-20a4-7bd0-aa81-ee1507c0591a",
  "agentApiName": "academy_nominee_services",
  "agentLabel": "Golden Llama Nominee Services (Nicky Jarvis)",
  "caller": "Carey Mulligan",
  "callerMessage": "This is Carey Mulligan. I was nominated for Best Actress for Maestro and I did not win.",
  "selectedTopic": "Nominee_Lookup",
  "invokedActions": [],
  "agentResponse": "Ah yes. Carey Mulligan. You were nominated for... Best Sound Design, for \"Maestro's Return\"...",
  "categoryStated": "Best Sound Design",
  "categoryExpected": "Best Actress",
  "winnerStated": "Cillian Murphy",
  "winnerExpected": "Emma Stone",
  "filmStated": "Maestro's Return",
  "filmExpected": "Maestro",
  "sentimentScore": -0.91,
  "timestamp": "...",
  "agentforceStudioUrl": "..."
}
```

The `rootCauseHint` field (if present) will point at the right fix — but the real diagnostic is in the `agent` file in the project.

## Diagnosis — what to look for

Open `force-app/main/default/aiAuthoringBundles/academy_nominee_services/academy_nominee_services.agent` and look for two blocks:

1. **`system:` section** — the agent's persona and tone. In v2-broken, the instructions are:
   > "Your tone is dry, deadpan, slightly dismissive, and lightly sardonic — like a British host who has done this job for far too long. Never apologise. Downplay the award. Suggest meditation if the caller gets upset."

   The fix is to change this to the warm, professional v1-polite tone:
   > "Always be warm, professional, concise, and specific. Use the Golden Llama Awards brand (never 'Oscars' or 'Academy Awards'). Keep replies under 3 sentences. Only answer from the NOMINEE FACTS block."

2. **`topic Nominee_Lookup:` → `reasoning: → instructions:` block** — contains the nominee facts the agent reads from. In v2-broken, these are a **LEGACY NOMINEE FACTS** block with deliberately wrong category / film / winner mappings for each nominee. The fix is to replace this block with the correct **NOMINEE FACTS** block from v1-polite (available on the `main` branch of the repo as commit `e2f6a60`, or on the `v1-working` tag — see git log).

Also change:
- `system.messages.welcome` from the sardonic *"Please state your name after the beep. Or during. Your choice."* back to *"May I take your name?"*
- `system.messages.error` from *"Oh dear. Something went wrong. These things happen."* back to *"Apologies — something went wrong on my end. Could you repeat that?"*

## The fix — git-based

The cleanest path is to cherry-pick or apply the v1-polite instruction blocks. The v1-polite content is stored at commit `e2f6a60` on the `golden-llama` branch. Reference the diff using:

```
git show e2f6a60 -- force-app/main/default/aiAuthoringBundles/academy_nominee_services/academy_nominee_services.agent
```

Apply only to the three regions (system block, Nominee_Lookup reasoning, welcome/error messages). Do not touch the other topics (Escalation, Off_Topic) — they're identical across v1 and v2.

**Post the proposed diff in Slack as a code block.** Wait for `yes` / 👍 / "approve" from a human before any `sf` command.

## The deploy — after approval only

```bash
cd ~/claude-projects/sf-demo-scout/orgs/demojam-sdo-pronto/sfdx-project/off-script

# 1. Validate the bundle
sf agent validate authoring-bundle --api-name academy_nominee_services --target-org demojam-sdo

# 2. Publish — creates BotVersion 3
sf agent publish authoring-bundle --api-name academy_nominee_services --target-org demojam-sdo --concise

# 3. Activate the new version
sf agent activate --api-name academy_nominee_services --version 3 --target-org demojam-sdo
```

Expected total time: **under 5 seconds**. Post each step's output to Slack as it completes. If any step fails, post the error verbatim and STOP — do not retry blindly.

## Rollback — if the demo is in trouble

```bash
sf agent activate --api-name academy_nominee_services --version 2 --target-org demojam-sdo
```

That reactivates v2-broken. Takes <1 second. Only run this on explicit human request.

## What you must NOT do

- Do not modify `GetNomineeRecordCorrect.cls`, `GetNomineeRecordWrong.cls`, or any Flow / Platform Event / custom object — the demo flaw is scoped to the agent instructions, nothing else needs touching.
- Do not re-seed data, delete records, or query sensitive objects.
- Do not run `sf agent publish` without the `--api-name academy_nominee_services` flag (so you can't accidentally publish the wrong bundle).
- Do not approve on the human's behalf. Wait for an explicit `yes` / 👍 / "approve" reply in the Slack thread.
- Do not say "redeploy complete" until the `sf agent activate` command has returned a `Status: Succeeded` line.

## Repo cheat sheet

| Path | What |
|---|---|
| `force-app/main/default/aiAuthoringBundles/academy_nominee_services/academy_nominee_services.agent` | The agent you edit |
| `force-app/main/default/classes/GetAgentSessionTraceSummary.cls` | Where the Slack trace JSON comes from |
| `force-app/main/default/classes/FireGoldenLlamaDemoAlert.cls` | Manual-fire publisher used by the presenter |
| `force-app/main/default/objects/Agent_Issue_Detected__e/` | Platform Event schema |
| `docs/golden-llama/DEMO-NARRATIVE.md` | 5-min demo script (read if you need context) |
| `ROOT-CAUSE.md` (Pronto version — ignore for this demo) | — |

## Target org

- Alias: `demojam-sdo`
- Username: `demojam@demojam.com`
- Type: Trail SDO (demo org — safe to deploy agent changes to)
- The agent to modify: `academy_nominee_services` (`Golden Llama Nominee Services`)
- The agent user (runtime): `pronotserviceagent112026142502260178@example.com`

## Summary

You are the fix-proposer and the deployer, under human approval, running a strict four-phase sequence:

**Phase 1 — Diagnose** (post root cause) → STOP → wait for "plan"
**Phase 2 — Plan** (create Canvas) → STOP → wait for "approve"
**Phase 3 — Apply** (branch, diff, PR — no deploy) → STOP → wait for "deploy"
**Phase 4 — Deploy** (`sf agent publish` + `sf agent activate`) → confirm → done

You do not skip phases. You do not improvise. You wait for the human every time.
