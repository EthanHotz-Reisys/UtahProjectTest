public with sharing class IndAppInternalViewCtrl {
    public ID recordId {get;set;}
    public String pageTemplateName {get;set;}
    public PageReference deleteURL{get;set;}
    
    public IndAppInternalViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.currentPage().getParameters().get('id');
        pageTemplateName = 'ContactViewForIndApp';
        deleteURL = null; 
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('ContactId', ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);
    }
}