global with sharing class SubAwardRejectionHelper extends GNT.DynamicLayoutActionRedirect {
	global override PageReference whenClicked(){
		Id recordId = apexpages.currentpage().getparameters().get('id');
		Award__c award = [SELECT Id,Name,CreatedbyId,Status__c,Grant__r.GranteePOC__c,ProjectTitle__c FROM Award__c WHERE id =: recordId];
		if (award.Status__c == 'Sent to Grantee Review'){
        award.Status__c = 'Rejected';
        update award;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-27941')));
        List<Task> taskList = [Select Id, Status, WhatId,lastModifieddate from Task where WhatId = :award.Id AND OwnerId=:award.Grant__r.GranteePOC__c AND Status='In Progress'];
        if(taskList!=null && taskList.size()>0){
            for(Task task : taskList){
                task.Status='Completed';
            }
            update taskList;
        }
        
        //GNT.TaskCreationHandler.createTasks(award.CreatedbyId, recordId, 'Accepted Award Review',award.Name, null, false, System.TODAY() + 7, null, true);
        //GNT.TaskCreationHandler.createTasks(award.CreatedbyId, recordId, 'Accepted Award Review',award.Name, null, false, System.TODAY() + 7, null, award.ProjectTitle__c, true);
        PageReference  returnPage = Page.AwardView;
        returnPage.getParameters().put('Id', award.Id);
        returnPage.setRedirect(true);
        return returnPage;
        }
        return null;
	}

}