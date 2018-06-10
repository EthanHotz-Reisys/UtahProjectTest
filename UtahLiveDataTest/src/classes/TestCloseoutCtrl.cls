@isTest
private with sharing class TestCloseoutCtrl{
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
              CloseoutCtrl ctrl = new CloseoutCtrl(sc);
              ctrl.getKeyValueMap();
              Test.stopTest();
          }
        
    }
    
}