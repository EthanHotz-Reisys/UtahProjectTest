public class CommunityApprovalCtrl {
    public String flexTableParameters {get;set;}
    public String recordId{get;set;}
 
    public CommunityApprovalCtrl() {

        GNT__UserPreferences__c userPrefs = GNT__UserPreferences__c.getValues(UserInfo.getUserId());
        recordId = userPrefs.GNT__ContactId__c;

        if(userPrefs != null){
            Map<String, String> keyValueMap = new Map<String, String>();
            keyValueMap.put(AppUtils.getNamespacePrefix() + 'UserRegistration__c.' + AppUtils.getNamespacePrefix() + 'Approver__c', UserInfo.getUserId()); 
            flexTableParameters = JSON.serialize(keyValueMap);        
        }
    }

}