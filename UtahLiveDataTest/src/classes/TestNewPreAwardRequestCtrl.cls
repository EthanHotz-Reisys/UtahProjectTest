@isTest
private with sharing class TestNewPreAwardRequestCtrl{
    static testMethod void testclickHandler() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              GNT.KeyValueStoreHelper.setTextValue('ChangeRequestNewCRValidation','In Progress,New',true);
              ApplicationTriggerHelper.skipTrigger = true;
              AnnouncementTriggerHelper.skipTrigger = true;
              
              Announcement__c ann = TestHelper.getAnnouncement(true);
              Application__c app = TestHelper.getApplication(ann.Id,true);
              ChangeRequest__c changeReq = new ChangeRequest__c();
              changeReq.Application__c = app.Id;
              changeReq.Status__c='In Progress';
              insert changeReq;
              
              Test.startTest();
              NewPreAwardRequestCtrl ctrl = new NewPreAwardRequestCtrl();
              ctrl.urlParams.put('parentRecordIdOfFlexTable',app.Id);
              ctrl.clickHandler();
              changeReq.Status__c='Approved';
              update changeReq;
              ctrl.clickHandler();
              Test.stopTest();
          }
        
    }
}