@isTest
private with sharing class TestProgressReportListViewCtrl{
    static testMethod void testKeyValueMap() {
       
          User u = TestHelper.getAdminUser(true);
          Account acct = null;
          
          System.runAs(u){
              
              GrantTriggerHelper.skipTrigger = true;
              Grant__c grant = TestHelper.getGrant(true);
         
              Test.startTest();
              ApexPages.currentPage().getParameters().put('grantId',grant.id);
              ProgressReportListViewCtrl ctrl = new ProgressReportListViewCtrl();
              ctrl.getKeyValueMap();
              Test.stopTest();
          }
        
    }
}