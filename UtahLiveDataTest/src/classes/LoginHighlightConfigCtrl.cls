public with sharing class LoginHighlightConfigCtrl {
    
    //Properties
    public ID recordId{get;set;}    
    
    public LoginHighlightConfigCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
    }

}