@isTest
private class TestUserTriggerHelper{

    @isTest
    private static void testInsert(){
    /*
        UserTriggerHelper.skipTrigger=false;
        User u = TestHelper.getAdminUser(false);
        
        System.runAs(u){
        Test.startTest();
        AccountTriggerHelper.skipTrigger = true;
    
        Account acc = TestHelper.getAccount(true);
        Contact c = new Contact();
        c.Lastname = 'Tester';
        c.AccountId = acc.Id;
        insert c;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole portalRole1 = [Select Id From UserRole Where Name = 'SYSTEM' Limit 1];
        UserRole portalRole2 = [Select Id From UserRole Where Name = 'SYSTEM' Limit 1];
        User user = new User();
        user.Alias = 'admtp';
        user.Email='sysAdmin@govbd.dev';
        user.EmailEncodingKey='UTF-8';
        user.LastName='Testing';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.ProfileId = p.Id;
        user.TimeZoneSidKey='America/New_York';
        user.UserName='sysAdmin'+Math.random()+'@govbd.dev';
        user.UserRoleId = portalRole1.Id;
        insert user;
         
        user.Email = 'Tester1@test.com';
        user.GNT__OrganizationId__c = acc.Id;
        user.OrganizationAccountName__c = acc.Name;
        user.UserRoleId = portalRole2.Id;
        //update user;
        
        Group g = new Group();
        g.Name = 'Test Group 1';
        g.DeveloperName = 'HERPA';
        insert g;
        
        
        //UserRole portalRole3 = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User user2 = TestHelper.getPortalUser(true);
        //user2.ContactId = c.Id;
        //user2.UserRoleId = portalRole3.Id;
        //update user2;
        
        Test.stopTest();
        system.assert(user != null);
        }
        
        */
    }
   
}