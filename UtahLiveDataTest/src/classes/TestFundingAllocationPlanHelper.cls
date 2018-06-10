@isTest
private with sharing class TestFundingAllocationPlanHelper{
    static testMethod void testClickHandler() {
          UserTriggerHelper.skipTrigger = true;         
          User u = TestHelper.getAdminUser(true);
          
          System.runAs(u){
          AnnouncementTriggerHelper.skipTrigger = true;
          List<String> IdSet = new List<String>();
          List<Id> newSet = new List<Id>();
          
          Announcement__c ann = TestHelper.getAnnouncement(true);
          ann.FormulaVariable1__c=1;
          ann.DWVariable1__c=2;
          ann.FormulaVariable2__c=1;
          ann.DWVariable2__c=2;
          ann.FormulaVariable3__c=1;
          ann.DWVariable3__c=2;
          ann.SetAsideAmount__c=10;
          update ann;
         
          PreApplication__c preApp = TestHelper.getPreApplication(false);
          preApp.Announcement__c = ann.Id;
          preApp.FormulaVariable1__c=2;
          preApp.FormulaVariable2__c=2;
          preApp.FormulaVariable3__c=2;
          preApp.PreApplicationScore__c=100;
          insert preApp;
          
          Test.startTest();
          FundingAllocationPlanHelper ctrl = new FundingAllocationPlanHelper();
          ctrl.urlparams.put('id',ann.Id);
          ctrl.clickHandler();
          Test.stopTest();
        
      }
        
    }
    
       static testMethod void testClickHandler2() {
          UserTriggerHelper.skipTrigger = true; 
          User u = TestHelper.getAdminUser(true);
          
          System.runAs(u){
          AnnouncementTriggerHelper.skipTrigger = true;
          Announcement__c ann = TestHelper.getAnnouncement(true);
          update ann;
         
          PreApplication__c preApp = TestHelper.getPreApplication(false);
          preApp.Announcement__c = ann.Id;
          insert preApp;
          
          Test.startTest();
          FundingAllocationPlanHelper ctrl = new FundingAllocationPlanHelper();
          ctrl.urlparams.put('id',ann.Id);
          ctrl.clickHandler();
          Test.stopTest();
        
      }
        
    }
    
}