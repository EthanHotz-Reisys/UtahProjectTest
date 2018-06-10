@isTest
private with sharing class TestAnnouncementBudgetCatHelper{

    static testMethod void testController1() {
          
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              List<String> IdSet = new List<String>();
              AnnouncementTriggerHelper.skipTrigger=true;
              UserTriggerHelper.skipTrigger = true;
              Announcement__c ann = TestHelper.getAnnouncement(true);
             
              List<BudgetCategory__c> budCat = TestHelper.getBudgetCategory(true);
              FundingOpportunityBudgetCategory__c fundOppBudCat = new FundingOpportunityBudgetCategory__c();
              fundOppBudCat.BudgetCategory__c=budCat[0].Id;
              fundOppBudCat.FundingOpportunity__c=ann.Id;
              insert fundOppBudCat;
              IdSet.add(fundOppBudcat.Id);
              
              
              Test.startTest();
              AnnouncementBudgetCatHelper ctrl = new AnnouncementBudgetCatHelper();
              ctrl.clickHandler();
              ctrl.selectedRecordIds=IdSet;
              ctrl.clickHandler();
              Test.stopTest();
         }
        
    }
    
      
    static testMethod void testController2() {
          
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              List<String> IdSet = new List<String>();
              AnnouncementTriggerHelper.skipTrigger=true;
              UserTriggerHelper.skipTrigger = true;
              Announcement__c ann = TestHelper.getAnnouncement(true);
             
              List<BudgetCategory__c> budCat = TestHelper.getBudgetCategory(true);
              IdSet.add(ann.Id);
              
              
              Test.startTest();
              AnnouncementBudgetCatHelper ctrl = new AnnouncementBudgetCatHelper();
              ctrl.selectedRecordIds=IdSet;
              ctrl.clickHandler();
              Test.stopTest();
         }
        
    }
}