public class ProfileVisibilityCtrl {
    public Boolean canView {get; private set;}
    public ApexPages.StandardSetController stdCntrlr {get; set;}
    
    public Boolean showLoginCount{get;set;}
    public Integer lastMonthCount{get;set;}
    public Integer currentMonthCount{get;set;}
    public Integer allowedCount{get;set;}
    public ProfileVisibilityCtrl() {
        Map<String, String> UrlParameterMap = ApexPages.currentPage().getParameters();
        
        GNT__UserPreferences__c userPref = GNT__UserPreferences__c.getValues(UserInfo.getUserId());
        ConnectApi.UserSettings settings = ConnectApi.Organization.getSettings().userSettings;
        canView = false;
        if (userPref.GNT__isInternal__c || settings.canViewAllData || settings.canModifyAllData) {
            canView = true;
        } else {
            if (UrlParameterMap.containsKey('id')){
                Id id = UrlParameterMap.get('id');
                if (id.getSObjectType().getDescribe().getName() == 'Contact') {
                    List<User> users = [SELECT id FROM User WHERE ContactId =: id LIMIT 1];
                    id = users[0].id;
                }
                if (id.getSObjectType().getDescribe().getName() == 'User') {
                 GNT__UserPreferences__c subjectPref = GNT__UserPreferences__c.getValues(id);
                    if(!subjectPref.GNT__isInternal__c) {
                        if (userPref.GNT__OrganizationAccountId__c == subjectPref.GNT__OrganizationAccountId__c) {
                            canView = true;
                        }
                    }
                }
            }
        }
        Id id = UrlParameterMap.get('id');
        User u = [select GNT__GGUserType__c from User where id=:UserInfo.getuserId()];
        if(u.GNT__GGUserType__c == 'Passive' && id == UserInfo.getuserId()) {
            showLoginCount = true;
            lastMonthCount = [Select count() from LoginHistory where LoginTime = LAST_MONTH and userid =:UserInfo.getUserId() and LoginType = 'Application'];
            currentMonthCount = [Select count() from LoginHistory where LoginTime = THIS_MONTH and userid =:UserInfo.getUserId() and LoginType = 'Application'];
            GNT__GlobalConfig__c gc = GNT__GlobalConfig__c.getInstance(UserInfo.getUserId());
            if(gc != null && gc.GNT__AllowedLoginAttempts__c != null ) {
                allowedCount = Integer.valueOf(gc.GNT__AllowedLoginAttempts__c);
            }
        
        }
    }

    public ProfileVisibilityCtrl(ApexPages.StandardSetController controller) {
        stdCntrlr = controller;
        Map<String, String> UrlParameterMap = ApexPages.currentPage().getParameters();
        GNT__UserPreferences__c userPref = GNT__UserPreferences__c.getValues(UserInfo.getUserId());
        canView = false;
        if (userPref.GNT__isInternal__c) {
            canView = true;
        } else {
            if (UrlParameterMap.containsKey('id')){
                Id id = UrlParameterMap.get('id');
                if (id.getSObjectType().getDescribe().getName() == 'Contact') {
                    List<User> users = [SELECT id FROM User WHERE ContactId =: id LIMIT 1];
                    id = users[0].id;
                }
                if (id.getSObjectType().getDescribe().getName() == 'User') {
                 GNT__UserPreferences__c subjectPref = GNT__UserPreferences__c.getValues(id);
                    if(!subjectPref.GNT__isInternal__c) {
                        if (userPref.GNT__OrganizationAccountId__c == subjectPref.GNT__OrganizationAccountId__c) {
                            canView = true;
                        }
                    }
                }
            }
        }
    }
}