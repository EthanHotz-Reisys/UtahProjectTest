@isTest
private with sharing class TestSendForReviewFromStepCtrl{
    @isTest
    private static void testSendForReviewFromStepCtrl(){
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        Contact c = new Contact();
        c.LastName = 'Test';
        c.Email = 'Test@test.com';
        insert c;
        
        System.runAs(u){
            AnnouncementTriggerHelper.skipTrigger = true;
            ReviewStep__c rs = TestHelper.getReviewStep(true);
            ApexPages.CurrentPage().getParameters().put('id',rs.id);
            Test.startTest();
            SendForReviewFromStepCtrl srfs = new SendForReviewFromStepCtrl();
            srfs.getKeyValueMap();
            System.assert(srfs.getListParameters() != null);
            Test.stopTest();
       }
    }
}