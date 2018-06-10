@IsTest
private with sharing class TestFundingAccountPlanCtrl {

    @IsTest
    private static void testcontroller() {
         UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
  
        System.runAs(u) { 
            AnnouncementTriggerHelper.skipTrigger = true;
           
            Announcement__c ann = TestHelper.getAnnouncement(true);

            //Execute test
            Test.startTest();
            ApexPages.CurrentPage().getParameters().put('id', ann.Id);  
            ApexPages.StandardController stdController = new ApexPages.StandardController(ann);
            FundingAllocationPlanCtrl ctrl = new FundingAllocationPlanCtrl(stdController);
            ctrl.savePage = new PageReference('Page.myPage');
            ctrl.cancelPage = new PageReference('Page.myPage');
            ctrl.getKeyValueMap();
            Test.stopTest();
        }
    }
}