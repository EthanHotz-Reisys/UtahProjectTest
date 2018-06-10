public with sharing class PanelUserViewCtrl {
    public ID recordId {get;set;}
    public String pageTemplateName {get;set;}
    public PageReference deleteURL{get;set;}
    
    public PanelUserViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.currentPage().getParameters().get('id');
        pageTemplateName = 'ReviewerTemplate';
        deleteURL = null; 
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('ContactId', ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);
    }
}