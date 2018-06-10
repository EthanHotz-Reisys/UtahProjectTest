global with sharing class PayPaymentRequestHelper extends GNT.DynamicLayoutActionRedirect{
    
    global override PageReference whenClicked(){
        Savepoint sp = Database.setSavepoint();
        List<String> errors = new List<String>();
        try{
                Id recordId = apexpages.currentpage().getparameters().get('id');
                PaymentRequest__c paymentreq = [SELECT Id,Status__c FROM PaymentRequest__c WHERE Id =: recordId LIMIT 1];
                if (paymentreq.Status__c == 'Approved') {
                	paymentreq.Status__c = 'Paid';
                	update paymentreq;
                }
                PageReference p = Page.PaymentRequestView;
                p.getParameters().put('Id', paymentreq.Id);
                p.setRedirect(true);
                return p;
        }catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
}