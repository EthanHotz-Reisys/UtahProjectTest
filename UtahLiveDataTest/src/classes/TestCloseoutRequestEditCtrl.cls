@isTest
public with sharing class TestCloseoutRequestEditCtrl {
    
    @isTest
    static void editTest() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u) {
            AccountTriggerHelper.skipTrigger = true;
            GrantTriggerHelper.skipTrigger = true;
            Grant__c grant = TestHelper.getGrant(true);
            
            
            AwardTriggerHelper.skipTrigger = true;
            Award__c award = TestHelper.getAwards(grant.Id, true);
            award.Status__c = 'Activated';
            update award;
            
            BusinessPackage__c bp=new BusinessPackage__c();
            GNT__PageTemplate__c pt = TestHelper.getPageTemplateConfig(true);
            GNT__Package__c pack = TestHelper.getPackage(false, pt);
            pack.name='test';
            pack.GNT__SubmissionType__c = 'Application';
            pack.GNT__LatestVersion__c = true;
            pack.GNT__Status__c = 'Active';
            insert pack;
            bp.PackageConfig__c=pack.Id;
            bp.PackageType__c = 'Closeout';
            bp.Grant__c = grant.Id;
            insert bp;
            
            Closeout__c closeout = new Closeout__c();
            closeout.Grant__c = grant.Id;
            insert closeout;
            
            Test.startTest();
            ApexPages.standardController sc = new ApexPages.standardController(closeout);
            ApexPages.currentPage().getParameters().put('grantId',grant.Id);
            ApexPages.currentPage().getParameters().put('id',closeout.Id);
            CloseoutRequestEditCtrl ctrl = new CloseoutRequestEditCtrl(sc);
            ctrl.getKeyValueMap();
            Test.stopTest();
        }
        */
    }

    @isTest
    static void nullIdTest() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u) {
            AccountTriggerHelper.skipTrigger = true;
            GrantTriggerHelper.skipTrigger = true;
            Grant__c grant = TestHelper.getGrant(true);
            
            
            AwardTriggerHelper.skipTrigger = true;
            Award__c award = TestHelper.getAwards(grant.Id, true);
            award.Status__c = 'Activated';
            update award;
            
            BusinessPackage__c bp=new BusinessPackage__c();
            GNT__PageTemplate__c pt = TestHelper.getPageTemplateConfig(true);
            GNT__Package__c pack = TestHelper.getPackage(false, pt);
            pack.name='test';
            pack.GNT__SubmissionType__c = 'Application';
            pack.GNT__LatestVersion__c = true;
            pack.GNT__Status__c = 'Active';
            insert pack;
            bp.PackageConfig__c=pack.Id;
            bp.PackageType__c = 'Closeout';
            bp.Grant__c = grant.Id;
            insert bp;
            
            Closeout__c closeout = new Closeout__c();
            closeout.Grant__c = grant.Id;
            insert closeout;
            
            Test.startTest();
            ApexPages.standardController sc = new ApexPages.standardController(closeout);
            ApexPages.currentPage().getParameters().put('grantId',grant.Id);
            CloseoutRequestEditCtrl ctrl = new CloseoutRequestEditCtrl(sc);
            ctrl.getKeyValueMap();
            Test.stopTest();
        }
        */
    }
}