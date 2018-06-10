public with sharing class InternalUserRegistrationEditCtrl {
    public Id recordId {get; set;}
    public String pageTemplateName {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String packageId {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public InternalUserRegistrationEditCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplateName = 'GrantorUserRegistrationEditForm';
         savePage = Page.InternalUserRegistrationView;
         savePage.getParameters().put('id', recordId); 
            
        if (!String.isEmpty(recordId)) {
               cancelPage = Page.InternalUserRegistrationView;
               cancelPage.getParameters().put('id', recordId);   
        }
    }
}