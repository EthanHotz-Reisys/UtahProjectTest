public with sharing class TertiaryApplicantRegistrationEditCtrl {
     public Id recordId {get; set;}
     public String pageTemplateName {get; set;}
     public PageReference savePage {get;set;}
     public PageReference cancelPage {get;set;}
  
   
public TertiaryApplicantRegistrationEditCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplateName = 'Tertiary Profile Detail';
        savePage = Page.TertiaryApplicantRegistrationView;
       
    }
}