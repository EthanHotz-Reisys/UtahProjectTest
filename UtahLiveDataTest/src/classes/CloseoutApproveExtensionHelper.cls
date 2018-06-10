global with sharing class CloseoutApproveExtensionHelper extends GNT.DynamicLayoutActionRedirect{ 
    public CloseoutApproveExtensionHelper() {}
    List<String> errors = new List<String>(); 
    
    //global override PageReference whenClicked(){
    global override PageReference whenClicked(){
       
        Closeout__c tempCloseout;
        try{
            String recordId = apexpages.currentpage().getparameters().get('id');
            System.debug(LoggingLevel.ERROR,'inside CloseoutApproveExtensionHelper--');
            Closeout__c req = [Select Id, Name, Title__c, Award__c, Grant__c,FOApprover__c,ExtensionDays__c,DueDate__c, POApprover__c from Closeout__c where Id=:recordId limit 1];              
            system.debug(LoggingLevel.Info,'**Closeout Req --'+req);
            if(req.POApprover__c == null){
                   // errors.add(' Assign the Program Approver in the Roles and Responsibilities Section');
                   errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-90696'));
                }
              if(req.FOApprover__c == null){
                   // errors.add(' Assign the Fiscal Approver in the Roles and Responsibilities Section');
                   errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-55723'));
                }
               
            if(errors.size() > 0){
                for(String error: errors){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                }
             return null;
             }else{
                 
                GNT.TaskCreationHandler.createApprovalProcessTasks(req.Id, 'Approve Closeout Request', req.Name, null, System.TODAY() + 7, req.Title__c, true);
                req.ExtensionStatus__c='Approved';
                req.DueDate__c= req.DueDate__c.addDays(req.ExtensionDays__c.intValue());
                update req; 
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Closeout has been successfully submitted for Approval'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-83597')));
                PageReference pf = Page.CloseoutRequestView;
                pf.getParameters().put('id', req.Id);
                pf.setRedirect(true);
                return pf;
            }
        } catch(Exception e){
            system.debug(LoggingLevel.ERROR,'error seen '+e);  
           system.debug(LoggingLevel.ERROR,'error seen '+e.getStackTraceString());  
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error in submitting closeout for approval'));
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-20509')));  

            return null;
        }
    }
}