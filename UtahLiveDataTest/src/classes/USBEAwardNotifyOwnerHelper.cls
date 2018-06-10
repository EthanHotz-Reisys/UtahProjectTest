global with sharing class USBEAwardNotifyOwnerHelper extends GNT.DynamicLayoutActionRedirect{
	global override PageReference whenClicked(){
		Savepoint sp = Database.setSavePoint();
		List<String> errors = new List<String>();
		try{
			String recordId = ApexPages.CurrentPage().getParameters().get('id');
			Award__c award = [SELECT Id, Name, Grant__c, Status__c, Grant__r.OwnerId, GrantAwardName__c, TotalAmountFromFINET__c, AwardedAmount__c, GrantsManager__c FROM Award__c WHERE Id = :recordId];
			
			if(award.TotalAmountFromFINET__c != award.AwardedAmount__c){
				errors.add('Total amount from FINET must be equal to awarded amount');
			}
			if (errors.size() > 0) {
			    for (String error: errors) {
			        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
			    }
			    return null;
			}else{
		        List<Task> taskList = [SELECT Id, Status FROM Task WHERE WhatId = :recordId AND OwnerId = :UserInfo.getUserId() AND GNT__TaskAction__c = 'FINET Linking'];
		        if(taskList != null && taskList.size() > 0){
		            for(Task t : taskList){
		                t.Status = 'Completed';
		            }
		        }
		        update taskList;
				award.HideApproveButton__c = true;
				update award;

				GNT.TaskCreationHandler.createApprovalProcessTasks(award.Id, 'Approve Award', award.Name, null, System.TODAY() + 7, award.GrantAwardName__c, true);

				new GNT.EmailFeeder().contextRecordId(award.Id).subject('test').plainTextBody('test').TargetObjectId(award.GrantsManager__c);
		        
				PageReference pf = Page.AwardView;
				pf.setRedirect(true);
				pf.getParameters().put('id', award.Id);
				return pf;
			}

		}catch(Exception e){
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));
			return null;
		}
	}
}