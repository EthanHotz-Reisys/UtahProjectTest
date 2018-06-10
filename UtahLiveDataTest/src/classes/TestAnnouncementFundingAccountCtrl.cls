@isTest
private with sharing class TestAnnouncementFundingAccountCtrl{
    static testMethod void testController() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              AnnouncementTriggerHelper.skipTrigger=true;
              UserTriggerHelper.skipTrigger = true;
              
              Announcement__c ann = TestHelper.getAnnouncement(true);
             
              Test.startTest();
              ApexPages.currentPage().getParameters().put('Id',ann.id);
              AnnouncementFundingAccountCtrl ctrl = new AnnouncementFundingAccountCtrl();
              ctrl.deleteURL = new PageReference('myPage.TestPage');
              Test.stopTest();
         }
        
    }
}