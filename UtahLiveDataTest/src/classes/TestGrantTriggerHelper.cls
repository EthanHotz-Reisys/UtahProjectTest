@isTest
public with sharing class TestGrantTriggerHelper {

    @isTest
    static void grantorTest() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        

        System.runAs(u) {
            AccountTriggerHelper.skipTrigger = true;
            ProgramTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            AwardTriggerHelper.skipTrigger = true;

            Account acc = TestHelper.getAccount(true);
            
            Grant__c grant = TestHelper.getGrant(false);
            grant.InternalOrganization__c = acc.Id;

            Program__c program = TestHelper.getProgram(acc.Id, false);
            program.programsubtype__c = 'Project Grants';
            insert program;

            grant.Program__c = program.Id;


            BusinessPackage__c bp=new BusinessPackage__c();
            GNT__PageTemplate__c pt = TestHelper.getPageTemplateConfig(true);
            GNT__Package__c pack = TestHelper.getPackage(false, pt);
            pack.name='test';
            pack.GNT__SubmissionType__c = 'Application';
            pack.GNT__LatestVersion__c = true;
            pack.GNT__Status__c = 'Active';
            insert pack;
            bp.PackageConfig__c=pack.Id;
            //bp.PackageType__c = 'Closeout';
            bp.Grant__c = grant.Id;
            bp.Program__c = program.Id;
            insert bp; 
            
            Announcement__c announcement = TestHelper.getAnnouncement(true);
            grant.Announcement__c = announcement.Id;
            
            BusinessPackage__c bp2=new BusinessPackage__c();
            GNT__PageTemplate__c pt2 = TestHelper.getPageTemplateConfig(true);
            GNT__Package__c pack2 = TestHelper.getPackage(false, pt2);
            pack2.name='test';
            //pack2.GNT__SubmissionType__c = 'Application';
            pack2.GNT__LatestVersion__c = true;
            pack2.GNT__Status__c = 'Active';
            insert pack2;
            bp2.PackageConfig__c=pack2.Id;
            //bp.PackageType__c = 'Closeout';
            bp2.Grant__c = grant.Id;
            bp2.FundingOpportunity__c = announcement.Id;

            insert bp2;

            Test.startTest();
            
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantor');
            insert grant;
            Test.stopTest();


        }
        */
    }

    @isTest
    static void granteeTest() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee');

        System.runAs(u) {
            AccountTriggerHelper.skipTrigger = true;
            ProgramTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            
            Account acc = TestHelper.getAccount(false);
            acc.Name = 'USBE';
            insert acc;

            Grant__c grant = TestHelper.getGrant(false);
            grant.InternalOrganization__c = acc.Id;
            grant.ProjectPeriodEndDate__c = Date.TODAY() + 365;

            Program__c program = TestHelper.getProgram(acc.Id, false);
            program.programsubtype__c = 'Project Grants';
            insert program;


            BusinessPackage__c bp=new BusinessPackage__c();
            GNT__PageTemplate__c pt = TestHelper.getPageTemplateConfig(true);
            GNT__Package__c pack = TestHelper.getPackage(false, pt);
            pack.name='test';
            pack.GNT__SubmissionType__c = 'Application';
            pack.GNT__LatestVersion__c = true;
            pack.GNT__Status__c = 'Active';
            insert pack;
            bp.PackageConfig__c=pack.Id;
            //bp.PackageType__c = 'Closeout';
            bp.Grant__c = grant.Id;
            bp.Program__c = program.Id;
            insert bp; 
            
            Announcement__c announcement = TestHelper.getAnnouncement(true);
            grant.Announcement__c = announcement.Id;
            
            BusinessPackage__c bp2=new BusinessPackage__c();
            GNT__PageTemplate__c pt2 = TestHelper.getPageTemplateConfig(true);
            GNT__Package__c pack2 = TestHelper.getPackage(false, pt2);
            pack2.name='test';
            //pack2.GNT__SubmissionType__c = 'Application';
            pack2.GNT__LatestVersion__c = true;
            pack2.GNT__Status__c = 'Active';
            insert pack2;
            bp2.PackageConfig__c=pack2.Id;
            //bp.PackageType__c = 'Closeout';
            bp2.Grant__c = grant.Id;
            bp2.FundingOpportunity__c = announcement.Id;

            insert bp2;

            Test.startTest();
            insert grant;
            Test.stopTest();


        }
        */
    }
}