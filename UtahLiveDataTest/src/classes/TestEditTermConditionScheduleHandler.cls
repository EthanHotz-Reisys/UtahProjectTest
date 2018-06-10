@isTest
private with sharing class TestEditTermConditionScheduleHandler{
    static testMethod void testclickHandler() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){

              AccountTriggerHelper.skipAll=true;
              TermCondition__c termCond = TestHelper.getTermCondition(false,'Payment Request');
              termCond.SubmissionType__c='Payment Request';
              insert termCond;
              
              TermConditionSchedule__c termCondSch = new TermConditionSchedule__c();
              termCondSch.TermAndCondition__c = termCond.Id;
              insert termCondSch;

               
              Test.startTest();
              EditTermConditionScheduleHandler ctrl = new EditTermConditionScheduleHandler();
              ctrl.clickHandler();
              Test.stopTest();
          }
        
    }
    
}