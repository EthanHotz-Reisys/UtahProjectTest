public with sharing class RSAModifyCommentsEditCtrl {

    public PageReference saveURL{get;set;}
    
    public RSAModifyCommentsEditCtrl(ApexPages.StandardController controller) {
        Id recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        saveURL = new PageReference('/apex/RSACommentsView?id='+recordId);
    }

}