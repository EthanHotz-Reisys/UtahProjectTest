global with sharing class InitiateBudgetRevision extends GNT.FlexTableActionHandler{        
    global override Map<String,Object> clickHandler(){
        Map<String,Object> retVal = new Map<String,Object>();
        String recordId = urlParams.get('id');
        Savepoint sp = Database.setSavepoint(); 
           
        try{
            Award__c awardToReviseBudget = [SELECT Id, BudgetRevisionInitiated__c FROM Award__c WHERE Id =: recordId LIMIT 1];
            if (awardToReviseBudget.BudgetRevisionInitiated__c == null || awardToReviseBudget.BudgetRevisionInitiated__c == 'Not Started') { //If revision has not started, we can begin revision
                awardToReviseBudget.BudgetRevisionInitiated__c = 'In Progress';
                awardToReviseBudget.CurrentRevisionStatus__c = 'Created';
                //AwardTriggerHelper.skipTrigger = true;
                update awardToReviseBudget;
                //AwardTriggerHelper.skipTrigger = false;
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot initiate a new revision while there is already a revision in the approval queue.'));
                retVal.put('Message', 'You cannot initiate a new revision while there is already a revision in the approval queue.');
                return retVal;
            }
        }
        catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            retVal.put('Message', e.getMessage());
            return retVal;
        }
        
        //PageReference pageRef = new PageReference('/apex/awardview?id=' + recordId);
        //pageRef.setRedirect(true);
        retVal.put('PageReference','/apex/awardview?id=' + recordId);
        //retVal.put('PageReference','/apex/awardedit?id=' + recordId);
        retVal.put('Message','Updated successfully');
        return retVal;
    }
}