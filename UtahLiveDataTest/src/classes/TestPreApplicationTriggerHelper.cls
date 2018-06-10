@isTest

private class TestPreApplicationTriggerHelper{

    @isTest
    private static void testPreApplicationTriggerHelper (){
        User admin = TestHelper.getAdminUser(true);
        UserRole ur = [SELECT Id, Name FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        AccountTriggerHelper.skipAll = true;
        RolesAndResponsibilities__c rolesAndResp = null;
        Program__c pgm = null;
        Announcement__c ann = null;
        User u;
        Account a;
        UserTriggerHelper.skipTrigger=true;
              
        system.runAs(admin){
            u = TestHelper.getAdminUser(false);
            u.UserRoleId = ur.Id;
            u.UserRole = ur;
            //u.UserType = 'Standard';
            System.debug('UserType=' + u.UserType);
            System.debug('RoleType=' + ur.Name);
            insert u;
            a = TestHelper.getAccount(false);
            a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
            a.IsActiveAgency__c=true;
            a.IsGrantingAgency__c=true;
            insert a;
            u.GNT__OrganizationId__c = a.id;
            update u;
        }
        List<Group> groups = [SELECT Name, RelatedId FROM Group WHERE type='Role'];
        List<String> ids = new List<String>();
        for(Group g: groups) {
            ids.add(g.RelatedId);
        }
        System.runAs(u) {
            
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            ProgramTriggerHelper.skipTrigger = true;
            
            TestHelper.createCustomSettings(true);
            pgm = TestHelper.getProgram(a.Id,true);
            ann = TestHelper.getAnnouncement(true);
            rolesAndResp = new RolesAndResponsibilities__c(Program__c = pgm.Id,BusinessRole__c='Fiscal Approver',Name__c=u.Id,Announcement__c=ann.Id);       
            insert rolesAndResp;      
                  
            PreApplication__c preApp = TestHelper.getPreApplication(false);
            preApp.ExternalOrganization__c=a.id;
            preApp.Announcement__c=ann.Id;
            insert preApp;
            Boolean isdeleted;
            test.StartTest();
            //preApp = TestHelper.getupdatedPreApplication(preApp.Id, false);
            preApp = TestHelper.getupdatedPreApplication(preApp.Id, true);
            isdeleted = TestHelper.deletePreApplication(preApp.Id);
            pgm = TestHelper.getProgram(a.Id,true);
            ann = TestHelper.getAnnouncement(true);
            rolesAndResp = new RolesAndResponsibilities__c(Program__c = pgm.Id,BusinessRole__c='Fiscal Approver',Name__c=u.Id,Announcement__c=ann.Id);       
            insert rolesAndResp;
            /*PreApplication__c preApp1 = TestHelper.getPreApplication(true);
            preApp1.status__c ='Approved';
            update preApp1;
            */
            PreApplicationTriggerHelper path = new PreApplicationTriggerHelper();
            
            test.stopTest();
            System.assertEquals(false, preApp.Submitted_to_Internal__c);
        }
    }
    
    @isTest
    private static void testPreApplicationTriggerHelper2 (){
        UserTriggerHelper.skipTrigger=true;
        User admin = TestHelper.getAdminUser(true);
        UserRole ur = [SELECT Id, Name FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        AccountTriggerHelper.skipAll = true;
        User u;
        Account a;
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');      
        Announcement__c ann = null;
   
        
        system.runAs(admin){
            u = TestHelper.getAdminUser(false);
            u.UserRoleId = ur.Id;
            u.UserRole = ur;
            insert u;
            
            a = TestHelper.getAccount(false);
            a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
            a.IsActiveAgency__c=true;
            a.IsGrantingAgency__c=true;
            insert a;
            
            u.GNT__OrganizationId__c = a.id;
            update u;
            
             GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
        }
        
        List<Group> groups = [SELECT Name, RelatedId FROM Group WHERE type='Role'];
        List<String> ids = new List<String>();
        for(Group g: groups) {
            ids.add(g.RelatedId);
        }
        System.runAs(u) {
        
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');  
            TestHelper.createCustomSettings(true);      
                  
            PreApplication__c preApp = TestHelper.getPreApplication(false);
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');  
            preApp.ExternalOrganization__c=a.id;
            insert preApp;
            Boolean isdeleted;
            test.StartTest();
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');  
            GNT__UserPreferences__c userPrefs = GNT__UserPreferences__c.getValues(UserInfo.getUserId());
            userPrefs.GNT__ProfileName__c = 'Applicant';
            update userPrefs;
            
           
            preApp = TestHelper.getupdatedPreApplication(preApp.Id, true);
           
            isdeleted = TestHelper.deletePreApplication(preApp.Id);
            PreApplicationTriggerHelper path = new PreApplicationTriggerHelper();
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
            PreApplication__c preApp1 = TestHelper.getPreApplication(false);
            insert preApp1;
            update preApp1;
            delete preApp1;

            test.stopTest();
           
        }
    }
    @isTest
    private static void testPreApplicationTriggerHelper3 (){
        UserTriggerHelper.skipTrigger=true;
        User admin = TestHelper.getAdminUser(true);
        UserRole ur = [SELECT Id, Name FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        AccountTriggerHelper.skipAll = true;
        User u;
        Account a;
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','Recipient');      
        Announcement__c ann = null;
   
        
        system.runAs(admin){
            u = TestHelper.getAdminUser(false);
            u.UserRoleId = ur.Id;
            u.UserRole = ur;
            insert u;
            
            a = TestHelper.getAccount(false);
            a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
            a.IsActiveAgency__c=true;
            a.IsGrantingAgency__c=true;
            insert a;
            
            u.GNT__OrganizationId__c = a.id;
            update u;
            
             GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','Recipient');
        }
        
        List<Group> groups = [SELECT Name, RelatedId FROM Group WHERE type='Role'];
        List<String> ids = new List<String>();
        for(Group g: groups) {
            ids.add(g.RelatedId);
        }
        System.runAs(u) {
        
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','Recipient');  
            TestHelper.createCustomSettings(true);      
                  
            PreApplication__c preApp = TestHelper.getPreApplication(false);
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','Recipient');  
            preApp.ExternalOrganization__c=a.id;
            insert preApp;
            Boolean isdeleted;
            test.StartTest();
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','Recipient');  
            GNT__UserPreferences__c userPrefs = GNT__UserPreferences__c.getValues(UserInfo.getUserId());
            userPrefs.GNT__ProfileName__c = 'Applicant';
            update userPrefs;
            
           
            preApp = TestHelper.getupdatedPreApplication(preApp.Id, true);
           
            isdeleted = TestHelper.deletePreApplication(preApp.Id);
            PreApplicationTriggerHelper path = new PreApplicationTriggerHelper();
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','Recipient');
            PreApplication__c preApp1 = TestHelper.getPreApplication(false);
            insert preApp1;
            update preApp1;
            delete preApp1;

            test.stopTest();
           
        }
    }
}