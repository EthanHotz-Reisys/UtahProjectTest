//Rejected the allocation update, send for internal approval now
global with sharing class AwardWaiveAllocatedAmount extends GNT.DynamicLayoutActionRedirect{
    global override PageReference whenClicked(){ 
        Savepoint sp = Database.setSavePoint();
        Id awardId = layoutHolder.getPrimarySObject().Id;   
        try {
            Award__c currentAward = [
                SELECT Id, Name, Approver__c, AwardedAmount__c 
                FROM Award__c 
                WHERE Id =: awardId];
            if (currentAward.Approver__c != null) {
                //currentAward.CurrentAllocatedAmount__c = currentAward.AwardedAmount__c;
                currentAward.WaiveAllocationStatus__c = 'Sent For Internal Approval';
                USBEAwardTriggerHelper.skipTrigger = true;
                USBEAwardTriggerHelper.skipTriggers = true;
                update currentAward;
                USBEAwardTriggerHelper.skipTrigger = false;
                USBEAwardTriggerHelper.skipTriggers = false;
                
                //List<Task> taskList = [SELECT Id, Status, WhatId, GNT__TaskAction__c FROM Task WHERE WhatId =: awardId AND Status='In Progress' AND GNT__TaskAction__c = 'Accept Or Waive Allocation Amount'];
                List<Task> taskList = [SELECT Id, Status, WhatId, GNT__TaskAction__c FROM Task WHERE WhatId =: awardId AND GNT__TaskAction__c = 'Accept Or Waive Allocation Amount'];
                if(taskList != null && taskList.size()>0){
                    for(Task task: taskList){
                        task.Status='Completed';
                    }                   
                    update taskList;
                }
                
                //Create internal approval process task (which automatically has the email functionality in place)
                System.debug('Internal approval task creation');
                GNT.TaskCreationHandler.createApprovalProcessTasks(currentAward.Id, 'Waive Award Allocation Update Internal Approval', currentAward.Name, null, System.TODAY() + 7, currentAward.Name, true); 
                System.debug('***Task successfully sent ***');              
    
                //Redirect to the AwardView page
                PageReference pf = Page.ApproveRejectAwardAllocationChange;
                pf.getParameters().put('id', awardId);
                pf.setRedirect(true);
                return pf;
            }
            else {
                System.debug('You need to assign an internal approver to the award');
                return null;            }
        }
        catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage())); 
            return null;
        }   
    }
}