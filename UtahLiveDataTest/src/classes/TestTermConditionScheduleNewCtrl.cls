@isTest
private with sharing class TestTermConditionScheduleNewCtrl{
    static testMethod void testController() {
          User u = TestHelper.getAdminUser(true);
          
          System.runAs(u){
            
            TermCondition__c termCond = new TermCondition__c();
            insert termCond;
            
            TermConditionSchedule__c termConSc= new TermConditionSchedule__c(TermAndCondition__c=termCond.Id);
            insert termConSc;

         
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(termConSc);
        ApexPages.currentPage().getParameters().put('id',termConSc.Id);
        ApexPages.currentPage().getParameters().put('termConditionId',termCond.Id);
        ApexPages.currentPage().getParameters().put('template','Test Template');
        TermConditionScheduleNewCtrl ctrl = new TermConditionScheduleNewCtrl();
        ctrl.getKeyValueMap();
        Test.stopTest();
        
      }
        
    } 
}