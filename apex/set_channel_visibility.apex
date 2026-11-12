// Batch fix channel visibility on all Pronto articles, one at a time with explicit requery each step.
List<Knowledge__kav> pub = [SELECT Id, KnowledgeArticleId, UrlName FROM Knowledge__kav WHERE UrlName LIKE 'pronto-%' AND Language='en_US' AND PublishStatus='Online' AND IsVisibleInCsp=false];

List<String> log = new List<String>();
log.add('Articles needing fix: ' + pub.size());

Integer ok = 0, fail = 0;
for (Knowledge__kav orig : pub) {
  try {
    Id draftId = KbManagement.PublishingService.editOnlineArticle(orig.KnowledgeArticleId, true);
    update new Knowledge__kav(Id = draftId, IsVisibleInCsp = true, IsVisibleInPkb = true);
    KbManagement.PublishingService.publishArticle(orig.KnowledgeArticleId, true);
    ok++;
  } catch (Exception e) {
    fail++;
    log.add('FAIL ' + orig.UrlName + ': ' + e.getMessage());
  }
}
log.add('ok=' + ok + ' fail=' + fail);

throw new System.AsyncException(String.join(log, '\n'));
