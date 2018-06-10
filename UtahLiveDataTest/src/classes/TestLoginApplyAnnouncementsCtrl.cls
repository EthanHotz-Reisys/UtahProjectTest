@isTest
private with sharing class TestLoginApplyAnnouncementsCtrl{
    static testMethod void testforwardToApplyPage() {
       
          AccountTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              
              AnnouncementTriggerHelper.skipTrigger = true;
              Announcement__c ann = TestHelper.getAnnouncement(true);
              
              Test.startTest();
              ApexPages.currentPage().getParameters().put('id',ann.id);
              ApexPages.currentPage().getParameters().put('t','Test');
              LoginApplyAnnounementsCtrl ctrl = new LoginApplyAnnounementsCtrl();
              ctrl.forwardToApplyPage();
              Test.stopTest();
          }
        
    }
}