public with sharing class GrantProjectAreaViewCtrl {
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    
    public GrantProjectAreaViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        pageTemplateName = 'GrantProjectArea';//TODO get template dynamically from sObjectConfig
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('grantprojectareaid',recordId);
        return JSON.serialize(keyValueMap);
    }

}