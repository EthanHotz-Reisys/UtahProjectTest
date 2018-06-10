public with sharing class SendForReviewFromPanelCtrl{
    
    //Properties
    public String panelId{get;set;}
    public ReviewPanel__c reviewPanel {get;set;}
    public String flexTableHeader {get;set;}
    public SendForReviewFromPanelCtrl(){
        panelId = ApexPages.CurrentPage().getParameters().get('id');
        reviewPanel = [SELECT Id, Name,ReviewStep__c,UserType__c FROM ReviewPanel__c WHERE Id=:panelId];
        flexTableHeader  = 'Select Reviews to Send';
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();   
        keyValueMap.put('reviewPanelId',panelId);    
        return JSON.serialize(keyValueMap);
    }
    public string getListParameters(){
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();      
        return JSON.serialize(listParams);
    }
    
}