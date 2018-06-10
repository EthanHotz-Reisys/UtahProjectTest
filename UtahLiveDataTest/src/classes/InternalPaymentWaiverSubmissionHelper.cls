global with sharing class InternalPaymentWaiverSubmissionHelper extends GNT.DynamicLayoutActionRedirect{
    
    global override PageReference whenClicked(){
        Savepoint sp = Database.setSavepoint();
        List<String> errors = new List<String>();
        try{
                Id recordId = apexpages.currentpage().getparameters().get('id');
                PaymentRequest__c paymentreq = [SELECT Id,Award__c,Status__c,Name,Title__c,Applicant__c,Approver__c FROM PaymentRequest__c WHERE Id =: recordId LIMIT 1];
                
                if(paymentreq.Approver__c == null){
                    errors.add('Assign an Internal Approver');
                }
                
                if(errors.size() > 0){
                  for(String error: errors){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                  } 
                } else{
	                GNT.TaskCreationHandler.createApprovalProcessTasks(paymentreq.Id, 'Recipient Review Payment Waiver', paymentreq.Name, null, System.TODAY() + 7, paymentreq.Title__c, true); 
	                
	                List<Task> taskList = [SELECT WhatId,Status,OwnerId FROM Task where WhatId=:paymentreq.Id and Status IN ('In Progress', 'Not Started')];
	                if (!taskList.isEmpty()) {
	                    for (Task t : taskList) {
	                        if (t.OwnerId == paymentreq.Applicant__c) {
	                            t.Status = 'Completed';
	                        }
	                    }
	                    update taskList;
	                }
	                PageReference p = Page.PaymentRequestView;
	                p.getParameters().put('id', paymentreq.Id);
	                p.setRedirect(true);
	                return p;
                }
                return null;
        }catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
}