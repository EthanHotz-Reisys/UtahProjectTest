@isTest
private with sharing class TestFOLevelPostAwardTemplateAssignCtrl{
    static testMethod void testController() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              AnnouncementTriggerHelper.skipTrigger = true;
              Announcement__c ann = TestHelper.getAnnouncement(true);
              
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(ann);
              ApexPages.currentPage().getParameters().put('id',ann.id);
              FOLevelPostAwardTemplateAssignmentCtrl ctrl = new FOLevelPostAwardTemplateAssignmentCtrl(sc);
              ctrl.getKeyValueMap();
              Test.stopTest();
          }
        
    }
}