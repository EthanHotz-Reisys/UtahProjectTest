/**
 
    **********************************************************
    Audit History
    **********************************************************
    7/27/2016   swati singh                           Created
    2016-08-03  Sarat Mahavratayajula                 Edited 
 
    **********************************************************  
*/
@isTest
private with sharing class TestChangeRequestCtrl{

    @isTest public static void test_ctrl() {
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);

        System.runAs(u) {
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationtriggerHelper.skiptrigger = true;
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,true);
            app.Status__c = 'Submitted';
            update app;

            GNT__PageTemplate__c pageTemplate = TestHelper.getPageTemplateConfig(true);
            GNT__Package__c pkg = TestHelper.getPackage(true,pageTemplate.Id);

            BusinessPackage__c businessPackage = new BusinessPackage__c(PackageConfig__c=pkg.Id,
                                                    PackageType__c='Application',FundingOpportunity__c=ann.Id);
            insert businessPackage;


            Test.startTest();
                PageReference pageRef = Page.ApplicationView;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('Id',app.Id);
                ChangeRequestCtrl changeRequestCtrl = new ChangeRequestCtrl();
                changeRequestCtrl.cancel();
                changeRequestCtrl.save();
            Test.stopTest();
        }
    }
 }