global with sharing class CancelPaymentWaiverHelper extends GNT.DynamicLayoutActionRedirect{
    
    global override PageReference whenClicked(){
        Savepoint sp = Database.setSavepoint();
        List<String> errors = new List<String>();
        try{
                Id recordId = apexpages.currentpage().getparameters().get('id');
                PaymentRequest__c paymentreq = [SELECT Id,Award__c,Status__c FROM PaymentRequest__c WHERE Id =: recordId LIMIT 1];
                Award__c award = [SELECT Id,Status__c FROM Award__c WHERE Id =: paymentreq.Award__c LIMIT 1];
                delete paymentreq;
                PageReference p = Page.AwardView;
                p.getParameters().put('id', award.Id);
                p.setRedirect(true);
                return p;
        }catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
}