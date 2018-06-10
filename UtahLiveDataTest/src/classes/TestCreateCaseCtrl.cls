@isTest
private with sharing class TestCreateCaseCtrl{
    static testMethod void testController() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          
              Case tempCase = new Case();
              insert tempCase;

              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(tempCase);
              ApexPages.currentPage().getParameters().put('id',tempCase.id);
              CreateCaseCtrl ctrl = new CreateCaseCtrl(sc);
              ctrl.recordType='Case';
              ctrl.getKeyValueMap();
              Test.stopTest();
          }
        
    }
   
    
}