public with sharing class LEAPrivateSchoolEditCtrl{
    public ID recordId {get;set;}
    public ID formId {get;set;}
    public ID appId {get;set;}
    public String pageTemplateName {get;set;}
    public String savePage{get;set;}
    public String cancelPage{get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public LEAPrivateSchoolEditCtrl(ApexPages.StandardController stdController){
        formId = ApexPages.CurrentPage().getParameters().get('formId');
        appId = ApexPages.CurrentPage().getParameters().get('appId');
        pageTemplateName = 'LEAPrivateSchool';

        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        if (formId != null) {
            GNT.DynamicLayoutDefaultValueHelper formdv = new GNT.DynamicLayoutDefaultValueHelper('USBEForm__c',formId, true);
            listDefaultValues.add(formdv);
        }

        if (appId != null) {
            GNT.DynamicLayoutDefaultValueHelper appdv = new GNT.DynamicLayoutDefaultValueHelper('Application__c',appId, true);
            listDefaultValues.add(appdv);
        }
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('formId',formId);
        keyValueMap.put('appId',appId);
        return JSON.serialize(keyValueMap);
    }
    
    

}