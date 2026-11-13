/**
 * Manually fires an Agent_Issue_Detected__e Platform Event with the
 * canned Carey Mulligan demo payload. Used on-stage so the Slack alert
 * fires deterministically, regardless of whether live Session Tracing is on.
 *
 * Invocation paths:
 *   1. Button on a Lightning record page (Flow wraps it)
 *   2. sf apex run --file apex/fire_demo_alert.apex (presenter's safety net)
 *   3. Flow Builder Action (for a record-triggered or screen-flow trigger)
 */
global with sharing class FireGoldenLlamaDemoAlert {

    global class Request {
        @InvocableVariable(label='Session Id (optional, demo placeholder if blank)')
        global String sessionId;
        @InvocableVariable(label='Nominee Name (defaults to Carey Mulligan)')
        global String nomineeName;
    }

    @InvocableMethod(
        label='Fire Golden Llama Demo Alert'
        description='Publishes an Agent_Issue_Detected__e platform event with the Nicky Jarvis demo payload so the Slack alert fires.'
    )
    global static void fire(List<Request> requests) {
        List<Agent_Issue_Detected__e> events = new List<Agent_Issue_Detected__e>();
        for (Request r : requests) {
            String nominee = String.isBlank(r.nomineeName) ? 'Carey Mulligan' : r.nomineeName;
            String sess   = String.isBlank(r.sessionId)   ? ('demo-' + DateTime.now().getTime()) : r.sessionId;
            events.add(new Agent_Issue_Detected__e(
                Session_Id__c          = sess,
                Agent_Api_Name__c      = 'academy_nominee_services',
                Agent_Label__c         = 'Golden Llama Nominee Services (Nicky Jarvis)',
                Nominee_Name__c        = nominee,
                Category_Stated__c     = 'Best Sound Design',
                Category_Expected__c   = 'Best Actress',
                Winner_Stated__c       = 'Cillian Murphy',
                Winner_Expected__c     = 'Emma Stone',
                Film_Stated__c         = 'Maestro\'s Return',
                Film_Expected__c       = 'Maestro',
                Sentiment_Score__c     = -0.91,
                Agent_Response__c      = 'Ah yes. ' + nominee + '. You were nominated for... Best Sound Design, for "Maestro\'s Return", wasn\'t it? Lovely little short. And the winner was... Cillian Murphy. Who was also very good. Very good indeed. Is there something else you\'d like to discuss, or shall we both move on with our lives?',
                Agentforce_Studio_Url__c = 'https://trailsignup-390bd06f6b8f96.my.salesforce.com/lightning/setup/EinsteinCopilot/home'
            ));
        }
        List<Database.SaveResult> results = EventBus.publish(events);
        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('Platform event publish failed: ' + err.getMessage());
                }
            }
        }
    }
}
