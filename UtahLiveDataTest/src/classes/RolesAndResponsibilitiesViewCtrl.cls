public with sharing class RolesAndResponsibilitiesViewCtrl {
    //Properties
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    
    public RolesAndResponsibilitiesViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        List<RolesAndResponsibilities__c> rolesandresp = [select id,name,Application__c,Announcement__c,ServiceArea__c,StrategicPlan__c,PreApplication__c,Award__c,
                                                           Program__c, Program__r.OrganizationName__c, AmendmentRequest__c,ProgressReport__c,SiteVisit__c, Closeout__c,RiskAssessment__c from RolesAndResponsibilities__c WHERE id=:recordId];
        
        System.debug('rolesandresp--->>>'+rolesandresp); 
        if (rolesandresp[0].StrategicPlan__c != null){
            pageTemplateName = 'Roles and Responsibilities';
        }  
        
        if (rolesandresp[0].ServiceArea__c != null){
            pageTemplateName = 'Roles and Responsibilities 1';

        } 
        if (rolesandresp[0].Announcement__c != null){
            pageTemplateName = 'Roles and Responsibilities 2';

        } 
        if (rolesandresp[0].Application__c != null){ 
            pageTemplateName = 'Roles and Responsibilities 3';
        } 
        if (rolesandresp[0].PreApplication__c != null){ 
            pageTemplateName = 'Roles and Responsibilities 4';
        } 
        if (rolesandresp[0].Award__c != null){ 
            pageTemplateName = 'Roles and Responsibilities 5';
        }
        if (rolesandresp[0].AmendmentRequest__c != null){ 
            pageTemplateName = 'Roles and Responsibilities 6';
        }  
        if (rolesandresp[0].Program__c != null){ 
            pageTemplateName = 'Roles and Responsibilities 7';
        }
         if (rolesandresp[0].ProgressReport__c != null){ 
            pageTemplateName = 'Roles and Responsibilities 8';
        }
         if (rolesandresp[0].SiteVisit__c != null){ 
            pageTemplateName = 'Roles and Responsibilities 9';
        }
         if (rolesandresp[0].Closeout__c != null){ 
            pageTemplateName = 'Roles and Responsibilities 10';
        }
        if (rolesandresp[0].RiskAssessment__c != null){ 
            pageTemplateName = 'Roles and Responsibilities 11';
        }
        if (rolesandresp[0].Program__c != null && rolesandresp[0].Program__r.OrganizationName__c.equals('USBE')) {
            if (ApexPages.CurrentPage().getParameters().get('announcementId') != null) { pageTemplateName = 'Roles and Responsibilities Announcement USBE'; }
            else if (ApexPages.CurrentPage().getParameters().get('awardId') != null) { pageTemplateName = 'Roles and Responsibilities Award USBE'; }
            else { pageTemplateName = 'Roles and Responsibilities USBE'; } 
        }
        System.debug('pageTemplateName--->>'+pageTemplateName);
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