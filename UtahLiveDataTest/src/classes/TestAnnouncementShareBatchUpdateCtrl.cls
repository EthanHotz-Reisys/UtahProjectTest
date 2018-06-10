@isTest
private with sharing class TestAnnouncementShareBatchUpdateCtrl{
    static testMethod void testBatch() {
       /*
          UserTriggerHelper.skipTrigger = true; 
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              Set<Id> acctIds = new Set<Id>();
              Set<Id> pgmIds = new Set<Id>();
              
              GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
              AccountTriggerHelper.skipTrigger=true;
              UserTriggerHelper.skipTrigger = true;
              Account acct = TestHelper.getAccount(true);
              acctIds.add(acct.Id);
              
              ProgramTriggerHelper.skipTrigger = true;
              Program__c pgm = TestHelper.getProgram(acct.Id,true);
              pgmIds.add(pgm.Id);
              
              AnnouncementTriggerHelper.skipTrigger = true;
              Announcement__c ann = TestHelper.getAnnouncement(false);
              ann.Program__c=pgm.Id;
              insert ann;
              
              Test.startTest();
              AnnouncementShareBatchUpdateCtrl ctrl = new AnnouncementShareBatchUpdateCtrl(acctIds,pgmIds);
              Database.executeBatch(ctrl);
              Test.stopTest();
          }
       */
    }
    
}