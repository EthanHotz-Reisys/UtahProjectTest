@isTest
private with sharing class TestMyProfileEditCtrl{
    static testMethod void testController() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(u);
              ApexPages.currentPage().getParameters().put('id',u.id);
              MyProfileEditCtrl ctrl = new MyProfileEditCtrl(sc);
              Test.stopTest();
          }
        
    }
}