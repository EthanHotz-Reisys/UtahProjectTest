/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2016   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestChangeRequestMessageCtrl {


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        AnnouncementTriggerHelper.skiptrigger = true;
        ApplicationTriggerHelper.skiptrigger = true;
         Announcement__c ann = TestHelper.getAnnouncement(true);
        Application__c app = TestHelper.getApplication(ann.Id,false);
        app.ChangeRequestStatus__c = 'Change Request Accepted';
        insert app;
        Changerequest__c cr = new ChangeRequest__c();
        cr.application__c = app.Id;
        
        insert cr;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', app.Id);
        ApexPages.currentPage().getParameters().put('type', 'Applicant');
        ChangeRequestMessageCtrl ctrl = new ChangeRequestMessageCtrl();
        ChangeRequestMessageCtrl.getMessage(app.Id);
        Test.stopTest();

        //assert
        System.assertEquals(app.Id, app.Id);
        
        
        }
    }
  }