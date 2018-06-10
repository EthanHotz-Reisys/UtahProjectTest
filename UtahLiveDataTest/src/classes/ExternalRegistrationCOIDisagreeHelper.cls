global with sharing class ExternalRegistrationCOIDisagreeHelper extends GNT.DynamicLayoutActionRedirect{
    private String securityToken;
    
    global override PageReference whenClicked(){ 
         Savepoint sp = Database.setSavePoint();
          try{
             Id recordId = apexpages.currentpage().getparameters().get('id');
             UserRegistration__c userReg = [Select Id, Name,NDADate__c,NDAStatus__c,NDALookup__c from UserRegistration__c where id =:recordId Limit 1];
              //system.debug('--Inside ApplicationSubmissionHelper--'+app);
              userReg.COIDate__c= System.today();
              userReg.COIStatus__c= 'Rejected';
              update userReg ;
               //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Registration process is terminated please close the broswer window to exit'));
              // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('P01-GRNTR-55811')));
               //PageReference pf = Page.ExternalRegistrationCOI;
               PageReference pf = Page.ApplicantLogin4;
              //pf.getParameters().put('id', userReg.Id);
              pf.setRedirect(true);
              return pf;
              //return null;
            
              
          }catch(Exception ex){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage())); 
            return null;
          }
    }

}