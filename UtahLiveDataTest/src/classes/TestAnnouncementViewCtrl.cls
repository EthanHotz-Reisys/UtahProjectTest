@isTest(Seealldata=false)
private with sharing class TestAnnouncementViewCtrl {
    static testMethod void granteeTest() {
        Announcement__c announce = null;
        User u = new User(Id=UserInfo.getUserId());        
        System.runAs(u){
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            ProgramTriggerHelper.skipTrigger=true;
            GNT.TriggerHelper.skipTrigger=true;
            announce=TestHelper.getAnnouncement(true);        
        }        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(announce);
        ApexPages.currentPage().getParameters().put('id',announce.Id);
        AnnouncementViewCtrl ann = new AnnouncementViewCtrl(sc);        
        ann.getKeyValueMap();
        ann.getListParams();
        Test.stopTest();
    }

     static testMethod void grantorTest() {
        Announcement__c announce = null;
        User u = new User(Id=UserInfo.getUserId());        
        System.runAs(u){
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            ProgramTriggerHelper.skipTrigger=true;
            GNT.TriggerHelper.skipTrigger=true;
            announce=TestHelper.getGrantorAnnouncement(true);
        
        }        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(announce);
        ApexPages.currentPage().getParameters().put('id',announce.Id);
        AnnouncementViewCtrl ann = new AnnouncementViewCtrl(sc);
        ann.getKeyValueMap();
        ann.getListParams();
        Test.stopTest();
    }
}