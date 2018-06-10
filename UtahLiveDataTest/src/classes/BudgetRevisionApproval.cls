global class BudgetRevisionApproval extends GNT.ApprovalDecisionActionHandler {
    Map<String,Object> resultMap = new Map<String,Object>();
    PageReference pageRef = null;
    global override String execute(){
        system.debug('Connecting...!');
        if(selectedAction == 'Approve'){           
            Id recordId= selectedRecordId;
            system.debug('id is' +recordId);
            Savepoint savestate = Database.setSavepoint();
            try{
                Map<String, String> messageMap = new Map<String, String>{
                    'Allocation Change' => 'allocation change ',
                    'Indirect Change' => 'indirect change '
                };
                AmendmentRequest__c budgetRevision = [SELECT Id, Name, AwardName__c, Award__r.BudgetRevisionInitiatedByUSBE__c FROM AmendmentRequest__c WHERE Id =: recordId limit 1];
                TaskCreator(recordId);
                String outputMessage = messageMap.keySet().contains(budgetRevision .Award__r.BudgetRevisionInitiatedByUSBE__c) ? messageMap.get(budgetRevision .Award__r.BudgetRevisionInitiatedByUSBE__c) : '';
                return ('Submitting ' + outputMessage + 'budget revision to Grantor.');
            }
            catch(Exception e){
                Database.rollback(savestate);
                System.debug('inside catch');
                return ('Submission of budget revision failed. Internal approval required.');                    
            }
        }
        return null;        
    }
    
    @future
    public static void TaskCreator(Id recordId){
        AmendmentRequest__c budgetRevision = [SELECT Id, Name, AwardName__c FROM AmendmentRequest__c WHERE Id =: recordId limit 1];
        if (!Test.isRunningTest()) {
            GNT.TaskCreationHandler.createApprovalProcessTasks(budgetRevision.Id, 'Budget Revision Approval Request', budgetRevision.Name, null, System.TODAY() + 7, budgetRevision.AwardName__c, true);
        }
    }   
}