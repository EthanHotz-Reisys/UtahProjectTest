@isTest
private with sharing class TestCloseoutExtensionCtrl{
    static testMethod void testController() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          
              GrantTriggerHelper.skipTrigger = true;
              Grant__c grant = TestHelper.getGrant(true);
              Closeout__c closeOut = TestHelper.getCloseout(grant.Id,true);
              
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(closeOut);
              ApexPages.currentPage().getParameters().put('id',closeOut.id);
              CloseoutExtensionCtrl ctrl = new CloseoutExtensionCtrl(sc);
              ctrl.getKeyValueMap();
              Test.stopTest();
          }
        
    }
    
    static testMethod void testController2() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          
              GrantTriggerHelper.skipTrigger = true;
              Grant__c grant = TestHelper.getGrant(true);
              Closeout__c closeOut = TestHelper.getCloseout(grant.Id,false);
              closeOut.Status__c='Created';
        
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(closeOut);
              ApexPages.currentPage().getParameters().put('id',null);
              CloseoutExtensionCtrl ctrl = new CloseoutExtensionCtrl(sc);
              Test.stopTest();
          }
        
    }
    
}