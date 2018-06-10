global with sharing class ExternalRegistrationNDADisagreeHelper extends GNT.DynamicLayoutActionRedirect{
    private String securityToken;
    
    global override PageReference whenClicked(){ 
         Savepoint sp = Database.setSavePoint();
          try{
             securityToken= ApexPages.CurrentPage().getParameters().get('SecurityToken');
             List<Contact> contactList = [SELECT ID FROM Contact WHERE SecurityToken__c =: SecurityToken limit 1];
             Id recordId = apexpages.currentpage().getparameters().get('id');
              
              if(securityToken != NULL && securityToken != ''){
                  UserRegistration__c userReg = [Select Id, Name,NDADate__c,NDAStatus__c,NDALookup__c from UserRegistration__c where Contact__c = :contactList[0].Id Limit 1];
                  userReg.NDADate__c= System.today();
                  userReg.NDAStatus__c= 'Rejected';
                  UserRegistrationTriggerHelper.skipTrigger = true;
                  update userReg ;
                  //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Registration process is terminated please close the broswer window to exit'));
                  //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('P01-GRNTR-55811')));
                   PageReference pf = Page.ApplicantLogin4;
                  //pf.getParameters().put('id', userReg.Id);
                  pf.setRedirect(true);
                  return pf;
              }else{
                  UserRegistration__c userReg = [Select Id, Name,NDADate__c,NDAStatus__c,NDALookup__c from UserRegistration__c where id =:recordId Limit 1];
                  userReg.NDADate__c= System.today();
                  userReg.NDAStatus__c= 'Rejected';
                  UserRegistrationTriggerHelper.skipTrigger = true;
                  update userReg ;
                  //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Registration process is terminated please close the broswer window to exit'));
                  //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('P01-GRNTR-55811')));
                    
                   PageReference pf = Page.ApplicantLogin4;
                  //pf.getParameters().put('id', userReg.Id);
                  pf.setRedirect(true);
                  return pf;
                  //return null;
                  
              }
            
              
          }catch(Exception ex){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage())); 
            return null;
          }
    }

}