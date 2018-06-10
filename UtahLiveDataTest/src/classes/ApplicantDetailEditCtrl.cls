public with sharing class ApplicantDetailEditCtrl {
    public Id recordId {get; set;}
    public String pageTemplateName {get; set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public PageReference pageRef {get;set;} 
    
    public ApplicantDetailEditCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplateName = 'Applicant Profile Detail';
        cancelPage = Page.ApplicantLogin4;
        savePage = Page.capchaPage;
        savePage.getParameters().put('id', recordId);
       }
}