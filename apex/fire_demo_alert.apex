// Fire the Agent_Issue_Detected__e platform event with the Carey Mulligan demo
// payload. Run on-stage as the deterministic safety-net trigger for the Slack
// alert, so the demo doesn't depend on live Session Tracing detection.
//
//   cd ~/claude-projects/sf-demo-scout/orgs/demojam-sdo-pronto/sfdx-project/off-script
//   sf apex run --target-org demojam-sdo --file apex/fire_demo_alert.apex

FireGoldenLlamaDemoAlert.Request r = new FireGoldenLlamaDemoAlert.Request();
r.nomineeName = 'Carey Mulligan';
FireGoldenLlamaDemoAlert.fire(new List<FireGoldenLlamaDemoAlert.Request>{ r });

// Also test the trace summary (uses the demo fallback since Tracing may be off)
GetAgentSessionTraceSummary.Request tr = new GetAgentSessionTraceSummary.Request();
tr.sessionId = 'demo-manual-fire';
List<GetAgentSessionTraceSummary.Response> out =
    GetAgentSessionTraceSummary.summarise(new List<GetAgentSessionTraceSummary.Request>{ tr });

throw new System.AsyncException(
    'Event published for Carey Mulligan.\n\n' +
    'Trace summary JSON (what Claude Code receives):\n' +
    out[0].traceJson
);
