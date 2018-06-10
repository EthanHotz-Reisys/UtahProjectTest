@isTest
private with sharing class TestContactRedirectCtrl{
    static testMethod void testController() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          
              Contact ct = TestHelper.getContact(true);

               
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(ct);
              ApexPages.currentPage().getParameters().put('id',ct.id);
              ContactRedirectCtrl ctrl = new ContactRedirectCtrl(sc);
              ctrl.forwardToProfilePage();
              Test.stopTest();
          }
        
    }
    
}