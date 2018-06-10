@isTest
private with sharing class TestApplicantSRComments{

    static testMethod void testController() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              List<String> IdSet = new List<String>();
              AnnouncementTriggerHelper.skipTrigger=true;
              Announcement__c ann = TestHelper.getAnnouncement(true);
             
              ApplicationTriggerHelper.skipTrigger= true;
              Application__c app = TestHelper.getApplication(ann.Id,true);
              
              ChangeRequest__c changeReq = new ChangeRequest__c();
              changeReq.Application__c=app.Id;
              changeReq.ApplicantComments__c='Test123';
              insert changeReq;
              
              
              Test.startTest();
              ApexPages.currentPage().getParameters().put('id',changeReq.Id);
              ApplicantSRComments ctrl = new ApplicantSRComments();
              ctrl.save();
              Test.stopTest();
         }
        
    }
    
}