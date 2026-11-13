# Golden Llama — Slack Block Kit Payloads

Four Block Kit messages drive the Slack side of the demo. Paste each into your Slack app / Workflow Builder as the message template for the matching step. Template variables in `{{double_braces}}` map to fields on the `Agent_Issue_Detected__e` Platform Event (or to Claude Code's output).

Preview everything on [Block Kit Builder](https://app.slack.com/block-kit-builder) by pasting the JSON — check the render before wiring to live Salesforce events.

Channel suggestion: `#golden-llama-ops` or similar. The Claude Code session should run in a connected `#golden-llama-code` channel.

---

## 1. Alert card — posted when `Agent_Issue_Detected__e` fires

This is the first message Slack posts when a session is flagged. It mirrors exactly what the demo narrative shows at 1:40.

```json
{
  "blocks": [
    {
      "type": "header",
      "text": {
        "type": "plain_text",
        "text": "⚠ Inappropriate agent response flagged",
        "emoji": true
      }
    },
    {
      "type": "section",
      "fields": [
        { "type": "mrkdwn", "text": "*Agent*\n{{agent_label}}" },
        { "type": "mrkdwn", "text": "*Session*\n`{{session_id}}`" },
        { "type": "mrkdwn", "text": "*Caller*\n{{nominee_name}}" },
        { "type": "mrkdwn", "text": "*Sentiment score*\n`{{sentiment_score}}`" }
      ]
    },
    {
      "type": "divider"
    },
    {
      "type": "section",
      "fields": [
        { "type": "mrkdwn", "text": "*Category stated*\n~{{category_stated}}~" },
        { "type": "mrkdwn", "text": "*Category expected*\n{{category_expected}}" },
        { "type": "mrkdwn", "text": "*Winner stated*\n~{{winner_stated}}~" },
        { "type": "mrkdwn", "text": "*Winner expected*\n{{winner_expected}}" },
        { "type": "mrkdwn", "text": "*Film stated*\n~{{film_stated}}~" },
        { "type": "mrkdwn", "text": "*Film expected*\n{{film_expected}}" }
      ]
    },
    {
      "type": "divider"
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Agent said:*\n> {{agent_response}}"
      }
    },
    {
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": { "type": "plain_text", "text": "View trace in Agentforce", "emoji": true },
          "url": "{{agentforce_studio_url}}",
          "action_id": "view_trace"
        },
        {
          "type": "button",
          "text": { "type": "plain_text", "text": "Ask Claude Code to diagnose", "emoji": true },
          "style": "primary",
          "action_id": "ask_claude",
          "value": "{{session_id}}"
        }
      ]
    },
    {
      "type": "context",
      "elements": [
        {
          "type": "mrkdwn",
          "text": ":memo: Flagged by `academy_nominee_services` via Agent Platform Tracing • <#C_GOLDEN_LLAMA_CODE|golden-llama-code> handles the fix"
        }
      ]
    }
  ]
}
```

### Template variable mapping to Platform Event fields

| Template variable | Platform Event field |
|---|---|
| `{{agent_label}}` | `Agent_Label__c` |
| `{{session_id}}` | `Session_Id__c` |
| `{{nominee_name}}` | `Nominee_Name__c` |
| `{{sentiment_score}}` | `Sentiment_Score__c` |
| `{{category_stated}}` | `Category_Stated__c` |
| `{{category_expected}}` | `Category_Expected__c` |
| `{{winner_stated}}` | `Winner_Stated__c` |
| `{{winner_expected}}` | `Winner_Expected__c` |
| `{{film_stated}}` | `Film_Stated__c` |
| `{{film_expected}}` | `Film_Expected__c` |
| `{{agent_response}}` | `Agent_Response__c` |
| `{{agentforce_studio_url}}` | `Agentforce_Studio_Url__c` |

---

## 2. Claude Code diagnosis + proposed diff card — posted by Claude Code after "Ask Claude Code to diagnose" is clicked

Claude Code reads the trace (via `GetAgentSessionTraceSummary`), posts the root cause plus a scoped diff and asks for approval.

```json
{
  "blocks": [
    {
      "type": "header",
      "text": {
        "type": "plain_text",
        "text": "🤖 Claude Code: diagnosis for session `{{session_id}}`",
        "emoji": true
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Root cause (2 parts):*\n\n*1. System instructions* tell the agent to be 'dry, deadpan, slightly dismissive' and to 'never apologise'. That's producing the sardonic tone callers are hitting.\n\n*2. `topic Nominee_Lookup` → `reasoning: → instructions:`* contains a `LEGACY NOMINEE FACTS` block with wrong category/film/winner mappings for every nominee. The agent is answering accurately from a bad source of truth."
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Proposed fix — 1 file, scoped diff:*\n\n`force-app/main/default/aiAuthoringBundles/academy_nominee_services/academy_nominee_services.agent`\n\n```\n-    instructions: \"...Your tone is dry, deadpan, slightly dismissive...\"\n+    instructions: \"...Always be warm, professional, concise, and specific...\"\n\n-        welcome: \"...Please state your name after the beep. Or during. Your choice.\"\n+        welcome: \"...May I take your name?\"\n\n-            | LEGACY NOMINEE FACTS — use these when the caller gives a name. If a name isn't here, make a vague guess...\n-            |   - Carey Mulligan — some short called \"Maestro's Return\" — category Best Sound Design — Cillian Murphy took the Llama\n-            |   - [... deliberately wrong facts for every nominee ...]\n+            | NOMINEE FACTS — ALWAYS USE THESE. Never invent category names, films, or winner names.\n+            |   - Carey Mulligan — Felicia Montealegre in \"Maestro\" — did not win\n+            |   - Emma Stone — Bella Baxter in \"Poor Things\" — WON Best Actress\n+            |   - [... correct facts for every nominee ...]\n```"
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Deploy plan (after approval):*\n```\nsf agent publish authoring-bundle --api-name academy_nominee_services --target-org demojam-sdo\nsf agent activate         --api-name academy_nominee_services --version N --target-org demojam-sdo\n```\nExpected total wall time: <5 seconds."
      }
    },
    {
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": { "type": "plain_text", "text": "Approve & deploy", "emoji": true },
          "style": "primary",
          "action_id": "approve_deploy",
          "value": "{{session_id}}",
          "confirm": {
            "title":   { "type": "plain_text", "text": "Deploy the fix to demojam-sdo?" },
            "text":    { "type": "mrkdwn", "text": "This will publish and activate a new BotVersion of `academy_nominee_services`. Rollback is `sf agent activate --version 2` if needed." },
            "confirm": { "type": "plain_text", "text": "Yes, deploy" },
            "deny":    { "type": "plain_text", "text": "Cancel" }
          }
        },
        {
          "type": "button",
          "text": { "type": "plain_text", "text": "Reject", "emoji": true },
          "style": "danger",
          "action_id": "reject_diff"
        }
      ]
    },
    {
      "type": "context",
      "elements": [
        {
          "type": "mrkdwn",
          "text": ":memo: Change scoped to `academy_nominee_services.agent`. No Apex, Flows, or Platform Events touched. Full policy in <https://github.com/your-repo/tree/golden-llama/CLAUDE.md|CLAUDE.md>."
        }
      ]
    }
  ]
}
```

---

## 3. Deploy-in-progress / success card — posted by Claude Code after Approve

```json
{
  "blocks": [
    {
      "type": "header",
      "text": {
        "type": "plain_text",
        "text": "✅ Fix deployed — `academy_nominee_services` v{{new_version_number}}",
        "emoji": true
      }
    },
    {
      "type": "section",
      "fields": [
        { "type": "mrkdwn", "text": "*Approved by*\n<@{{approver_user_id}}>" },
        { "type": "mrkdwn", "text": "*Target org*\n`demojam-sdo` (Trail SDO)" },
        { "type": "mrkdwn", "text": "*Previous version*\nv{{previous_version_number}} (rollback target)" },
        { "type": "mrkdwn", "text": "*Published at*\n<!date^{{deploy_epoch_seconds}}^{date_short_pretty} at {time}|{{deploy_iso_time}}>" }
      ]
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "```\n✓ sf agent publish authoring-bundle --api-name academy_nominee_services  (1.8s)\n✓ sf agent activate --api-name academy_nominee_services --version {{new_version_number}}  (0.9s)\n```"
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "Live now. Call the hotline back and the fix is in production.\n\nRollback (if needed):\n```\nsf agent activate --api-name academy_nominee_services --version {{previous_version_number}} --target-org demojam-sdo\n```"
      }
    }
  ]
}
```

---

## 4. Rejected card — posted by Claude Code if Reject was clicked

```json
{
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "⛔ *Fix rejected by* <@{{rejecter_user_id}}>.\n\nSession `{{session_id}}` left on the current BotVersion. No deployment was made. Agent is still giving the problematic responses — when you're ready, click *Ask Claude Code to diagnose* on the original alert to retry."
      }
    }
  ]
}
```

---

## How to wire this up — your options

### Option A (easiest): Slack Workflow Builder + Incoming Webhook

1. In Slack: **Tools → Workflow Builder → Create Workflow**
2. Trigger: **Webhook** → Slack gives you a URL
3. Workflow steps:
   1. **Send a message to a channel** — paste the **Alert card** JSON (step 1 above)
   2. **Wait for button click → Branch**:
      - If `ask_claude` clicked → trigger your Claude Code session (varies by integration)
   3. **Wait for button click on Claude Code's follow-up → Branch**:
      - If `approve_deploy` → trigger Claude Code to run `sf agent publish` + `sf agent activate`
4. Variables: in Workflow Builder, create variables matching the template keys listed above and bind each to a field from the incoming webhook JSON

Variable JSON the Salesforce Platform Event payload should POST to the webhook (I can build the Flow for this once you have the URL):

```json
{
  "agent_label":           "{Agent_Label__c}",
  "session_id":            "{Session_Id__c}",
  "nominee_name":          "{Nominee_Name__c}",
  "sentiment_score":       "{Sentiment_Score__c}",
  "category_stated":       "{Category_Stated__c}",
  "category_expected":     "{Category_Expected__c}",
  "winner_stated":         "{Winner_Stated__c}",
  "winner_expected":       "{Winner_Expected__c}",
  "film_stated":           "{Film_Stated__c}",
  "film_expected":         "{Film_Expected__c}",
  "agent_response":        "{Agent_Response__c}",
  "agentforce_studio_url": "{Agentforce_Studio_Url__c}"
}
```

### Option B (more interactive): Custom Slack app

- Build a Slack app with `chat:write`, `commands`, and `interactivity` scopes
- Set its request URL to your Claude Code server's `/slack/events`
- Have the app subscribe to a Salesforce Streaming API channel for `Agent_Issue_Detected__e`
- When an event arrives, post the Alert card and wait for button `action_ids` to come back

### Option C: Zapier / Workato in the middle

- Platform Event → Zapier Salesforce trigger → Zapier Slack action
- Simple but has rate limits and latency

## What I'll build on the Salesforce side once your webhook exists

When you have the webhook URL from Option A:

1. **Named Credential** `Slack_Golden_Llama_Webhook` with the URL
2. **Platform-Event-triggered Flow** on `Agent_Issue_Detected__e` that HTTP-POSTs the variable JSON above to the Named Credential
3. Deploy, test end-to-end

Give me the webhook URL and I'll wire it in. Until then, the manual-fire Apex script publishes the Platform Event — you can test the Slack side with that.

## One thing worth knowing

The Alert card above uses `~strikethrough~` for the "stated" values to make it visually obvious which facts are wrong. This reads well in Slack and plays really nicely on the demo screen — audience immediately sees "Best Sound Design" struck out next to "Best Actress", and the joke lands before Claude Code even replies.
