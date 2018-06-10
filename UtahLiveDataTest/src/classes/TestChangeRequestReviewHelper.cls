@isTest
private with sharing class TestChangeRequestReviewHelper{
    static testMethod void testclickHandler() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          
              GrantTriggerHelper.skipTrigger = true;
              ApplicationTriggerHelper.skipTrigger = true;
              AnnouncementTriggerHelper.skipTrigger = true;
              List<String> IdSet = new List<String>();
              
              Announcement__c ann = TestHelper.getAnnouncement(true);
              Application__c app = TestHelper.getApplication(ann.Id,true);
              ChangeRequest__c changeReq = new ChangeRequest__c(Application__c=app.Id);
              insert changeReq;
              IdSet.add(changeReq.Id);
              
              Test.startTest();
              ChangeRequestReviewHelper ctrl = new ChangeRequestReviewHelper();
              ctrl.urlParams.put('id',changeReq.Id);
              ctrl.selectedRecordIds = IdSet;
              ctrl.clickHandler();
              Test.stopTest();
          }
        
    }
    
}