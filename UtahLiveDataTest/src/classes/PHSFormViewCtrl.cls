public with sharing class PHSFormViewCtrl {
    
    public ID recordId{get;set;}
    public String pageTemplateName {get;set;}
    
    public PHSFormViewCtrl (ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        pageTemplateName = ApexPages.CurrentPage().getParameters().get('templateName');
    }
     
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('PHSFormId',recordId);
        keyValueMap.put('pageTemplateName',pageTemplateName);
        return JSON.serialize(keyValueMap);
    }
}