@isTest
private with sharing class TestChangeRequestEditCtrl{
    static testMethod void testKeyValueMap() {
       
          User u = TestHelper.getAdminUser(true);
         
          System.runAs(u){
              
              AnnouncementTriggerHelper.skipTrigger=true;
              ApplicationTriggerHelper.skipTrigger=true;
              
              Announcement__c ann = TestHelper.getAnnouncement(true);
              Application__c app = TestHelper.getApplication(ann.Id,true);
              
              ChangeRequest__c changeReq = new ChangeRequest__c(Application__c=app.Id);
              insert changeReq;
              
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(changeReq);
              ApexPages.CurrentPage().getParameters().put('id',changeReq.Id);   
              ChangeRequestEditCtrl ctrl = new ChangeRequestEditCtrl(sc);
              Test.stopTest();
          }
        
    }
}