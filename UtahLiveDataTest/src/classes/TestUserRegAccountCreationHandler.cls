@isTest
private class TestUserRegAccountCreationHandler {

    static testMethod void myUnitTest() {
        
        User u = TestHelper.getAdminUser(true);
        system.runAs(u) {
            // skip unwanted triggers
            AccountTriggerHelper.skipAll = true;
            ContactTriggerHelper.skiptrigger = true;
            UserRegistrationTriggerHelper.skipTrigger = true;
            UserTriggerHelper.skipTrigger = true;
            
            UserRegistration__c userreg = new UserRegistration__c(AccountCreateFlag__c=true,Status__c='Approved');
            userreg.OrganizationName__c = 'REI Systems Test';
            userreg.OrgnizationPhoneNumber__c = '1234567890';
            userreg.EINText__c='123456789';
            userreg.OrganizationTypeSInglePicklist__c='State governments';
            userreg.PrimaryRepPrefix__c='Miss.';
            userreg.PrimaryRepFirstName__c = 'Sample';
            userreg.PrimaryRepLastName__c = 'Test';
            userreg.PrimaryRepCity__c = 'Sterling';
            userreg.PrimaryRepState__c = 'Virginia';
            userreg.SecondaryRepEmail__c = 'abc@test.com';
            userreg.SecondaryRepPrefix__c = 'Mr.';
            userreg.SecondaryRepFirstName__c='REI';
            userreg.SecondaryRepLastName__c='Systems';
            userreg.SecondaryRepCity__c='Fairfax';
            userreg.SecondaryRepState__c='Virginia';
            insert userreg;
            
            Account acc = TestHelper.getAccount(false);
            acc.UserRegistration__c = userreg.id;
            insert acc;
            Contact con =TestHelper.getContact(false);
            con.Accountid = acc.id;
            insert con;
            //User user = TestHelper.getPortalUser(true);
            Test.startTest();
            UserRegAccountUserCreationHandler userregcreationhandler = new UserRegAccountUserCreationHandler();
            Database.executeBatch(userregcreationhandler);
           
            Test.stopTest();
        }
    
    }
}