@isTest
private with sharing class TestRRSeniorPersonProfileSubCtrl{
    static testMethod void testController() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              Form__c form = new Form__c();
              insert form;
              
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(form);
              ApexPages.currentPage().getParameters().put('ParentId',form.id);
              RRSeniorPersonProfileSubCtrl ctrl = new RRSeniorPersonProfileSubCtrl(sc);
              ctrl.recordId=form.Id;
              Test.stopTest();
          }
        
    }
}