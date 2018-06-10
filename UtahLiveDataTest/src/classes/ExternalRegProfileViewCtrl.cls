//public with sharing class ExternalRegistrationNDACtrl{
public class ExternalRegProfileViewCtrl{
    public ID recordId{get;set;}
    public PageReference deleteURL;
    public String pageTemplateName{get;set;}
   
   
  public ExternalRegProfileViewCtrl(ApexPages.StandardController stdController){
    recordId= ApexPages.CurrentPage().getParameters().get('ID');
    //pageTemplateName = 'External Reviewer Edit';
    pageTEmplateName = 'Applicant Confirmation';
  }

  
  
  

  

  


}