public with sharing class KeyContactViewCtrl{
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    
    public KeyContactViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        if(appName != null && appName == 'StateasGrantor'){ 
            pageTemplateName = 'GrantorKeyContact';
        }
        if(appName != null && appName == 'StateasGrantee'){
          pageTemplateName = 'GranteeKeyContact';
        }
        deleteURL = null;
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('keycontactid',recordId);
        return JSON.serialize(keyValueMap);
    }

}