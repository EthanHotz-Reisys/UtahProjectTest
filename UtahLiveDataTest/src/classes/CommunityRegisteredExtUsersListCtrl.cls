public class CommunityRegisteredExtUsersListCtrl{
    
    //Properties
    public String flexTableParameters {get;set;}
    
    public CommunityRegisteredExtUsersListCtrl(){
        
        GNT__UserPreferences__c userPrefs = GNT__UserPreferences__c.getValues(UserInfo.getUserId());
        Map<String, String> keyValueMap = new Map<String, String>();
        keyValueMap.put('Account.Id', userPrefs.GNT__OrganizationAccountId__C ); 
        flexTableParameters = JSON.serialize(keyValueMap);
    }
}