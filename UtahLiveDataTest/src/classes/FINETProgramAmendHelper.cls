global with sharing class FINETProgramAmendHelper extends GNT.DynamicLayoutActionRedirect{
    global override PageReference whenClicked(){
        Savepoint sp = Database.setSavePoint();
        try{
            String recordId = ApexPages.CurrentPage().getParameters().get('id');
            r_prog__c finetProgram = [SELECT Id, Status__c,Grants_API_Document_Phase__c  FROM r_prog__c WHERE Id = :recordId];
            finetProgram.Status__c = 'Being Amended';
            finetProgram.Grants_API_Document_Phase__c = '';
            update finetProgram;
            PageReference pf = Page.FINETProgramView;
            pf.setRedirect(true);
            pf.getParameters().put('id', recordId);
            return pf;
        }catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));
            return null;
        }
    }
}