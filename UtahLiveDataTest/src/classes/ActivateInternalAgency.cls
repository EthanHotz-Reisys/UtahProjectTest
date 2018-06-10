global with sharing class ActivateInternalAgency extends GNT.DynamicLayoutActionRedirect {

 
 global override PageReference whenClicked(){
    Savepoint sp = Database.setSavepoint();
    List<Account> lstAccount = new List<Account>();              
    List<String> errors = new List<String>();  
       
    try{                
        Id recordId = apexpages.currentpage().getparameters().get('id');
        Account account = [Select Status__c,parentId,IsActiveAgency__c from Account where Id =: recordId];
        lstAccount.add(account);
        System.debug('THE RECORD ID IS '+recordId ); 
        System.debug('THE ACCOUNT ID IS '+account );
        
        if(account.parentId != null){
             Account parentaccount = [Select Id,Status__c,parentId,IsActiveAgency__c from Account where Id =: account.parentId];
             if(parentaccount.Status__c != 'Active'){
                  lstAccount.add(parentaccount);
                  List<Contact> lstContact = [Select Id from Contact where AccountId=:parentaccount.Id];
                  if(lstContact ==null || lstContact.size()==0){  
                    // errors.add('Atleast One contact is required on the Parent Organization to activate the Child Organization.');
                    errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-02430'));
                }  
             }
        }    
        
        List<Contact> lstContact = [Select Id from Contact where AccountId=:recordId];
         System.debug('THE LIST OF CONTACTS IS '+lstContact );
         
        if(lstContact ==null || lstContact.size()==0){
             // errors.add('Atleast One contact is required to activate the Organization.');
             errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-10795'));
            
        }
         if(errors.size() > 0){  
            for(String error: errors){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
            }
         }
        else{
             
            account.Status__c ='Active';
            account.IsActiveAgency__c = true;
            update account; 
         
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Organization activated successfully'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-45874')));
            PageReference  pageref = Page.OrganizationView;
            pageref.getParameters().put('Id',recordId); 
            pageref.setRedirect(true);
            return pageref;
        }  
        
    } catch(Exception e){
        
            Database.rollback(sp);
            //return e.getMessage();
        }
        return null;
    }
 
}