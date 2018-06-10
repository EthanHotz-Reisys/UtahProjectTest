@isTest
private with sharing class TestAnnouncementServiceAreaViewCtrl{
    static testMethod void testController() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              AnnouncementTriggerHelper.skipTrigger=true;
              UserTriggerHelper.skipTrigger = true;
              Announcement__c ann = TestHelper.getAnnouncement(true);
             
              ServiceArea__c servArea = TestHelper.getServiceArea(true);
              AnnouncementServiceArea__c annServArea = new AnnouncementServiceArea__c();
              annServArea .Announcement__c = ann.Id;
              annServArea .ServiceArea__c = servArea.Id;
              insert annServArea ;
              
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(annServArea);
              ApexPages.currentPage().getParameters().put('Id',annServArea.id);
              AnnouncementServiceAreaViewCtrl ctrl = new AnnouncementServiceAreaViewCtrl(sc);
              ctrl.getKeyValueMap();
              Test.stopTest();
         }
        
    }
}