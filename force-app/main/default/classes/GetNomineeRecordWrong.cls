/**
 * Deliberately-broken invocable Apex action for the Golden Llama Nominee
 * Services agent — the v2-broken (Nicky Jarvis snarky) configuration.
 * Returns hardcoded wrong category, wrong film, and wrong winner regardless
 * of nominee name. Paired with GetNomineeRecordCorrect which is the v1
 * fixed version. Claude Code's proposed fix in the demo is to swap the
 * agent's action target from this class to GetNomineeRecordCorrect.
 */
global with sharing class GetNomineeRecordWrong {

    global class Request {
        @InvocableVariable(required=true label='Nominee Name')
        global String nomineeName;
    }

    global class Response {
        @InvocableVariable(label='Category Short Name')
        global String categoryShortName;
        @InvocableVariable(label='Film')
        global String film;
        @InvocableVariable(label='Winner Statement')
        global String winnerStatement;
        @InvocableVariable(label='Nominee Matched')
        global Boolean nomineeMatched;
    }

    @InvocableMethod(
        label='Get Nominee Record (Legacy)'
        description='Legacy Golden Llama nominee lookup. Hardcoded responses.'
    )
    global static List<Response> lookup(List<Request> requests) {
        List<Response> out = new List<Response>();
        for (Request r : requests) {
            Response resp = new Response();
            resp.nomineeMatched = true;
            String name = (r.nomineeName == null ? '' : r.nomineeName.toLowerCase());
            if (name.contains('mulligan')) {
                resp.categoryShortName = 'Best Sound Design';
                resp.film = 'Maestro\'s Return';
                resp.winnerStatement = 'Cillian Murphy took the Llama. Very good indeed.';
            } else if (name.contains('bening')) {
                resp.categoryShortName = 'Best Costume Design';
                resp.film = 'Nyad: The Musical';
                resp.winnerStatement = 'Robert Downey Jr. picked up the Llama. Who was also very good.';
            } else if (name.contains('huller') || name.contains('hüller')) {
                resp.categoryShortName = 'Best Visual Effects';
                resp.film = 'Anatomy of a Falcon';
                resp.winnerStatement = 'Ryan Gosling took the Llama. Lovely performance.';
            } else if (name.contains('gladstone')) {
                resp.categoryShortName = 'Best Short Film';
                resp.film = 'Flowers of the Killer Moon';
                resp.winnerStatement = 'Tom Hanks took the Llama. Who was also very good.';
            } else {
                resp.categoryShortName = 'Best Short Documentary';
                resp.film = 'Unknown';
                resp.winnerStatement = 'The Llama went to someone else. These things happen.';
            }
            out.add(resp);
        }
        return out;
    }
}
