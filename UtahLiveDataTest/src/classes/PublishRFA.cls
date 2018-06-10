global with sharing class PublishRFA extends GNT.DynamicLayoutActionRedirect{
    
    global override PageReference whenClicked(){
         Savepoint sp = Database.setSavepoint();
         List<String> errors = new List<String>(); 
         Id recordId = apexpages.currentpage().getparameters().get('id');
       
        try{
            Announcement__c ann = [Select Id, Name, FundingOppURL__c,FOAPublicationDate__c,PreApplicationNeeded__c,RFAReleaseDate__c,FOAStatus__c,RFAStatus__c,Status__c from Announcement__c where id =: recordId Limit 1];

            if(System.today() < ann.RFAReleaseDate__c ){
                 errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-47289')+' ' + ann.RFAReleaseDate__c.format());
            }        
            if(errors.size() > 0){
                for(String error: errors){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                }
             }else{
                 ann.Status__c='RFA Published'; 
                 ann.RFAStatus__c='Published'; 
                 update ann ;
                 errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-74299'));
                 // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'RFA Published Successfully'));
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-74299')));
                 PageReference  pageref = Page.AnnouncementView;
                 pageref.getParameters().put('Id',recordId);
                 pageref.setRedirect(true);
                 return pageref;   
             }
           
        }catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
                    
        }
       return null;   
    }
       

}