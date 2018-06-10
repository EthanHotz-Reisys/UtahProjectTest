public with sharing class CloseoutCtrl {
    
    public ID recordId{get;set;}
    public CloseoutCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('recordId',ApexPages.currentPage().getParameters().get('id'));      
        return JSON.serialize(keyValueMap);
    }
}