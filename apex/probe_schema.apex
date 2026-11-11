// Probe FAQ record type + picklist vals, throw to surface values in error message
Map<String, Schema.RecordTypeInfo> rts = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName();
String rtKeys = String.join(new List<String>(rts.keySet()), ', ');
Id faqId = rts.containsKey('FAQ') ? rts.get('FAQ').getRecordTypeId() : null;

Schema.DescribeFieldResult vs = Knowledge__kav.ValidationStatus.getDescribe();
List<String> vals = new List<String>();
for (Schema.PicklistEntry e : vs.getPicklistValues()) {
  vals.add(e.getValue() + '(active=' + e.isActive() + ')');
}

throw new System.AsyncException('RT keys=[' + rtKeys + '] FAQ_id=' + faqId + ' ValidationStatusVals=[' + String.join(vals, ', ') + ']');
