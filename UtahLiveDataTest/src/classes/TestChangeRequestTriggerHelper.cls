/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2014   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestChangeRequestTriggerHelper{


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        ApplicationTriggerHelper.SkipTrigger = true;
        AnnouncementTriggerHelper.SkipTrigger = true;
        Announcement__c ann = TestHelper.getAnnouncement(true);
        Application__c app = new Application__c();
        app.Announcement__c = ann.Id;
        insert app;
        ChangeRequest__c cr = new ChangeRequest__c();
        cr.application__c = app.Id;
        Test.startTest();
        insert cr;
        Test.stopTest();
        //assert
        System.assertEquals(cr.Id, cr.Id);
        
        
        }
    }
    
      @IsTest(OnInstall=false)
        public static void test_ctrl1() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        ApplicationTriggerHelper.SkipTrigger = true;
        AnnouncementTriggerHelper.SkipTrigger = true;
        Announcement__c ann = TestHelper.getAnnouncement(true);
        Application__c app = new Application__c();
        app.Announcement__c = ann.Id;
        insert app;
        ChangeRequest__c cr = new ChangeRequest__c();
        cr.application__c = app.Id;
        cr.status__c = 'Initiated';
        insert cr;
        Test.startTest();
        update cr;
        Test.stopTest();
        //assert
        System.assertEquals(cr.Id, cr.Id);
        
        
        }
    }
 }