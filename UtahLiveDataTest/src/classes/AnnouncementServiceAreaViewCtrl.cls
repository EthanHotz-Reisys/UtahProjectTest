public with sharing class AnnouncementServiceAreaViewCtrl {
   
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    
    public AnnouncementServiceAreaViewCtrl (ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
    //    pageTemplateName = 'Service Area';  // commented by Vinayak for using the same service area template
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
      //  if(appName != null && appName == 'StateasGrantee'){
            pageTemplateName = 'AnnouncementServiceArea';
     //   }  
        deleteURL = null;
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        //keyValueMap.put('serviceareaid',recordId);
        return JSON.serialize(keyValueMap);
    }
   
}