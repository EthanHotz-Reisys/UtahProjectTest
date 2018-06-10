public with sharing class UserExternalViewCtrl {
    public Id recordId {get; set;}
    public String pageTemplateName {get;set;}
    public UserExternalViewCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        
       
        	pageTemplateName = 'External User';
        
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('userregid',ApexPages.currentPage().getParameters().get('id'));
    
        return JSON.serialize(keyValueMap);
    }
       
}