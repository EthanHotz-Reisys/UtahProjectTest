@isTest
private with sharing class TestOMBFormViewCtrl{
    static testMethod void testController() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              Form__c form = new Form__c();
              insert form;
              
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(form);
              ApexPages.currentPage().getParameters().put('id',form.id);
              ApexPages.currentPage().getParameters().put('templateName','Test Template');
              OMBFormViewCtrl ctrl = new OMBFormViewCtrl(sc);
              ctrl.getKeyValueMap();
              Test.stopTest();
          }
        
    }
}