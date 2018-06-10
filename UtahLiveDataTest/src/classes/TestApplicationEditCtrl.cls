@isTest
private with sharing class TestApplicationEditCtrl {
    static testMethod void test1() {
    /*
        UserTriggerHelper.skipTrigger = true;
        AccountTriggerHelper.skipTrigger=true;
        ApplicationTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        Account acc=TestHelper.getAccount(true);
        u.GNT__OrganizationId__c=acc.Id;
        update u;
        acc.Code__c='UOV';
        update acc;
        Application__c app = null;
        preApplication__c preApp = null;
        Announcement__c ann = null;
        Program__c prog=null;
 
        System.runAs(u){

            ApplicationTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            FOALead__c foalead=TestHelper.getFOALead(true);
            foalead.LastUpdateDate__c=System.today();
            update foalead;
            
            Prog=Testhelper.getProgram(acc.Id,true);
            Prog.FederalProgramCFDA__c='A123';
            update Prog;
            BusinessPackage__c bp=new BusinessPackage__c();
            GNT__PageTemplate__c pt = TestHelper.getPageTemplateConfig(true);
            GNT__Package__c pack = TestHelper.getPackage(false, pt);
            pack.name='test';
            pack.GNT__SubmissionType__c = 'Application';
            pack.GNT__LatestVersion__c = true;
            pack.GNT__Status__c = 'Active';
            insert pack;
            bp.PackageConfig__c=pack.Id;
            insert bp;

            ann = TestHelper.getAnnouncement(prog.Id,true);
            ann.ApplyingAgency__c=acc.Id;
            ann.AwardingFedAgency__c=acc.Id;
            ann.AwardCeiling__c=100000;
            ann.closeDate__c=System.today();
            ann.AnnouncementNumber__c='123456';
            ann.AwardFloor__c=10000;
            ann.Budget__c=50000;
            ann.ApplicationDeadlineWithDateTime__c=System.today();
            ann.EligibilityDescription__c='test';
            ann.PreApplicationDeadline__c=System.today();
            ann.PreApplicationDeadlineWithDateTime__c=System.today();
            ann.StateProgram__c=prog.Id;
            ann.AgencyContact__c='test contact';
            ann.Program__c=prog.Id;
            ann.EstimatedProjectPeriodStartDate__c=System.today();
            ann.EstimatedProjectPeriodEndDate__c=System.today();
            ann.OpportunityCategory__c='test';
            ann.FOALead__c=foalead.Id;
            System.debug('test class account id: '+acc.Id+' '+acc.Code__c);
            System.debug('test class user org  id: '+u.GNT__OrganizationId__c);
            preApp=TestHelper.getPreApplication(ann.Id,true);
            app = TestHelper.getApplication(ann.Id,true);
            
            Test.startTest();
            
            ApexPages.StandardController sc = new ApexPages.standardController(ann);
            ApexPages.currentPage().getParameters().put('preAppId',null);
            ApexPages.currentPage().getParameters().put('id',null);
            ApexPages.CurrentPage().getParameters().put('applicationid',app.id);
            ApexPages.CurrentPage().getParameters().put('announcementId',ann.id);
            ApplicationEditCtrl e = new ApplicationEditCtrl(sc);
            e.getKeyValueMap();
            
            Test.stopTest();
            }
            */
        }


static testMethod void test2() {
/*
        UserTriggerHelper.skipTrigger = true;
        AccountTriggerHelper.skipTrigger=true;
        ApplicationTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        Account acc=TestHelper.getAccount(true);
        u.GNT__OrganizationId__c=acc.Id;
        update u;
        acc.Code__c='UOV';
        update acc;
        Application__c app = null;
        preApplication__c preApp = null;
        Announcement__c ann = null;
        Program__c prog=null;
 
        System.runAs(u){

            ApplicationTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            FOALead__c foalead=TestHelper.getFOALead(true);
            foalead.LastUpdateDate__c=System.today();
            update foalead;
            
            Prog=Testhelper.getProgram(acc.Id,true);
            Prog.FederalProgramCFDA__c='A123';
            update Prog;
            BusinessPackage__c bp=new BusinessPackage__c();
            GNT__PageTemplate__c pt = TestHelper.getPageTemplateConfig(true);
            GNT__Package__c pack = TestHelper.getPackage(false, pt);
            pack.name='test';
            pack.GNT__SubmissionType__c = 'Application';
            pack.GNT__LatestVersion__c = true;
            pack.GNT__Status__c = 'Active';
            insert pack;
            bp.PackageConfig__c=pack.Id;
            insert bp;

            ann = TestHelper.getAnnouncement(prog.Id,true);
            ann.ApplyingAgency__c=acc.Id;
            ann.AwardingFedAgency__c=acc.Id;
            ann.AwardCeiling__c=100000;
            ann.closeDate__c=System.today();
            ann.AnnouncementNumber__c='123456';
            ann.AwardFloor__c=10000;
            ann.Budget__c=50000;
            ann.ApplicationDeadlineWithDateTime__c=System.today();
            ann.EligibilityDescription__c='test';
            ann.PreApplicationDeadline__c=System.today();
            ann.PreApplicationDeadlineWithDateTime__c=System.today();
            ann.StateProgram__c=prog.Id;
            ann.AgencyContact__c='test contact';
            ann.Program__c=prog.Id;
            ann.EstimatedProjectPeriodStartDate__c=System.today();
            ann.EstimatedProjectPeriodEndDate__c=System.today();
            ann.OpportunityCategory__c='test';
            ann.FOALead__c=foalead.Id;
            System.debug('test class account id: '+acc.Id+' '+acc.Code__c);
            System.debug('test class user org  id: '+u.GNT__OrganizationId__c);
            preApp=TestHelper.getPreApplication(ann.Id,true);
            app = TestHelper.getApplication(ann.Id,true);
            
            Test.startTest();
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee'); 
            ApexPages.StandardController sc = new ApexPages.standardController(ann);
            ApexPages.currentPage().getParameters().put('preAppId',null);
            ApexPages.currentPage().getParameters().put('id',null);
            ApexPages.CurrentPage().getParameters().put('applicationid',null);
            ApexPages.CurrentPage().getParameters().put('announcementId',ann.id);
            ApplicationEditCtrl e = new ApplicationEditCtrl(sc);
            e.getKeyValueMap();
            
            Test.stopTest();
            }
            */
        }


static testMethod void test3() {
/*
        UserTriggerHelper.skipTrigger = true;
        AccountTriggerHelper.skipTrigger=true;
        ApplicationTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        Account acc=TestHelper.getAccount(true);
        u.GNT__OrganizationId__c=acc.Id;
        update u;
        acc.Code__c='UOV';
        update acc;
        Application__c app = null;
        preApplication__c preApp = null;
        Announcement__c ann = null;
        Program__c prog=null;
 
        System.runAs(u){

            ApplicationTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            FOALead__c foalead=TestHelper.getFOALead(true);
            foalead.LastUpdateDate__c=System.today();
            update foalead;
            
            Prog=Testhelper.getProgram(acc.Id,true);
            Prog.FederalProgramCFDA__c='A123';
            update Prog;
            
            GNT__PageTemplate__c pt = TestHelper.getPageTemplateConfig(true);
            GNT__Package__c pack = TestHelper.getPackage(false, pt);
            pack.name='test';
            pack.GNT__SubmissionType__c = 'Application';
            pack.GNT__LatestVersion__c = true;
            pack.GNT__Status__c = 'Active';
            insert pack;



            ann = TestHelper.getAnnouncement(prog.Id,false);
            ann.ApplyingAgency__c=acc.Id;
            ann.AwardingFedAgency__c=acc.Id;
            ann.AwardCeiling__c=100000;
            ann.closeDate__c=System.today();
            ann.AnnouncementNumber__c='123456';
            ann.AwardFloor__c=10000;
            ann.Budget__c=50000;
            ann.ApplicationDeadlineWithDateTime__c=System.today();
            ann.EligibilityDescription__c='test';
            ann.PreApplicationDeadline__c=System.today();
            ann.PreApplicationDeadlineWithDateTime__c=System.today();
            ann.StateProgram__c=prog.Id;
            ann.AgencyContact__c='test contact';
            ann.Program__c=prog.Id;
            ann.EstimatedProjectPeriodStartDate__c=System.today();
            ann.EstimatedProjectPeriodEndDate__c=System.today().addDays(5);
            ann.OpportunityCategory__c='test';
            ann.FOALead__c=foalead.Id;
            insert ann;
            BusinessPackage__c bp=new BusinessPackage__c();
            bp.PackageConfig__c=pack.Id;
            bp.PackageType__c='Application';
            bp.FundingOpportunity__c=ann.Id;
            insert bp;
            System.debug('test class account id: '+acc.Id+' '+acc.Code__c);
            System.debug('test class user org  id: '+u.GNT__OrganizationId__c);
            preApp=TestHelper.getPreApplication(ann.Id,true);
            preApp.OpportunityNumber__c='123454';
            preApp.OpportunityTitle__c='test';
            preApp.AwardCeiling__c=10000;
            preApp.AwardFloor__c=1000;
            preApp.Budget__c=1000;
            preApp.ApplicationDeadline__c =System.today();
            preApp.GranteeTypeOfSubmission__c='Pre-Application';
            preApp.FederalAwardingAgency__c=acc.Id ;
            preApp.CFDANumber__c='112432';
            preApp.EligibilityDescription__c='TEST';
            preApp.AwardingAgencyContact__c='1747141';
            preApp.Title__c='test';
            preApp.StateProgram__c=Prog.Id;
            preApp.RequestedAmount__c=15131.11;
            preApp.FederalProgram__c=Prog.Id;
            preApp.ProjectAbstract__c='test text';
            preApp.OpportunityCategory__c='Discretionary';
            preApp.ProjectPeriodStartDate__c=System.today();
            preApp.ProjectPeriodEndDate__c=System.today().addDays(5);
            preApp.Status__c='Created';
            preApp.ProjectDirector__c=u.Id;
            update preApp;

           
            app = TestHelper.getApplication(ann.Id,true);
            
            Test.startTest();
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee'); 
            ApexPages.StandardController sc = new ApexPages.standardController(ann);
            ApexPages.currentPage().getParameters().put('preAppId',preApp.Id);
            ApexPages.currentPage().getParameters().put('id',app.Id);
           // ApexPages.CurrentPage().getParameters().put('applicationid',);
            ApexPages.CurrentPage().getParameters().put('announcementId',ann.id);
            ApplicationEditCtrl e = new ApplicationEditCtrl(sc);
            e.getKeyValueMap();
            
            Test.stopTest();
            }
            */
        }




    }