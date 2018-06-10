global with sharing class ReviewerConfirmationHelper extends GNT.DynamicLayoutActionRedirect{
    
    global override PageReference whenClicked(){

        Id recordId = apexpages.currentpage().getparameters().get('id');
        
        List<String> errors = new List<String>();   

        try{
            Savepoint sp = Database.setSavepoint();
             Review__c review = [Select Id, Name,    ReviewDeclineReason__c from Review__c where id =: recordId Limit 1];
    system.debug('--review--'+  review);

            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Announcement published successfully.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('P51-GRNTR-93993')));
            PageReference  pageref = Page.ReviewerConfirmation;
            pageref.getParameters().put('Id',recordId);
            pageref.setRedirect(true);
            return null;   
        
        
           
        }catch(Exception e){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

          return null;
    }
    
    
  
}