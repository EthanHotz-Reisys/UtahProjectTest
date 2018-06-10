public with sharing class OMBFormViewCtrl {
  
  public ID recordId{get;set;}
    public String pageTemplateName {get;set;}
    
    public OMBFormViewCtrl (ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        pageTemplateName = ApexPages.CurrentPage().getParameters().get('templateName');
    }
     
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('OMBFormId',recordId);
        keyValueMap.put('pageTemplateName',pageTemplateName);
        return JSON.serialize(keyValueMap);
    }
}