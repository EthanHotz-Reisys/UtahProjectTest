@isTest
private with sharing class TestTaskFieldMappingViewCtrl{
    static testMethod void testController() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              TaskTriggerHelper.skipTrigger = true;
              Task tsk = TestHelper.getTask(true);

              
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(tsk);
              ApexPages.currentPage().getParameters().put('id',tsk.id);
              TaskFieldMappingViewCtrl ctrl = new TaskFieldMappingViewCtrl(sc);
              Test.stopTest();
          }
        
    }
}