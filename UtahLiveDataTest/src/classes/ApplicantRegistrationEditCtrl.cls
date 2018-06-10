public with sharing class ApplicantRegistrationEditCtrl {
    public Id recordId {get; set;}
    public String pageTemplateName {get; set;}
    public PageReference savePage {get;set;}
     public PageReference cancelPage {get;set;}
    public PageReference pageRef {get;set;}
    public string recId{get;set;}
    public List <GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}   
    
    public ApplicantRegistrationEditCtrl(ApexPages.StandardController stdController) {  
        recordId = ApexPages.CurrentPage().getParameters().get('id');         
        pageTemplateName = 'ApplicantOrgDetail';
        cancelPage = Page.ApplicantLogin4;
        savePage = Page.ApplicantDetailEdit;
        savePage.getParameters().put('id', recordId);
   } 
}