/*
  <Purpose of this class>    
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-04-01  Shah Kadirmohideen  Code Reviewed
    **********************************************************************************************************************  
*/ 
public with sharing class ServiceAreaViewCtrl {
   
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    
    public ServiceAreaViewCtrl (ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
    //    pageTemplateName = 'Service Area';  // commented by Vinayak for using the same service area template
        //Shah CRF: The following line is obsolete - remove such unused lines to improve performance
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
      //  if(appName != null && appName == 'StateasGrantee'){
            pageTemplateName = 'ServiceArea';
     //   }  
        deleteURL = null;
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('serviceareaid',recordId);
        return JSON.serialize(keyValueMap);
    }
   
}