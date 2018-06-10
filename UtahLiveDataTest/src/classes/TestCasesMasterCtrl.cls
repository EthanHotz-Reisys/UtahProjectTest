@isTest
private with sharing class TestCasesMasterCtrl{
    static testMethod void testDisplayTable() {
       
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          
              User u1=TestHelper.getAdminUser(true);
              Case tempCase = new Case();
              insert tempCase;
              
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(tempCase);
              ApexPages.CurrentPage().getParameters().put('id',tempCase.Id);    
              CasesMasterCtrl ctrl = new CasesMasterCtrl(sc);  
              ctrl.recordType='Case';  
              ctrl.getDisplayTableTier1();
              ctrl.getDisplayTableTier2();
              ctrl.getLoggedInUserRole();
              ctrl.getKeyValueMap();
              Test.stopTest();
          }
        
    }
    
}