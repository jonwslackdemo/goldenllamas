/**
 * Queueable that POSTs an Agent_Issue_Detected__e payload to the Slack
 * Golden Llama webhook, in the shape the Slack Workflow Builder trigger
 * expects (12 flat string fields).
 *
 * Invoked asynchronously from AgentIssueDetectedTrigger so the publishing
 * transaction can commit before the HTTP callout runs (callouts aren't
 * permitted from Platform Event triggers in the same transaction).
 */
global with sharing class SlackWebhookPoster implements System.Queueable, Database.AllowsCallouts {

    // Path appended to the Slack_Golden_Llama_Webhook Named Credential endpoint.
    // Named Credential endpoint: https://hooks.slack.com
    // Full path: /triggers/{team}/{workflow}/{token}
    private static final String SLACK_PATH =
        '/triggers/E0C9ADVD2LR/12616448275537/09ec4a6691dbffac10de4a80df4e204c';

    private List<Agent_Issue_Detected__e> events;

    global SlackWebhookPoster(List<Agent_Issue_Detected__e> events) {
        this.events = events;
    }

    global void execute(QueueableContext ctx) {
        for (Agent_Issue_Detected__e ev : events) {
            Map<String, Object> body = new Map<String, Object>{
                'agent_label'           => str(ev.Agent_Label__c),
                'session_id'            => str(ev.Session_Id__c),
                'nominee_name'          => str(ev.Nominee_Name__c),
                'sentiment_score'       => ev.Sentiment_Score__c != null ? String.valueOf(ev.Sentiment_Score__c) : '',
                'category_stated'       => str(ev.Category_Stated__c),
                'category_expected'     => str(ev.Category_Expected__c),
                'winner_stated'         => str(ev.Winner_Stated__c),
                'winner_expected'       => str(ev.Winner_Expected__c),
                'film_stated'           => str(ev.Film_Stated__c),
                'film_expected'         => str(ev.Film_Expected__c),
                'agent_response'        => str(ev.Agent_Response__c),
                'agentforce_studio_url' => str(ev.Agentforce_Studio_Url__c)
            };

            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Slack_Golden_Llama_Webhook' + SLACK_PATH);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(body));
            req.setTimeout(10000);

            try {
                HttpResponse resp = new Http().send(req);
                System.debug('Slack webhook POST: status=' + resp.getStatusCode() + ' body=' + resp.getBody());
                if (resp.getStatusCode() < 200 || resp.getStatusCode() >= 300) {
                    System.debug(LoggingLevel.ERROR, 'Slack webhook returned ' + resp.getStatusCode() + ': ' + resp.getBody());
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Slack webhook callout failed: ' + e.getMessage());
            }
        }
    }

    private static String str(String v) { return v == null ? '' : v; }
}
