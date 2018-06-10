//public with sharing class ExternalRegistrationNDACtrl{
public class ExternalRegistrationCOICtrl{
    public ID recordId{get;set;}
    public string type{get;set;}
    public PageReference deleteURL;
    public String pageTemplateName{get;set;}
    private PageReference cancelPage;
    private PageReference savePage;
   
  public ExternalRegistrationCOICtrl(ApexPages.StandardController stdController){
  
  system.debug('--id--'+ApexPages.CurrentPage().getParameters().get('ID'));
  system.debug('--type--'+ApexPages.CurrentPage().getParameters().get('type'));
  
    recordId= ApexPages.CurrentPage().getParameters().get('ID');
    type= ApexPages.CurrentPage().getParameters().get('type');
    UserRegistration__c userReg = [Select Id, Name,NDADate__c,NDAStatus__c,NDALookup__c from UserRegistration__c where id = :recordId Limit 1];
  /*  if(type == 'agree'){
     
              //system.debug('--Inside ApplicationSubmissionHelper--'+app);
              userReg.NDADate__c= System.today();
              userReg.NDAStatus__c= 'Accepted';
              update userReg ;
             
    
    } else {
    
              userReg.NDADate__c= System.today();
              userReg.NDAStatus__c= 'Rejected';
              update userReg ;
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Registration process is terminated please close the window'));
    } */
    //pageTemplateName = 'External Reviewer Edit';
       pageTEmplateName = 'ExternalRegistrationCOI';
  }

  
  
  

  

  


}