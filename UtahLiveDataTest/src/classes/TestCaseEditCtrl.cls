@isTest
private with sharing class TestCaseEditCtrl{
    static testMethod void testController() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          
              User u1=TestHelper.getAdminUser(true);
              Case tempCase = new Case();
              insert tempCase;
              
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(tempCase);
              ApexPages.CurrentPage().getParameters().put('id',tempCase.Id);    
              CaseEditCtrl ctrl = new CaseEditCtrl(sc);  
              ctrl.recordType = 'Case';
              ctrl.getKeyValueMap();
              Test.stopTest();
          }
        
    }
    
}