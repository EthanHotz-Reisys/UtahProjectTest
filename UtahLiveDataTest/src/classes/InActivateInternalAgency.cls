global with sharing class InActivateInternalAgency extends GNT.DynamicLayoutActionRedirect{
     
  global override PageReference whenClicked(){
    Savepoint sp = Database.setSavepoint();
    List<Account> lstAccount = new List<Account>();
    System.debug('>>>>>INACTIVATE INTERNAL AGENCY<<<<');
    try{         
        Id recordId = apexpages.currentpage().getparameters().get('id');
        Account acc = [Select Status__c,parentId,IsActiveAgency__c from Account where Id =: recordId];
        lstAccount.add(acc);
        if(acc.parentId != null){
             Account parentacc = [Select Status__c,parentId,IsActiveAgency__c from Account where Id =: acc.parentId];
             lstAccount.add(parentacc); 
             if(parentacc.parentId != null){
                Account grandParent = [Select Status__c,IsActiveAgency__c from Account where Id =: parentacc.parentId];
                lstAccount.add(grandParent);
             }
        } 
       
        for(Account account :lstAccount){
            account.Status__c ='Inactive';
            account.IsActiveAgency__c = false;
        } 
         System.debug('>>>>>INACTIVATE INTERNAL AGENCY<<<<'+lstAccount);
        if(Schema.sObjectType.Account.isUpdateable()){
             update lstAccount;    
        }
     
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Organization Deactivated successfully'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-46661')));
        PageReference  pageref = Page.OrganizationView;
        pageref.getParameters().put('Id',recordId);
        pageref.setRedirect(true);
        return pageref;
         
    } catch(Exception e){
        
            Database.rollback(sp);
        }
        return null;
    } 
 
}