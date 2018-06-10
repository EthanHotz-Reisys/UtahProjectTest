@isTest
private with sharing class TestPreApplicationApprovalCtrl{
    static testMethod void testKeyValueMap() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              AnnouncementTriggerHelper.skipTrigger = true;
              
              Announcement__c ann = TestHelper.getAnnouncement(true);
         
              Test.startTest();
              ApexPages.currentPage().getParameters().put('id',ann.id);
              PreApplicationApprovalCtrl ctrl = new PreApplicationApprovalCtrl();
              ctrl.getKeyValueMap();
              Test.stopTest();
          }
        
    }
}