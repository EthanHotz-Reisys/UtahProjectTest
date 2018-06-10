public with Sharing class ReviewStepApplicationAmountCtrl{
    public ID recordId {get; set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    
    public ReviewStepApplicationAmountCtrl(){
         recordId = ApexPages.currentPage().getParameters().get('id');
         System.debug('recordId-->>'+recordId);
       savePage = Page.ReviewStepApplicationAmountView;
       savePage.getParameters().put('id', recordId);
        
        if (!String.isEmpty(recordId)) {
            cancelPage = Page.ReviewStepApplicationAmountView;
            cancelPage.getParameters().put('id', recordId);   
        }
         
    }
}