public with sharing class SF425FormViewCtrl {
    
    public ID recordId{get;set;}
    public String pageTemplateName {get;set;}
    //Form__c frmobj {get;set;}
    
    public SF425FormViewCtrl (ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        pageTemplateName = ApexPages.CurrentPage().getParameters().get('templateName');
        //frmobj.TemplateName__c=pageTemplateName;
    }
     
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('SF425FormId',recordId);
        keyValueMap.put('SF425FormTemplate',pageTemplateName);
        return JSON.serialize(keyValueMap);
    }
}