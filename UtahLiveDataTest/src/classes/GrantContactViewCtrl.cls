public with sharing class GrantContactViewCtrl {
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    
    public GrantContactViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        if(appName != null && appName == 'StateasGrantor' || appName == 'Recipient'){ 
            pageTemplateName = 'GrantContact';
        }
        if(appName != null && appName == 'StateasGrantee'){
        	pageTemplateName = 'GranteeGrantContact';
        }
        deleteURL = null;
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('grantcontactid',recordId);
        return JSON.serialize(keyValueMap);
    }

}