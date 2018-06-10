@isTest
private class TestUserDiactivateHelper {
    
    @isTest static void test_method_one() {
        UserTriggerHelper.skipTrigger=true;
        Contact c = TestHelper.getcontact(true);
        /*Profile p = [SELECT Id FROM Profile WHERE Name = 'High Volume Customer Portal User' LIMIT 1];
        User u = new User(Alias = 'admtp', Email='sysAdmin@govbd.dev', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id,ManagerId=TestHelper.getStandardUser(true).Id, 
                TimeZoneSidKey='America/New_York', UserName='sysAdmin'+Math.random()+'@govbd.dev',
                ContactId = c.Id);
        insert u; */
        User u = TestHelper.getAdminUser(true);
        //Contact c = TestHelper.getcontact(true);

        Test.startTest();
            ApexPages.currentPage().getParameters().put('Id',u.Id);
            UserDiactivateHelper userDiactivateHelper = new UserDiactivateHelper();
            userDiactivateHelper.whenClicked();
        Test.stopTest();
    }
}