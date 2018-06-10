public with sharing class DocumentTemplateEditCtrl {
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}    
      
    public DocumentTemplateEditCtrl (ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        savePage = Page.DocumentTemplateView;
        savePage.getParameters().put('id', recordId);
        
    }
   
}