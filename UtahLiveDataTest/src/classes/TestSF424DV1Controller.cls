@isTest
private with sharing class TestSF424DV1Controller{
    static testMethod void testsubmitForm() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              Test.startTest();
              SF424DV1Controller ctrl = new SF424DV1Controller();
              ctrl.sign='Test';
              ctrl.apporg='Test';
              ctrl.subdate=Date.newInstance(2016,03,03);
              ctrl.submitForm();
              Test.stopTest();
          }
        
    }
}