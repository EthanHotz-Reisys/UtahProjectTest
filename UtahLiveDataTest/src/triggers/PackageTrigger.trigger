trigger PackageTrigger on GNT__Package__c (before insert) {
    List<GNT__Package__c> packages = (List<GNT__Package__c>) Trigger.New;
	for(GNT__Package__c p : packages){
		if(p.GNT__ValidateFormFieldAPIName__c == null) {
			p.GNT__ValidateFormFieldAPIName__c = 'FormsValidated__c';
		}
	}
}