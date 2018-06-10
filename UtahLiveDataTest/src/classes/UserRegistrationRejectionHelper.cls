global with sharing class UserRegistrationRejectionHelper extends GNT.DynamicLayoutActionRedirect{
    
    
    global override PageReference whenClicked(){ 
         Savepoint sp = Database.setSavepoint();
        // Id recordId = layoutHolder.getPrimarySObject().Id;
         Id recordId = apexpages.currentpage().getparameters().get('id');
         UserRegistration__c uReg = [Select id, Comments__c
                                     from UserRegistration__c where id = :recordId];
        try{
            if(uReg.Comments__c == null){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please click the edit button and enter the Approval comments'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-95308')));
                return null;
            }
            uReg.Status__c='Rejected';
            update uReg;
                        
        }catch(Exception e){
            Database.rollback(sp);
            //System.Debug('UserRegistrationHelper whenClicked...'+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage())); 
        }   
        PageReference pageRef= new PageReference('/apex/InternalUserRegistrationView?id='+recordId);
        pageRef.setRedirect(true);
        return pageRef;                      
    }   
}