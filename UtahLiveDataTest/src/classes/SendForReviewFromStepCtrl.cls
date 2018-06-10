public with sharing class SendForReviewFromStepCtrl{
    
    //Properties
    public String reviewStepId{get;set;}
    public ReviewStep__c reviewStep {get;set;}
    public String flexTableHeader {get;set;}
    public SendForReviewFromStepCtrl(){
        reviewStepId = ApexPages.CurrentPage().getParameters().get('id');
        reviewStep = [SELECT Id, Name FROM ReviewStep__c WHERE Id=:reviewStepId];
        flexTableHeader  = 'Select reviews to send';
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();   
        keyValueMap.put('reviewStepId',reviewStepId);    
        return JSON.serialize(keyValueMap);
    }
    public string getListParameters(){
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();      
        return JSON.serialize(listParams);
    }
    
}