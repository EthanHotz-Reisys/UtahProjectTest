public with sharing class LoginHighlightConfigEditCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    
    public LoginHighlightConfigEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   

        savePage = Page.LoginHighlightConfigView;
        savePage.getParameters().put('Id', recordId);
        cancelPage = Page.LoginHighlightConfigView;
        cancelPage.getParameters().put('Id', recordId);                                    
    }

}