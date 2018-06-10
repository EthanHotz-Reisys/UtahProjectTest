global with sharing class AccountDeactivateCtrl extends GNT.DynamicLayoutActionRedirect{
     global override PageReference whenClicked(){
        Savepoint sp = Database.setSavepoint();
        Id recordId = layoutHolder.getPrimarySObject().Id;
        Account acc=(Account)layoutHolder.recordMap.get('Account');//testashwin
        
        try{
            acc.Status__c='Inactive';
            if(Schema.sObjectType.Account.isUpdateable()){
                update acc;
            }
              

        }catch(Exception e){
            Database.rollback(sp);
            return null; 
         }
         PageReference  p = Page.OrganizationView;
         p.getParameters().put('id',recordId);
         p.setRedirect(true);
         return p;  
     } 
}