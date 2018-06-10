@isTest
private with sharing class TestCommunityUserDeactivateCtrl{
    static testMethod void testCommunity() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(false);
          u.IsActive=true;
          insert u;
          System.runAs(u){
  
              User u1=TestHelper.getAdminUser(true);
              Test.startTest();
              ApexPages.currentPage().getParameters().put('userId',u1.id);
              CommunityUserDeactivateCtrl ctrl = new CommunityUserDeactivateCtrl();
              ctrl.cancelPage();
              ctrl.deactivateUser();
              Test.stopTest();
          }
        
    }
    
    static testMethod void testCommunity2() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(false);
          u.IsActive=true;
          insert u;
          System.runAs(u){
  
              Test.startTest();
              CommunityUserDeactivateCtrl ctrl = new CommunityUserDeactivateCtrl();
              ctrl.cancelPage();
              ctrl.deactivateUser();
              Test.stopTest();
          }
        
    }
    
}