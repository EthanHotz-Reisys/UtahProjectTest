@isTest
private with sharing class TestInternalLoginRedirectCtrl{
    static testMethod void testforwardToPage() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              AnnouncementTriggerHelper.skipTrigger= true;
              ApplicationTriggerHelper.skiptrigger = true;
              Announcement__c ann = TestHelper.getAnnouncement(true);
              Application__c app = TestHelper.getApplication(ann.Id,true);
              Test.startTest();
               InternalLoginRedirectCtrl ctrl = new InternalLoginRedirectCtrl();
              ctrl.forwardToPage();
              Test.stopTest();
          }
        
    }
}