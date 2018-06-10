@isTest
private with sharing class TestCommunityManageExternalUserCtrl{
    static testMethod void testController() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          

              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(u);
              ApexPages.currentPage().getParameters().put('userId',u.Id);        
              CommunityManageExternalUserCtrl ctrl = new CommunityManageExternalUserCtrl(sc);
              ctrl.contactId=null;
              Test.stopTest();
          }
        
    }
}