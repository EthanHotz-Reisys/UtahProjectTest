@isTest
private with sharing class TestAnnouncementFundingAccountsHelper{
    static testMethod void testClickHandler() {
          
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          
          System.runAs(u){
          AnnouncementTriggerHelper.skipTrigger = true;
          UserTriggerHelper.skipTrigger = true;
          List<String> IdSet = new List<String>();
          List<Id> newSet = new List<Id>();
          
          Announcement__c ann = TestHelper.getAnnouncement(true);
          FundingSource__c fundSrc = TestHelper.getFundingSource(true);
          FundingAccount__c fundAcc = TestHelper.getFundingAccount(true,fundSrc.Id);
          IdSet.add(fundAcc.Id);
          AnnouncementFundingAccount__c annfundAcc = new AnnouncementFundingAccount__c(Announcement__c=ann.Id,FundingAccount__c=fundAcc.Id); 
         
          Test.startTest();
          AnnouncementFundingAccountsHelper ctrl = new AnnouncementFundingAccountsHelper();
          ctrl.urlparams.put('announcementId',ann.Id);
          ctrl.selectedIds = newSet;
          ctrl.selectedRecordIds=IdSet;
          ctrl.clickHandler();
          Test.stopTest();
        
      }
        
    }
    
        static testMethod void testClickHandler2() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          
          System.runAs(u){
          AnnouncementTriggerHelper.skipTrigger = true;
          UserTriggerHelper.skipTrigger = true;
          
          List<String> IdSet = new List<String>();
          List<Id> newSet = new List<Id>();
          
          Announcement__c ann = TestHelper.getAnnouncement(true);
          FundingSource__c fundSrc = TestHelper.getFundingSource(true);
          FundingAccount__c fundAcc = TestHelper.getFundingAccount(true,fundSrc.Id);
          AnnouncementFundingAccount__c annfundAcc = new AnnouncementFundingAccount__c(Announcement__c=ann.Id,FundingAccount__c=fundAcc.Id); 
         
          Test.startTest();
          AnnouncementFundingAccountsHelper ctrl = new AnnouncementFundingAccountsHelper();
          ctrl.urlparams.put('announcementId',ann.Id);
          ctrl.selectedIds = newSet;
          ctrl.selectedRecordIds=IdSet;
          ctrl.clickHandler();
          Test.stopTest();
        
      }
        
    }

          static testMethod void testClickHandler3() {
          
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          
          System.runAs(u){
          AnnouncementTriggerHelper.skipTrigger = true;
          UserTriggerHelper.skipTrigger = true;
          
          List<String> IdSet = new List<String>();
          List<Id> newSet = new List<Id>();
          
          Test.startTest();
          AnnouncementFundingAccountsHelper ctrl = new AnnouncementFundingAccountsHelper();
          ctrl.selectedRecordIds=IdSet;
          ctrl.clickHandler();
          Test.stopTest();
        
      }
        
    }
    
}