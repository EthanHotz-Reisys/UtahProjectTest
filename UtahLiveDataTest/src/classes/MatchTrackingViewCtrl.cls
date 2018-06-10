public with sharing class MatchTrackingViewCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    
    public MatchTrackingViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        pageTemplateName = 'Match Tracking';//TODO get template dynamically from sObjectConfig
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('StrategicPlanid',ApexPages.currentPage().getParameters().get('id'));
        Boolean isExternalUser;
        String userType;
        List<User> userList = [SELECT id, IsExternalUser__c FROM User WHERE id=:UserInfo.getUserId()];
        If(userList != null && userList.size() > 0){
            isExternalUser = userList[0].IsExternalUser__c; 
        }
        if(isExternalUser){
            userType = 'External';
        }else
            userType = 'Internal';
        keyValueMap.put('userType',userType);
        return JSON.serialize(keyValueMap);
    }
}