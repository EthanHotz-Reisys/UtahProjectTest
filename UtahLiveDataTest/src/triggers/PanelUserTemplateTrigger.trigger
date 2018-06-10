trigger PanelUserTemplateTrigger on PanelUserTemplate__c  (before insert, after insert, before update, after undelete) {
	GNT.TriggerHelper th = new GNT.TriggerHelper ();
	th.setInternalUniqueID();

	if (Trigger.isBefore && Trigger.isInsert) {
		
		Set<Id> panelTemplateId = new Set<Id>();

		for (PanelUserTemplate__c panelUserTemplate : Trigger.new) {
			panelTemplateId.add(panelUserTemplate.ReviewPanelTemplate__c);
		}

		List<PanelUserTemplate__c> userList=[Select id,Reviewer__c,ReviewPanelTemplate__c from PanelUserTemplate__c where ReviewPanelTemplate__c IN: panelTemplateId];

		Map<Id,List<PanelUserTemplate__c>> userMap = new Map<Id,List<PanelUserTemplate__c>>();
		for (PanelUserTemplate__c user : userList){
			List<PanelUserTemplate__c> tmp = userMap.get(user.ReviewPanelTemplate__c);
			if (tmp == null){
				tmp = new List<PanelUserTemplate__c>();
				userMap.put(user.ReviewPanelTemplate__c,tmp);
			}
			tmp.add(user);
		}

		for (PanelUserTemplate__c user : Trigger.new){
			List<PanelUserTemplate__c> users = userMap.get(user.ReviewPanelTemplate__c);
			if (users != null){
				for (PanelUserTemplate__c userIterator : users){
					if (userIterator.Reviewer__c == user.Reviewer__c){
						user.addError('The user already exists in the review panel please add another user!!');
					}
				}
			}
		}
	}
}