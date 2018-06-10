global with sharing class WaiveFundsHelper extends GNT.DynamicLayoutActionRedirect{
    
    global override PageReference whenClicked(){
        Savepoint sp = Database.setSavepoint();
        List<String> errors = new List<String>();
        try{
                Id recordId = apexpages.currentpage().getparameters().get('id');
                PaymentRequest__c paymentreq = [SELECT Id,Award__c,Status__c FROM PaymentRequest__c WHERE Id =: recordId LIMIT 1];
                Award__c award = [SELECT Id,Status__c FROM Award__c WHERE Id =: paymentreq.Award__c LIMIT 1];
                List<AwardBudgetCategory__c> abclist = [SELECT Id,CurrentApprovedBudgetAmount__c,RemainingBudget__c FROM AwardBudgetCategory__c WHERE Award__c =: award.Id];
                SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
                award.Waived__c = true;
                paymentreq.Status__c = 'Waived';
                for(AwardBudgetCategory__c abc : abclist){
                	abc.CurrentApprovedBudgetAmount__c -= abc.RemainingBudget__c;
                }
                update paymentreq;
                update abclist;
                AwardTriggerHelper.skipTrigger = true;
                SystemContextMethodsHelper.updateAwards(new List<Award__c>{award});
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