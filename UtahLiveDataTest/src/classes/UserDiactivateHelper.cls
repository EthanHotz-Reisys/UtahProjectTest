global with sharing class UserDiactivateHelper extends GNT.DynamicLayoutActionRedirect{
   
    
    global override PageReference whenClicked(){ 
         Savepoint sp = Database.setSavePoint();
          try{
             Id recordId = apexpages.currentpage().getparameters().get('id');
             User user = [Select Id, Name,IsActive,Contact.Id from User 
             where id =:recordId Limit 1];
             Contact con  = [Select Id, Name,ReviewerStatus__c,IsUser__c from Contact 
             where id =:user.Contact.Id  Limit 1];
             user.IsActive = false;
             UserTriggerHelper.skipTrigger = true;
             update user ;
             con.ReviewerStatus__c ='Inactive';
             con.IsUser__c = false;
             ContactTriggerHelper.skipTrigger = true; 
             update con;
             PageReference pf = Page.RegisteredUser;
	         pf.setRedirect(true);
	         return pf;
              
            
              
          }catch(Exception ex){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage())); 
            return null;
          }
    }

}