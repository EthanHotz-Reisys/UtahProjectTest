@isTest
private with sharing class TestCloseoutInventoryEditCtrl{
    static testMethod void testController() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          
              GrantTriggerHelper.skipTrigger = true;
              Grant__c grant = TestHelper.getGrant(true);
              Closeout__c closeOut = TestHelper.getCloseout(grant.Id,true);
              CloseoutInventory__c closeOutInv = new CloseoutInventory__c(Closeout__c=closeOut.Id);
              insert closeOutInv;

              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(closeOutInv);
              ApexPages.currentPage().getParameters().put('id',closeOutInv.id);
              ApexPages.CurrentPage().getParameters().put('closeoutId',closeOut.Id); 
              CloseoutInventoryEditCtrl ctrl = new CloseoutInventoryEditCtrl(sc);
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
              Closeout__c closeOut = TestHelper.getCloseout(grant.Id,true);
              CloseoutInventory__c closeOutInv = new CloseoutInventory__c(Closeout__c=closeOut.Id);
              insert closeOutInv;

              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(closeOutInv);
              ApexPages.CurrentPage().getParameters().put('closeoutId',closeOut.Id); 
              CloseoutInventoryEditCtrl ctrl = new CloseoutInventoryEditCtrl(sc);
              ctrl.getKeyValueMap();
              Test.stopTest();
          }
        
    }
    
}