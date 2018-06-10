@isTest
private with sharing class TestCaseViewCtrl{
    static testMethod void testController() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          
              /*Case tempCase = new Case();
              insert tempCase;
              
              AnnouncementTriggerHelper.skipTrigger = true;
              ReviewTriggerHelper.skipTrigger = true;
              Announcement__c ann = TestHelper.getAnnouncement(true);
              
              ReviewGroup__c reviewGroup = new ReviewGroup__c();
              reviewGroup.Announcement__c = ann.id;
              reviewGroup.NumberOfReviewSteps__c= Decimal.valueOf('2.0');
              insert reviewGroup;
              
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(tempCase);
              ApexPages.CurrentPage().getParameters().put('id',tempCase.Id);
              ApexPages.CurrentPage().getParameters().put('isClose','true');
              CaseViewCtrl ctrl = new CaseViewCtrl(sc);
              ctrl.reviewGrp = reviewGroup;
              ctrl.recordType='Review';
              ctrl.getKeyValueMap();
              ctrl.closeIssue();
              Test.stopTest();*/
          }
        
    }
    
}