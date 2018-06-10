@isTest
private with sharing class TestReassignTasksSelectedCtrl{
    static testMethod void testKeyValueMap() {
       
          User u = TestHelper.getAdminUser(true);
          GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
          System.runAs(u){
              TaskTriggerHelper.skipTrigger = true;
              User u1 = TestHelper.getAdminUser(true);
              
              Task tsk = new Task(status = 'In Progress',IsReassignmentInitiated__c=false,GNT__CustomAppName__c= GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c'));
              insert tsk;
              
              Test.startTest();
              ReassignTasksSelectedCtrl ctrl = new ReassignTasksSelectedCtrl();
              ctrl.urlParams.put('sourceUser',u.Id);
              ctrl.urlParams.put('targetUser',u1.Id);
              ctrl.clickHandler();
              Test.stopTest();
          }
        
    }
}