@isTest
private with sharing class TestTaskUpdateCls{
    static testMethod void testclickHandler() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              TaskTriggerHelper.skipTrigger = true;
              List<String> IdSet = new List<String>();
              
              Task tsk = TestHelper.getTask(false);
              tsk.status = 'Not Started';
              insert tsk;
              IdSet.add(tsk.Id);

              Test.startTest();
              TaskUpdateCls ctrl = new TaskUpdateCls();
              ctrl.selectedRecordIds = IdSet;
              ctrl.clickHandler();
              ctrl.selectedRecordIds = null;
              delete tsk;
              ctrl.clickHandler();
              Test.stopTest();
          }
        
    }
}