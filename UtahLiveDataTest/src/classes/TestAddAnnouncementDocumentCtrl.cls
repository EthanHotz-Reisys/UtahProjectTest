@isTest
private with sharing class TestAddAnnouncementDocumentCtrl{
    static testMethod void testController() {
/*
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          Account acct = null;
          
          System.runAs(u){
            AnnouncementTriggerHelper.skipTrigger = true;
            ProgramTriggerHelper.skipTrigger = true;
            UserTriggerHelper.skipTrigger = true;
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            AccountTriggerHelper.skipTrigger=true;
            
            acct = TestHelper.getAccount(true);
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Program__c pgm = TestHelper.getProgram(acct.Id,true);
          
         
            Test.startTest();
            ApexPages.currentPage().getParameters().put('announcementId',ann.id);
            ApexPages.currentPage().getParameters().put('programId',pgm.id);
            ApexPages.CurrentPage().getParameters().put('required','No');
            AddAnnouncementDocumentCtrl ctrl = new AddAnnouncementDocumentCtrl();
            ctrl.getKeyValueMap();
            ctrl.getListParams();
            ApexPages.CurrentPage().getParameters().put('required','true');
            AddAnnouncementDocumentCtrl ctrl1 = new AddAnnouncementDocumentCtrl();
            ctrl1.getKeyValueMap();
            Test.stopTest();
        }
    */    
    }
}