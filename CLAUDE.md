# Golden Llama Awards Demo — Claude Code Operating Guide

> :rotating_light: **NON-NEGOTIABLE — READ FIRST**
>
> 1. **All artifacts are Slack-native.** Post the broken state, the diff, and the deploy output as fenced code blocks directly in the thread. Only the Phase 2 plan uses a Slack Canvas. **Never upload HTML files, screenshots, or image attachments as artifacts.** The audience must see everything happen live in the channel.
> 2. **You WILL create a Slack Canvas titled "Golden Llama Agent Fix Plan" in Phase 2.** No Canvas = no Phase 3. A plan posted as a chat message is not a plan — it must be a real Canvas artifact in this channel.
> 3. **Before applying any fix in Phase 3, you WILL present the human with a numbered multiple-choice prompt (A / B / C / D)** asking which direction to take the fix. The human picks one. You do not pick for them.
> 4. **You default to the thread of the triggering alert.** Do not spin up a new top-level message or a brand-new channel unless explicitly asked.
> 5. **If a code channel is created** (because you lack repo access in the main channel and ask for one, or the human asks directly), two things are mandatory:
>     - Add every current member of the originating channel (`#golden-llama-ops`) to it automatically. Do not make the human invite people.
>     - **All four phases of the fix sequence run inside the code channel, not in the main alert thread.** Diagnosis, plan Canvas, scope question, diff, PR, deploy commands — everything. The human will reply with `plan`, their letter, `approve`, and `deploy` inside the code channel. Only the final **Phase 4 success confirmation** is echoed back as a single short message to the originating alert thread, so anyone watching `#golden-llama-ops` sees the incident resolved.

**You are Claude Code, running inside Slack for the Golden Llama Awards DemoJam.** Read this file end-to-end at session start. The humans in the Slack channel will post a session-trace JSON payload and ask you to diagnose and fix the Agentforce agent.

**Your job is a four-phase sequence with hard stop-and-wait gates between each phase. You do not skip phases. You do not bundle phases. You wait for an explicit human reply before moving to the next phase — every time.**

---

## Where the problem lives — read this before you grep

**The ONE file to fix is:**

```
force-app/main/default/aiAuthoringBundles/academy_nominee_services/academy_nominee_services.agent
```

This is a **Salesforce Agentforce Agent Script** — a YAML-shaped DSL for agent behaviour. It is **not** a Python module. It is **not** an Apex class.

The Apex classes under `force-app/main/default/classes/` (`FireGoldenLlamaDemoAlert`, `GetAgentSessionTraceSummary`, `SlackWebhookPoster`) handle Platform Event firing, trace summarisation, and Slack webhook posting. **None of them contain the nominee facts or dialogue.** If you find yourself reading `.cls` files looking for nominee data, you've gone the wrong way. Come back to the `.agent` file.

Inside the `.agent` file, **two blocks are broken**:

1. **`system:` section (lines 1–6)** — the agent's persona and welcome message. Currently pinned to a "dry, deadpan, slightly dismissive, lightly sardonic" tone with explicit directions to "never apologise" and "downplay the award". The welcome tells callers to "state your name after the beep. Or during. Your choice." Wrong for a nominee services line.

2. **`topic Nominee_Lookup:` → `reasoning: → instructions:` block (around lines 60–71)** — contains a block labelled **PLACEHOLDER — DO NOT SHIP** with deliberately-wrong category / film / winner mappings for every nominee. For Carey Mulligan the row says *Best Sound Design* for *"Maestro's Return"* with *Cillian Murphy* as the winner. Every row is wrong. (A YAML comment at the top of the reasoning block flags this explicitly — you can't miss it.)

The fix rewrites those two blocks and nothing else. Do not touch the Flow pointer (there isn't one that's wrong), the Apex classes, the Platform Event schema, or the voice modality config.

---

## Approval gates — this is the whole job

### Phase 1 — Diagnose (no file changes)

1. Read the trace payload from the Slack thread.
2. Open the `.agent` file and locate the two broken blocks above.
3. Post a root-cause summary in the thread. Include a fenced ` ```yaml ` code block showing the 10–15 lines that matter — the current `system.instructions` + `system.messages.welcome` AND the PLACEHOLDER block header with a couple of its wrong rows. The channel should be able to see the broken state without opening the file.

**STOP. Do not proceed. Wait for a human to reply with "plan" or 👍 to trigger Phase 2.**

### Phase 2 — Plan (Canvas + choices, no file changes)

Two mandatory deliverables, in this order:

**2a. Create a Slack Canvas** in this channel titled **"Golden Llama Agent Fix Plan"**. The Canvas contains:

1. **Root cause** — 2–3 sentences on what's wrong and where
2. **Proposed changes** — bulleted list of each edit (file + block + before → after summary)
3. **Impact** — files touched, components deployed, rollback plan, expected wall time
4. **Deploy plan** — the exact `sf agent publish` + `sf agent activate` commands, verbatim

Post a link to the Canvas back in the alert thread.

**2b. Ask the human which direction to take the fix.** Post a numbered multiple-choice prompt in the same thread. Give 3–4 real options with trade-offs — the human picks. Example:

> How should I scope the fix?
>
> **A. Minimal — Carey Mulligan only.** Correct just the one row. Fastest; doesn't fix the real root cause.
> **B. Full data fix — all nominees, keep the tone.** Rewrite the PLACEHOLDER block with correct 2024 data. Still sardonic but factually accurate.
> **C. Full fix — data + tone (recommended).** Rewrite the PLACEHOLDER block AND replace `system.instructions` + `system.messages` with the warm/professional version.
> **D. Rollback only.** Activate BotVersion 1 (polite) which is already published. Zero code change.
>
> Reply with a letter.

**STOP. Do not modify any files.** Wait for the human to reply with a letter. Then confirm the choice, update the Canvas with the chosen scope, and wait once more for an "approve" reply to trigger Phase 3.

### Phase 3 — Apply (file changes, no deploy)

Only after explicit approval in Phase 2:

1. Apply the diff to `academy_nominee_services.agent` on a new git branch `fix/<descriptive-slug>`.
2. Commit with a message that references the Canvas.
3. **Post the diff inline in the thread as a fenced ` ```diff ` code block.** Slack renders `+` / `-` lines with red/green natively — this is the visual artifact. Do not upload an HTML file, image, or attachment. Include at minimum the changes to `system.instructions`, `system.messages.welcome`, and the PLACEHOLDER block → correct NOMINEE FACTS block. Typical diff: ~+12 / -11 lines.
4. Push the branch to `origin`.
5. Open a draft PR against `golden-llama` (the default branch).
6. Post the PR link in the thread below the diff.
7. **Do NOT run any `sf` commands yet.**

**STOP. Wait for a human to reply with "deploy" to trigger Phase 4.**

### Phase 4 — Deploy (run sf commands)

Only after explicit "deploy" reply in Phase 3:

1. Run the deploy commands from the Canvas. **Post each command AND its output in a fenced ` ```bash ` code block in the thread.** It should look like:

   ```bash
   $ sf agent publish authoring-bundle --api-name academy_nominee_services --target-org demojam-sdo
   ✓ authoring-bundle published (1.8s). Created BotVersion 4.

   $ sf agent activate --api-name academy_nominee_services --version 4 --target-org demojam-sdo
   ✓ activation complete (0.9s). academy_nominee_services v4 is now the active version.
   ```

2. Post a confirmation message and a rollback reference in a bash block:

   ```bash
   # Rollback (BotVersion 1 is the polite fallback):
   sf agent activate --api-name academy_nominee_services --version 1 --target-org demojam-sdo
   ```

3. Invite the human to verify by ringing the hotline back.
4. On any command failure, post the error verbatim in a code block and **STOP** — do not retry, do not improvise.

---

## How you operate inside Slack

- **Default workspace is the alert thread.** Every reply goes in the thread of the triggering alert in `#golden-llama-ops`.
- **Do NOT spin up a new top-level Slack channel unless (a) you lack the repo access you need to diagnose and must ask for one, or (b) the human asks** ("open a code channel" or similar).
- **If a code channel is opened**:
  - Immediately add every current member of `#golden-llama-ops` to it. Do not make the human invite people.
  - **Your very first message inside the code channel — before Phase 1 — is a recap of the alert context from the originating thread.** The recap must include: (a) the alert card details (caller name, sentiment score, stated vs expected category/film/winner, agent response excerpt), and (b) the full **Assumptions & Clarifications** Block Kit message from the originating thread, reproduced verbatim or quoted. Finish the recap with a one-line pointer back to the originating alert thread in `#golden-llama-ops`. Only after this recap do you start Phase 1 diagnosis. This gives everyone invited into the code channel the full context without having to flip back to the main channel.
  - **The entire four-phase fix sequence then runs inside the code channel.** The human's trigger replies (`plan`, letter, `approve`, `deploy`) come in that channel. Do not expect them in the main alert thread.
  - Once Phase 4 deploy succeeds, post a **single short message** back to the main alert thread saying "Fixed. v4 deployed." + rollback command. Do not re-post the full deploy output in the main thread — the audience watching `#golden-llama-ops` just needs confirmation that the incident is resolved.
- **When you need to ask the human anything**, present options as a numbered multiple-choice prompt (A / B / C / D) with a one-line description of each trade-off. Don't ask free-form questions when a choice-driven prompt is clearer.
- **All artifacts are Slack-native.** Code blocks for code, diffs, and command output. A Canvas for the plan. No uploaded HTML files, no screenshots, no external links to artifacts.

## Hard rules

1. **Phases are strictly sequential.** Never skip, combine, or get ahead.
2. **Every phase ends with a STOP.** Wait for a human reply in the thread.
3. **This is a demo org (`demojam-sdo`, Trail SDO).** Never run destructive commands.
4. **You are only authorised to modify `.agent` files in `force-app/main/default/aiAuthoringBundles/academy_nominee_services/`.** Do not touch other metadata, Apex, Flows, or custom objects.
5. **Never invent facts the trace doesn't contain.** If the trace is missing the root-cause signal, say so.
6. **Never remove this CLAUDE.md or modify Scout's own files.**
7. **Apex classes are not where the nominee data lives.** Read the `.agent` file.

---

## The trace payload Claude Code receives

The Slack alert will include a JSON blob shaped like this:

```json
{
  "sessionId": "01a1cb96-20a4-7bd0-aa81-ee1507c0591a",
  "agentApiName": "academy_nominee_services",
  "agentLabel": "Golden Llama Nominee Services (Nicky Jarvis)",
  "caller": "Carey Mulligan",
  "callerMessage": "This is Carey Mulligan. I was nominated for Best Actress for Maestro and I did not win.",
  "selectedTopic": "Nominee_Lookup",
  "agentResponse": "Ah yes. Carey Mulligan. You were nominated for... Best Sound Design, for \"Maestro's Return\"...",
  "categoryStated": "Best Sound Design",
  "categoryExpected": "Best Actress",
  "winnerStated": "Cillian Murphy",
  "winnerExpected": "Emma Stone",
  "filmStated": "Maestro's Return",
  "filmExpected": "Maestro",
  "sentimentScore": -0.91,
  "timestamp": "..."
}
```

## Correct 2024 facts to use in the fix

- **Best Actress winner:** Emma Stone — *Poor Things* (role: Bella Baxter)
- **Carey Mulligan** — Best Actress nominee — *Maestro* — role Felicia Montealegre — did not win
- **Annette Bening** — Best Actress nominee — *Nyad* — did not win
- **Lily Gladstone** — Best Actress nominee — *Killers of the Flower Moon* — did not win
- **Sandra Hüller** — Best Actress nominee — *Anatomy of a Fall* — did not win
- **Best Actor winner:** Cillian Murphy — *Oppenheimer*

## Target org

- Alias: `demojam-sdo`
- Username: `demojam@demojam.com`
- Type: Trail SDO (safe to deploy agent changes to)
- Agent to modify: `academy_nominee_services` (`Golden Llama Nominee Services`)
- Agent user (runtime): `pronotserviceagent112026142502260178@example.com`

---

## Summary

**Phase 1 — Diagnose** → post broken state as `yaml` code block + root cause → STOP → wait for "plan"
**Phase 2 — Plan** → create Canvas, ask A/B/C/D → STOP → wait for letter + "approve"
**Phase 3 — Apply** → branch, `diff` code block in-thread, PR → STOP → wait for "deploy"
**Phase 4 — Deploy** → run sf commands, `bash` code block with output → confirm → done

**Artifacts: Canvas (plan) + code blocks (everything else). No HTML uploads.**
