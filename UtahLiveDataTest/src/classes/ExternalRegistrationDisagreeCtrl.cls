//public with sharing class ExternalRegistrationNDACtrl{
public class ExternalRegistrationDisagreeCtrl{
    public ID recordId{get;set;}
    public string type{get;set;}
    public PageReference deleteURL;
    public String pageTemplateName{get;set;}
    private PageReference cancelPage;
    private PageReference savePage;
   
  public ExternalRegistrationDisagreeCtrl(ApexPages.StandardController stdController){
  
  system.debug('--id--'+ApexPages.CurrentPage().getParameters().get('ID'));
  system.debug('--type--'+ApexPages.CurrentPage().getParameters().get('type'));
  
    recordId= ApexPages.CurrentPage().getParameters().get('ID');
    type= ApexPages.CurrentPage().getParameters().get('type');
    UserRegistration__c userReg = [Select Id, Name,NDADate__c,NDAStatus__c,NDALookup__c from UserRegistration__c where id = :recordId Limit 1];
 
    //pageTemplateName = 'External Reviewer Edit';
       pageTEmplateName = 'ExtRegDisagree';
  }
}