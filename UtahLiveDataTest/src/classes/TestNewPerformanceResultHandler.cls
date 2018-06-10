@isTest
private with sharing class TestNewPerformanceResultHandler{
    
     static testMethod void testclickHandler() {
     /*
        User u = TestHelper.getAdminUser(true); 
             
        System.runAs(u){
           
            GrantTriggerHelper.skipTrigger = true;
            AwardTriggerHelper.skipTrigger = true;
            AccountTriggerHelper.skipTrigger=true;
            
            Grant__c grant = TestHelper.getGrant(true);
            Award__c awards = TestHelper.getAwards(grant.Id,true);
            
            TermCondition__c termCond=TestHelper.getTermCondition(true,'Term');
            
            ProgressReports__c progReport = new ProgressReports__c(Award__c=awards.Id,TermandCondition__c=termCond.Id);
            insert progReport;
            
            Test.startTest();
            NewPerformanceResultHandler ctrl = new NewPerformanceResultHandler();
            ctrl.urlParams.put('id',progReport.Id);
            ctrl.urlParams.put('type','Progress Report');
            ctrl.clickHandler();
            Test.stopTest();
        }
        */
    }
    
}