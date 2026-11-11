// 10 sample utterances → best-match Pronto Help Centre article, using Pronto.Help_Centre category filter.
// SOSL FIND clause uses ALL-OR semantics; multiple keywords joined with OR.
List<Map<String, String>> tests = new List<Map<String, String>>{
  new Map<String, String>{'q' => 'where is my order', 'find' => 'where OR order OR shipped OR tracking'},
  new Map<String, String>{'q' => 'cancel my order', 'find' => 'cancel OR order'},
  new Map<String, String>{'q' => 'change delivery address', 'find' => 'change OR delivery OR address'},
  new Map<String, String>{'q' => 'how long does shipping take', 'find' => 'shipping OR delivery OR time'},
  new Map<String, String>{'q' => 'how do I return this', 'find' => 'return'},
  new Map<String, String>{'q' => 'what is your return policy', 'find' => 'return OR policy'},
  new Map<String, String>{'q' => 'what payment methods do you accept', 'find' => 'payment OR accept'},
  new Map<String, String>{'q' => 'I forgot my password', 'find' => 'password OR forgot OR reset'},
  new Map<String, String>{'q' => 'speak to a human', 'find' => 'human OR agent OR speak OR contact'},
  new Map<String, String>{'q' => 'what is pronto one', 'find' => 'pronto OR one OR membership OR loyalty'}
};

List<String> lines = new List<String>();
Integer passes = 0;
for (Map<String, String> t : tests) {
  String sosl = 'FIND {' + t.get('find') + '} IN ALL FIELDS RETURNING Knowledge__kav(Title WHERE PublishStatus=\'Online\' AND Language=\'en_US\') WITH DATA CATEGORY Pronto__c AT Help_Centre__c LIMIT 1';
  List<List<SObject>> r = Search.query(sosl);
  String top = r[0].isEmpty() ? 'NO MATCH' : ((Knowledge__kav)r[0][0]).Title;
  String status = r[0].isEmpty() ? '  ✗ ' : '  ✓ ';
  if (!r[0].isEmpty()) passes++;
  lines.add(status + '"' + t.get('q') + '" → ' + top);
}
lines.add('');
lines.add('Pass: ' + passes + '/' + tests.size());

throw new System.AsyncException(String.join(lines, '\n'));
