@isTest
private with sharing class TestCommunityPasswordResetConfirmCtrl{
    static testMethod void testCommunity() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
  
              User u1=TestHelper.getAdminUser(true);
              Test.startTest();
             
              CommunityPasswordResetConfirmCtrl ctrl = new CommunityPasswordResetConfirmCtrl();
              ctrl.loginPage();
              Test.stopTest();
          }
        
    }
    
}