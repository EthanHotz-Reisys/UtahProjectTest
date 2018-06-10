global class PaymentRequestApproval extends GNT.ApprovalDecisionActionHandler {
    Map<String,Object> resultMap = new Map<String,Object>();
    PageReference pageRef = null;
    global override String execute(){
            system.debug('Connecting...!');
            if(selectedAction == 'Approve'){
            
            Id recordId= selectedRecordId;
            system.debug('id is' +recordId);
            Savepoint savestate = Database.setSavepoint();
            
            try{
            TaskCreator(recordId);
            return ('Submitting payment request to Grantor.');
            }
            catch(Exception e){
            Database.rollback(savestate);          
            }

            }
            return ('Submission of payment request failed. Internal approval required.');
                 
        }

    @future
    public static void TaskCreator(Id recordId){

    PaymentRequest__c paymentreq = [SELECT Id,Name,Title__c,RequestedAmountthisAction__c,FINETAmount__c,ExternalOrgName__c FROM PaymentRequest__c WHERE Id =: recordId LIMIT 1];        
    if(!test.isrunningtest())   
    GNT.TaskCreationHandler.createApprovalProcessTasks(paymentreq.Id, 'Review Payment Request', paymentreq.Name, null, System.TODAY() + 7, paymentreq.Title__c, true); 
            
    }    
}