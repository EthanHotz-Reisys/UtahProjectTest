@isTest
private with sharing class TestExpenseReportScheduleViewCtrl{
    static testMethod void testKeyValueMap() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          
              AnnouncementTriggerHelper.skipTrigger = true;
              Announcement__c ann = TestHelper.getAnnouncement(true);
              
              TermCondition__c termCond = TestHelper.getTermCondition(false,'Payment Request');
              termCond.SubmissionType__c='Payment Request';
              insert termCond;
              
              TermConditionSchedule__c termCondSch = new TermConditionSchedule__c();
              termCondSch.TermAndCondition__c = termCond.Id;
              insert termCondSch;

               
              Test.startTest();
              ExpenseReportScheduleViewCtrl ctrl = new ExpenseReportScheduleViewCtrl();
              ctrl.getKeyValueMap();
              Test.stopTest();
          }
        
    }
    
}