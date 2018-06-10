global with sharing class CloseoutExtensionSubmissionHelper extends GNT.DynamicLayoutActionRedirect{
    
    global override PageReference whenClicked(){

        Id recordId = apexpages.currentpage().getparameters().get('id');        
        List<String> errors = new List<String>();   
        try{
            Savepoint sp = Database.setSavepoint();
             Closeout__c closeout = [Select Id, Name,ExtensionDays__c from Closeout__c where id =: recordId Limit 1];

            if(closeout.ExtensionDays__c!=null && closeout.ExtensionDays__c>0)
              closeout.ExtensionStatus__c='Requested';
            else
              closeout.ExtensionStatus__c='Not Requested';
             
             closeout.Status__c='Notification Acknowledged'; 
             closeout.RecipientAccepted__c=true; 
             update closeout;       
            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Announcement published successfully.'));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Request has been successfully submitted to Grantor'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-37282')));
            PageReference  pageref = Page.CloseoutRequestView;
            pageref.getParameters().put('Id',recordId);
            pageref.setRedirect(true);
            return pageref;  
        }catch(Exception e){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

          return null;
    }
    
    }