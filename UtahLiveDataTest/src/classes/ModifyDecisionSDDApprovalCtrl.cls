public with sharing class ModifyDecisionSDDApprovalCtrl {
    
    public Id recordId{get;set;}
    public PageReference savePage {get;set;}
    public Id applicationId {get;set;}
    public Id reviewStepId {get;set;}
    public ModifyDecisionSDDApprovalCtrl(){
        recordId = ApexPages.currentpage().getParameters().get('id');
        List<ReviewStepApplication__c> revStepAppList = [Select ReviewStep__c,Application__c from ReviewStepApplication__c Where id = :recordId LIMIT 1];
        if(revStepAppList.size() > 0){
            applicationId = revStepAppList[0].Application__c;
            reviewStepId = revStepAppList[0].ReviewStep__c;
            savePage = Page.ReviewStepView;
            savePage.getParameters().put('id', reviewStepId);
        }
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('applicationId',applicationId);
        keyValueMap.put('reviewStepId',reviewStepId);
        keyValueMap.put('recordId',recordId);
        return JSON.serialize(keyValueMap);
    }
}