global with sharing class PaymentSubmissionHelper extends GNT.DynamicLayoutActionRedirect {
	
    global override PageReference whenClicked(){
    	Savepoint sp = Database.setSavepoint();
        List<String> errors = new List<String>();
        try{
	        Id recordId = apexpages.currentpage().getparameters().get('id');
	        PaymentRequest__c paymentreq = [SELECT Id,Name,Title__c,FINETAmount__c,ExternalOrgName__c FROM PaymentRequest__c WHERE Id =: recordId LIMIT 1];
	        GNT.TaskCreationHandler.createApprovalProcessTasks(paymentreq.Id, 'Review Payment Request', paymentreq.Name, null, System.TODAY() + 7, paymentreq.Title__c, true); 
	        
	        PageReference p = Page.PaymentRequestView;
	        p.getParameters().put('id', paymentreq.Id);
	        p.setRedirect(true);
	        return p;
        }catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
}