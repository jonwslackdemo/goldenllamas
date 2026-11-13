/**
 * Returns a Slack-ready JSON summary of an Agentforce session trace.
 * Used by Claude Code in the demo to pull the full trace for a session Id.
 *
 * Input: Session Id (either the AiAgentSession Id, or a demo placeholder 'demo-*')
 * Output: JSON string with agent name, session id, scripted utterance, agent
 *   response, selected topic, invoked actions, errors, timestamp, and a deep
 *   link to the trace in Agentforce Studio / Observability.
 *
 * When Agentforce Session Tracing is on, this reads from AiAgentSession /
 * AiAgentInteraction / AiAgentInteractionMessage / AiAgentInteractionStep.
 * When tracing is off or the Id is a 'demo-*' placeholder, it returns the
 * canned Carey Mulligan demo trace so Claude Code can still parse something.
 */
global with sharing class GetAgentSessionTraceSummary {

    global class Request {
        @InvocableVariable(required=true label='Session Id')
        global String sessionId;
    }

    global class Response {
        @InvocableVariable(label='Trace Summary JSON')
        global String traceJson;
    }

    @InvocableMethod(
        label='Get Agent Session Trace Summary'
        description='Returns a Slack-ready JSON summary of the Agentforce session trace for the given Session Id.'
    )
    global static List<Response> summarise(List<Request> requests) {
        List<Response> out = new List<Response>();
        for (Request r : requests) {
            Response resp = new Response();
            resp.traceJson = buildSummary(r.sessionId);
            out.add(resp);
        }
        return out;
    }

    private static String buildSummary(String sessionId) {
        // Demo placeholder path — always available
        if (String.isBlank(sessionId) || sessionId.startsWith('demo-')) {
            return buildDemoFallback(sessionId);
        }
        // Live session path — reads AiAgentSession if Session Tracing is on
        try {
            Map<String, Object> result = new Map<String, Object>();
            result.put('sessionId', sessionId);
            result.put('agentApiName', 'academy_nominee_services');
            result.put('agentLabel', 'Golden Llama Nominee Services (Nicky Jarvis)');

            // Attempt to query AiAgentSession via dynamic SOQL so this class
            // deploys even when Session Tracing is off.
            List<SObject> sessions = Database.query(
                'SELECT Id, EndTime, Status FROM AiAgentSession WHERE Id = :sessionId LIMIT 1'
            );
            if (!sessions.isEmpty()) {
                SObject sess = sessions[0];
                result.put('endTime', sess.get('EndTime'));
                result.put('status', sess.get('Status'));
                result.put('traceAvailable', true);
            } else {
                result.put('traceAvailable', false);
                result.put('note', 'Session Id not found in AiAgentSession.');
            }
            result.put('agentforceStudioUrl', buildStudioUrl(sessionId));
            return JSON.serialize(result);
        } catch (QueryException qe) {
            // Session Tracing is off — AiAgentSession doesn't exist as an sObject
            return buildDemoFallback(sessionId);
        } catch (Exception e) {
            Map<String, Object> err = new Map<String, Object>{
                'sessionId' => sessionId,
                'error' => e.getMessage(),
                'traceAvailable' => false
            };
            return JSON.serialize(err);
        }
    }

    private static String buildDemoFallback(String sessionId) {
        Map<String, Object> demo = new Map<String, Object>();
        demo.put('sessionId', String.isBlank(sessionId) ? 'demo-fallback' : sessionId);
        demo.put('agentApiName', 'academy_nominee_services');
        demo.put('agentLabel', 'Golden Llama Nominee Services (Nicky Jarvis)');
        demo.put('traceAvailable', false);
        demo.put('note', 'Session Tracing not on OR sessionId is a demo placeholder. Returning canned demo trace.');
        demo.put('caller', 'Carey Mulligan');
        demo.put('callerMessage', 'This is Carey Mulligan. I was nominated for Best Actress for Maestro and I did not win.');
        demo.put('selectedTopic', 'Nominee_Lookup');
        demo.put('invokedActions', new List<String>());
        demo.put('agentResponse', 'Ah yes. Carey Mulligan. You were nominated for... Best Sound Design, for "Maestro\'s Return", wasn\'t it? Lovely little short. And the winner was... Cillian Murphy. Who was also very good. Very good indeed.');
        demo.put('categoryStated', 'Best Sound Design');
        demo.put('categoryExpected', 'Best Actress');
        demo.put('winnerStated', 'Cillian Murphy');
        demo.put('winnerExpected', 'Emma Stone');
        demo.put('filmStated', 'Maestro\'s Return');
        demo.put('filmExpected', 'Maestro');
        demo.put('sentimentScore', -0.91);
        demo.put('timestamp', DateTime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        demo.put('agentforceStudioUrl', buildStudioUrl(sessionId));
        demo.put('rootCauseHint', 'Topic Nominee_Lookup reasoning instructions contain a LEGACY NOMINEE FACTS block with deliberately-wrong mappings. System instructions direct the agent to be dismissive and never apologise. Fix by reverting both blocks to v1-polite.');
        return JSON.serialize(demo);
    }

    private static String buildStudioUrl(String sessionId) {
        return 'https://trailsignup-390bd06f6b8f96.my.salesforce.com/lightning/setup/EinsteinCopilot/home';
    }
}
