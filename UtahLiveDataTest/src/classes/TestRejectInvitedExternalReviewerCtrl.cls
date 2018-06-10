@isTest
private with sharing class TestRejectInvitedExternalReviewerCtrl{
    static testMethod void testclickHandler() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              List<String> IdSet = new List<string>();

              IdSet.add(u.Id);
              
              Test.startTest();
              RejectInvitedExternalReviewerCtrl ctrl = new RejectInvitedExternalReviewerCtrl();
              ctrl.selectedRecordIds = IdSet;
              ctrl.clickHandler();
              Test.stopTest();
          }
        
    }
}