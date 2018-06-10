@isTest
private with sharing class TestAssignCaseCtrl{
    static testMethod void testController() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          
              Case tempCase = new Case();
              insert tempCase;

              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(tempCase);
              ApexPages.currentPage().getParameters().put('id',tempCase.id);
              AssignCaseCtrl ctrl = new AssignCaseCtrl(sc);
              ctrl.recordType='Case';
              ctrl.getKeyValueMap();
              Test.stopTest();
          }
        
    }
   
    
}