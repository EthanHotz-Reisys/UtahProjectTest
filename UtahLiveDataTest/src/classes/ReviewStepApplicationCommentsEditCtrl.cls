public with sharing class ReviewStepApplicationCommentsEditCtrl {
     //Properties
    public Id recordId {get;set;}
    public String templateName {get;set;}
        
    public ReviewStepApplicationCommentsEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        Id revStepId = ApexPages.CurrentPage().getParameters().get('reviewStepId'); 
        templateName = ApexPages.CurrentPage().getParameters().get('templateName'); 
        if(String.isEmpty(templateName)){
            templateName = 'ReviewStepAppRejectCommentsEdit';
        }
        String commentsEntered = ApexPages.CurrentPage().getParameters().get('commentsEntered'); 
        if(!String.isEmpty(commentsEntered) && commentsEntered == 'false') {
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter comments in order to perform this operation.');
                //ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-91263'));
                ApexPages.addMessage(errorMsg);
        }
    }
}