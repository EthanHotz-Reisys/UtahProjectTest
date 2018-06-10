//public with sharing class ExternalRegistrationNDACtrl{
public class ExternalRegProfileEditCtrl{
    public ID recordId{get;set;}
    public String pageTemplateName {get;set;}
    public PageReference cancelPage {get;set;}
    public PageReference savePage  {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
   
  public ExternalRegProfileEditCtrl(ApexPages.StandardController stdController){
    recordId= ApexPages.CurrentPage().getParameters().get('ID');
    UserRegistration__c uReg = [select id , name , recordtype.developername from UserRegistration__c where id =: recordId ];
    if(uReg.recordtype.developername == 'AdditionalApplicant' || uReg.recordtype.developername == 'AdditionalApplicantSecondary'){
        //pageTEmplateName = 'IndApplicantProfile';
        pageTEmplateName = 'Add Applicant Profile';
        cancelPage = Page.ApplicantLogin4;
        savePage = Page.capchaPage;
        savePage.getParameters().put('id', recordId);
        
    }
    else {
          //pageTemplateName = 'External Reviewer Edit';
        pageTEmplateName = 'Reviewer Profile Detail';
        //cancelPage = Page.ApplicantRegistrationPage2;
        cancelPage = Page.ApplicantLogin4;
        savePage = Page.capchaPage;
        savePage.getParameters().put('id', recordId);
    }
  
  }
}