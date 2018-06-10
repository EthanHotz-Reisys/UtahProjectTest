global with sharing class FundingSourceSubmissionHelper extends GNT.DynamicLayoutActionRedirect {
    global override PageReference whenClicked(){
        Savepoint sp = Database.setSavepoint();
        List<String> errors = new List<String>();   
        try{
            Id recordId = apexpages.currentpage().getparameters().get('id');
            FundingSource__c funsource = [select id,Name,Title__c from FundingSource__c where Id =:recordId];
            List<FundingAccount__c> funaccnt = [SELECT id,FundingSource__c FROM FundingAccount__c WHERE FundingSource__c =: recordId];
            List<FundingSourceBudgetCategory__c> funsourcbc = [SELECT id,FundingSource__c FROM FundingSourceBudgetCategory__c WHERE FundingSource__c =: recordId];
            if(funaccnt.size() < 1){
                    // errors.add ('Please add atleast one Funding Account to Submit for Approval');
                    errors.add (GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-80329'));
                    
                }
            if(funsourcbc.size() < 1){
                    // errors.add ('Add atleast one Funding Source Budget Category to Submit for Approval');
                    errors.add (GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-95122'));
                    
                }
            if(errors.size() > 0){
                for(String error: errors){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                } 
            }
            else{
            GNT.TaskCreationHandler.createApprovalProcessTasks(funsource.Id, 'Review Funding Source', funsource.Title__c, null, System.TODAY() + 7,funsource.Title__c,true);         
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Funding Source has been submitted successfully.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-48767')));
            PageReference  pageref = Page.FundingSourceView;   
            pageref.getParameters().put('Id',recordId);
            pageref.setRedirect(true);  
            return pageref;
          }
          return null;
       }
         catch(Exception e){
         Database.rollback(sp);
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
         return null;   
        }
    }

}