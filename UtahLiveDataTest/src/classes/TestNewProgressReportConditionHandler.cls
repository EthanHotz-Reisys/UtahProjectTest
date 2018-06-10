@isTest
private with sharing class TestNewProgressReportConditionHandler{
    static testMethod void testclickHandler() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              GrantTriggerHelper.skipTrigger = true;
              AwardTriggerHelper.skipTrigger = true;
              AccountTriggerHelper.skipAll=true;
              
              Grant__c grant = TestHelper.getGrant(true);
              Award__c awards = TestHelper.getAwards(grant.Id,true);
              TermCondition__c termCond = TestHelper.getTermCondition(false,'Progress Report');
              termCond.Award__c= awards.Id;
              insert termCond;
              
              Test.startTest();
              NewProgressReportConditionHandler ctrl = new NewProgressReportConditionHandler();
              ctrl.urlParams.put('id',awards.Id);
              ctrl.clickHandler();
              Test.stopTest();
          }
        
    }
    
     static testMethod void testclickHandler2() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              GrantTriggerHelper.skipTrigger = true;
              AwardTriggerHelper.skipTrigger = true;
              AccountTriggerHelper.skipAll=true;
              
              Grant__c grant = TestHelper.getGrant(true);
              Award__c awards = TestHelper.getAwards(grant.Id,false);
              awards.BudgetPeriodStartDate__c=Date.newInstance(2016,03,03);
              awards.BudgetPeriodEndDate__c= Date.newInstance(2016,12,12);
              insert awards;
              TermCondition__c termCond = TestHelper.getTermCondition(false,'Progress Report');
              termCond.Award__c= awards.Id;
              insert termCond;
              
              Test.startTest();
              NewProgressReportConditionHandler ctrl = new NewProgressReportConditionHandler();
              ctrl.urlParams.put('id',awards.Id);
              ctrl.clickHandler();
              Test.stopTest();
          }
        
    }
    
     static testMethod void testclickHandler3() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              GrantTriggerHelper.skipTrigger = true;
              AwardTriggerHelper.skipTrigger = true;
              AccountTriggerHelper.skipAll=true;
              
              Grant__c grant = TestHelper.getGrant(true);
              Award__c awards = TestHelper.getAwards(grant.Id,false);
              awards.BudgetPeriodStartDate__c=Date.newInstance(2016,03,03);
              awards.BudgetPeriodEndDate__c= Date.newInstance(2016,12,12);
              insert awards;
              TermCondition__c termCond = TestHelper.getTermCondition(false,'Term');
              termCond.Award__c= awards.Id;
              insert termCond;
              
              Test.startTest();
              NewProgressReportConditionHandler ctrl = new NewProgressReportConditionHandler();
              ctrl.urlParams.put('id',awards.Id);
              ctrl.clickHandler();
              Test.stopTest();
          }
        
    }
}