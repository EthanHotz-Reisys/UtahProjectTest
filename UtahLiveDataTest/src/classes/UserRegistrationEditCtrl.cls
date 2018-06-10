public with sharing class UserRegistrationEditCtrl {
    public Id recordId {get; set;}
    public String pageTemplateName {get; set;}
    public PageReference savePage {get;set;}
    public UserRegistrationEditCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplateName = 'External Reviewer Template';
        //pageTemplateName = 'External Applicant Template';
        savePage = Page.UserRegistrationView;
        savePage.getParameters().put('id', recordId);
    }
}