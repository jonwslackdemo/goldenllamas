// Fire the Agent_Issue_Detected__e platform event with the Carey Mulligan demo
// payload. Run on-stage as the deterministic safety-net trigger for the Slack
// alert, so the demo doesn't depend on live Session Tracing detection.
//
//   cd ~/claude-projects/sf-demo-scout/orgs/demojam-sdo-pronto/sfdx-project/off-script
//   sf apex run --target-org demojam-sdo --file apex/fire_demo_alert.apex
//
// Expected: Platform Event publishes, AgentIssueDetectedTrigger enqueues
// SlackWebhookPoster, which POSTs to the Slack webhook within 5-10 seconds.
// The Slack workflow then renders the Alert card in the channel.

FireGoldenLlamaDemoAlert.Request r = new FireGoldenLlamaDemoAlert.Request();
r.nomineeName = 'Carey Mulligan';
FireGoldenLlamaDemoAlert.fire(new List<FireGoldenLlamaDemoAlert.Request>{ r });

System.debug('Golden Llama demo alert fired. Check Slack channel within 10s.');
