global with sharing class CloseoutNotificationHelper extends GNT.DynamicLayoutActionRedirect{ 
    public  CloseoutNotificationHelper() {}
    List<String> errors = new List<String>(); 
    
    
    global override PageReference whenClicked(){
        String recordId = apexpages.currentpage().getparameters().get('id');
        Closeout__c req = [Select Id, Name, Title__c, Award__c, Grant__c,FOApprover__c, POApprover__c,Grant__r.GranteePOC__c from Closeout__c where Id=:recordId limit 1];            
        
        if(req.FOApprover__c==null ||req.POApprover__c ==null){
        // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Program Approver and Fiscal Approver before sending a Notification')); 
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-28828')));                                 
        return null;    
        }
        notifyUsers(req);
        // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Notification has been sent to Internal Users and External Recipient/Sub-Awardee')); 
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-57777')));                                  
        PageReference pf = Page.CloseoutRequestView;
        pf.getParameters().put('id', recordId);
        pf.setRedirect(true);
        return pf;
    }    
    
      global Boolean notifyUsers(Closeout__c closeout)
      {

       If(!Test.isrunningtest()){
          List<Task> closeoutTasks = GNT.TaskCreationHandler.createTasks(closeout.Grant__r.GranteePOC__c,
                                                                        closeout.Id, 'Accept Closeout Request',
                                                                        closeout.Title__c, null, false, null,
                                                                        'Approval', closeout.Title__c, false); 


       /*  List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();    
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         String[] toAddresses = new String[] {};
         EmailTemplate templateId = [Select id from EmailTemplate where developername = 'NotificationofGrantCloseoutSubmission'];
         Contact cont = [select id, Email from Contact where email <> null limit 1];
         mail.saveAsActivity = false;  
         mail.setTargetObjectId(UserInfo.getuserId());
         mail.setTemplateID(templateId.Id); 
         mails.add(mail);
         Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]> ();
         for(RolesAndResponsibilities__c resp : [Select Id, Name,Name__c from RolesAndResponsibilities__c where Closeout__c =: closeout.Id]){
           toAddresses.add(resp.Name__c);
         }        
         toAddresses.add(UserInfo.getuserId());
         toAddresses.add(closeout.Grant__r.GranteePOC__c);
         recIdToAddressMap.put(closeout.Id, toAddresses);
         try{
         GNT.AppUtils.sendEmailUsingTemplate(templateId.Id, recIdToAddressMap, cont.Id, false);            
         }
         catch(Exception exc){
            system.debug(exc);
         } */
         insert closeoutTasks;
         }
         closeout.Status__c='Notified';
         update closeout;
         return false;
    
  }
}