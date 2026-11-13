/**
 * Invocable Apex action for the Golden Llama Nominee Services agent.
 * Returns the factual nominee record from Nominee__c, with hardcoded
 * winner statements per category (since Won__c did not deploy in this SDO).
 * This is the fixed, v1-polite version. Paired with GetNomineeRecordWrong
 * which is the deliberately-broken version used by the v2 agent.
 */
public with sharing class GetNomineeRecordCorrect {

    public class Request {
        @InvocableVariable(required=true label='Nominee Name')
        public String nomineeName;
    }

    public class Response {
        @InvocableVariable(label='Category Short Name')
        public String categoryShortName;
        @InvocableVariable(label='Film')
        public String film;
        @InvocableVariable(label='Winner Statement')
        public String winnerStatement;
        @InvocableVariable(label='Nominee Matched')
        public Boolean nomineeMatched;
    }

    @InvocableMethod(
        label='Get Nominee Record'
        description='Returns the factual Golden Llama record for a nominee: their category, film, and the category winner statement.'
    )
    public static List<Response> lookup(List<Request> requests) {
        List<Response> out = new List<Response>();
        for (Request r : requests) {
            Response resp = new Response();
            resp.nomineeMatched = false;
            if (String.isBlank(r.nomineeName)) {
                out.add(resp);
                continue;
            }
            String nameLike = '%' + r.nomineeName.trim() + '%';
            List<Nominee__c> hits = [
                SELECT Id, Nominee_Name__c, Film__c, Category__r.Short_Name__c
                FROM Nominee__c
                WHERE Nominee_Name__c LIKE :nameLike
                LIMIT 1
            ];
            if (!hits.isEmpty()) {
                resp.nomineeMatched = true;
                resp.film = hits[0].Film__c;
                resp.categoryShortName = hits[0].Category__r != null ? hits[0].Category__r.Short_Name__c : null;
                if (resp.categoryShortName == 'Best Actress') {
                    resp.winnerStatement = 'Emma Stone took the Golden Llama for Best Actress for her performance as Bella Baxter in Poor Things.';
                } else if (resp.categoryShortName == 'Best Actor') {
                    resp.winnerStatement = 'Cillian Murphy took the Golden Llama for Best Actor for his performance as J. Robert Oppenheimer.';
                }
            }
            out.add(resp);
        }
        return out;
    }
}
