public with sharing class IntegrationDetailCtrl {

        //Properties
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}


    public IntegrationDetailCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        List<IntegrationDetail__c> intDetail = [select id,Process_Response__c from IntegrationDetail__c WHERE id=:recordId];
        
         
        if (intDetail[0].Process_Response__c != null){
            pageTemplateName = 'Verification Response';
        }       
    }

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        
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