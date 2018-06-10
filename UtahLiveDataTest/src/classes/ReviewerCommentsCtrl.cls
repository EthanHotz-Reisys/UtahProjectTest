public with sharing class ReviewerCommentsCtrl {

    //properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public Review__c review{get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public ReviewerCommentsCtrl(ApexPages.StandardController controller) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        if(recordId != null){
            //GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('Compliant__c','Review Declined',true);
            //listDefaultValues.add(dv);
            Review__c closeout = [Select Id, Name,Compliant__c,ReviewAcceptanceStatus__c from Review__c where Id=:recordId];
             pageTemplateName = 'Reviewer Comments';
        }else{
           pageTemplateName = 'Reviewer Comments';            
        }
        system.debug('Inside ReviewerCommentsCtrl------------');
        savePage = Page.ReviewerComments;
        savePage.getParameters().put('id', recordId);
        savePage.getParameters().put('template', pageTemplateName);
        cancelPage = Page.ReviewerComments;
        cancelPage.getParameters().put('id', recordId);
    }
    
    public string getKeyValueMap(){
        system.debug('Inside getKeyValueMap^^^^^^^^^^^^^^^^^^^');
        Map<String,String> keyValueMap = new Map<String,String>();
        if(recordId != null){
            keyValueMap.put('closeoutId',recordId);
        }
        return JSON.serialize(keyValueMap);
    }
    
    /*public PageReference redirect(){
        system.debug('Inside redirect++++++++++++++++++');
        Review__c closeout = [Select Id, Name,Rating__c,Status__c,Compliant__c,ReviewAcceptanceStatus__c,ReviewDeclineReason__c from Review__c where Id=:recordId];
        Id recordId=ApexPages.currentPage().getParameters().get('id');
        if(closeout.ReviewDeclineReason__c==null || closeout.ReviewDeclineReason__c=='None'|| closeout.ReviewDeclineReason__c==''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-69138')));
            return null;
        }
        closeout.Compliant__c='Review Declined';
        closeout.Rating__c='0';
        closeout.Status__c='Review Completed';
        update closeout;
        PageReference newPage = new PageReference('/apex/PhaseView?t=Application');
        newPage.setRedirect(true);
        return newPage ;
    }*/
}