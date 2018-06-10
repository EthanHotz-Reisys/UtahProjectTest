@isTest
private with sharing class TestAnnouncementsRecordsCtrl{
    static testMethod void testController() {
       /*
         
          GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
          AccountTriggerHelper.skipTrigger=true;
          Account acct = TestHelper.getAccount(true);  
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(false);
          u.GNT__OrganizationId__c=acct.Id;
          insert u;
           System.runAs(u){
          
              UserTriggerHelper.skipTrigger = true;
              AnnouncementTriggerHelper.skipTrigger = true;
              Announcement__c ann = TestHelper.getAnnouncement(true);
              
              GrantTriggerHelper.skipTrigger = true;
              Grant__c grant = TestHelper.getGrant(true);
              
              AwardTriggerHelper.skipTrigger = true;
              Award__c award = TestHelper.getAwards(grant.Id,true);
              
              SoleSourceAwardRecipient__c soleSrcAwardRecp = new SoleSourceAwardRecipient__c();
              soleSrcAwardRecp.FundingOpportunity__c=ann.Id;
              soleSrcAwardRecp.Account__c=u.GNT__OrganizationId__c;
              insert soleSrcAwardRecp;
              
              Test.startTest();
              AnnouncementsRecordsActiveCtrl ctrl = new AnnouncementsRecordsActiveCtrl();
              ctrl.getkeyValueMap();
              ctrl.getListParameters();
              Test.stopTest();
          }
        */
    }
    
}