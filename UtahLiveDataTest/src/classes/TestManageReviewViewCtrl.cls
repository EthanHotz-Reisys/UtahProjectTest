@isTest
private with sharing class TestManageReviewViewCtrl{
    static testMethod void testController() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              Test.startTest();
              ManageReviewViewCtrl ctrl = new ManageReviewViewCtrl();
              ctrl.getKeyValueMap();
              Test.stopTest();
          }
        
    }
}