public with sharing class UserRegistrationViewCtrl {
    public Id recordId {get; set;}
    public String pageTemplateName {get;set;}
    public UserRegistrationViewCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplateName = 'External Reviewer Template';
    }
}