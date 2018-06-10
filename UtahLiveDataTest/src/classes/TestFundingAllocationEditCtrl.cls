@isTest
private with sharing class TestFundingAllocationEditCtrl{
    static testMethod void testController() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              AccountTriggerHelper.skipAll=true;
              AnnouncementTriggerHelper.skipTrigger = true;
              Announcement__c ann = TestHelper.getAnnouncement(true);
              PreApplication__c preApp = TestHelper.getPreApplication(true);
              
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(preApp);
              ApexPages.currentPage().getParameters().put('id',preApp.id);
              ApexPages.currentPage().getParameters().put('announcementid',ann.id);
              FundingAllocationEditCtrl ctrl = new FundingAllocationEditCtrl(sc);
              ctrl.getKeyValueMap();
              Test.stopTest();
          }
        
    }
}