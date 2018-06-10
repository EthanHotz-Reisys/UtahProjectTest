@isTest
private with sharing class TestProfileDropDownConfigEditCtrl{
    static testMethod void testController() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              GNT__ProfileDropDownConfig__c profDropDownConfig = TestHelper.getProfileDropDownConfig(true);
              
              Test.startTest();
              ApexPages.StandardController sc = new ApexPages.standardController(profDropDownConfig);
              ApexPages.currentPage().getParameters().put('id',profDropDownConfig.id);
              ProfileDropDownConfigEditCtrl ctrl = new ProfileDropDownConfigEditCtrl(sc);
              Test.stopTest();
          }
        
    }
}