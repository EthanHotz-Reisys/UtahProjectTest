global with sharing class ExternalRegistrationCOIAgreeHelper extends GNT.DynamicLayoutActionRedirect{
    private String securityToken;
    
    global override PageReference whenClicked(){ 
         Savepoint sp = Database.setSavePoint();
          try{
             Id recordId = apexpages.currentpage().getparameters().get('id');
             UserRegistration__c userReg = [Select Id, Name,NDADate__c,NDAStatus__c,NDALookup__c,RecordType.DeveloperName from UserRegistration__c 
             where id =:recordId Limit 1];
              //system.debug('--Inside ApplicationSubmissionHelper--'+app);
              userReg.COIDate__c= System.today();
              userReg.COIStatus__c= 'Accepted';
              UserRegistrationTriggerHelper.skipTrigger = true;
              update userReg ;
              if(userReg.RecordType.DeveloperName == 'Reviewer'){
	               PageReference pf = Page.ExternalRegProfileEdit;
	               pf.getParameters().put('id', userReg.Id);
	               pf.setRedirect(true);
	               return pf;
              } else if(userReg.RecordType.DeveloperName == 'IndApplicant'){
	              PageReference pf = Page.ExtRegIndApplicantSearch;
	              pf.getParameters().put('id', userReg.Id);
	              pf.setRedirect(true);
	              return pf;
              }else if(userReg.RecordType.DeveloperName == 'Applicant'){
	              PageReference pf = Page.ApplicantRegistrationPage2;
	              pf.getParameters().put('id', userReg.Id);
	              pf.setRedirect(true);
	              return pf;
              }else if(userReg.RecordType.DeveloperName == 'AdditionalApplicant') {
              	  PageReference pf = Page.ExternalRegProfileEdit;
	              pf.getParameters().put('id', userReg.Id);
	              pf.setRedirect(true);
	              return pf;
              }
              else if(userReg.RecordType.DeveloperName == 'AdditionalApplicantSecondary') {
                  PageReference pf = Page.ExternalRegProfileEdit;
                pf.getParameters().put('id', userReg.Id);
                pf.setRedirect(true);
                return pf;
              }
               else{
              	return null;}
             
            
              
          }catch(Exception ex){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage())); 
            return null;
          }
    }

}