@isTest
private with sharing class TestPreAwardSubReqCommentsCtrl{
    static testMethod void testController() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              ApplicationTriggerHelper.skipTrigger = true;
              AnnouncementTriggerHelper.skipTrigger = true;
              
              Announcement__c ann = TestHelper.getAnnouncement(true);
              Application__c app = TestHelper.getApplication(ann.Id,true);
              
              //ChangeRequest__c changeReq = new ChangeRequest__c();
               ChangeRequest__c changeReq = new ChangeRequest__c(Application__c=app.Id,Status__c='Approved');
              insert changeReq;
              
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(changeReq);
              ApexPages.currentPage().getParameters().put('id',changeReq.id);
              ApexPages.currentPage().getParameters().put('applicationId',app.Id);
              PreAwardSubmissionRequestCommentsCtrl ctrl = new PreAwardSubmissionRequestCommentsCtrl(sc);
              ctrl.getKeyValueMap();
              Test.stopTest();
          }
        
    }
}