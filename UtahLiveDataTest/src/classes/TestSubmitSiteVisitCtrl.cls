@isTest
public with sharing class TestSubmitSiteVisitCtrl {

    @isTest 
    static void plannedTest() {
        UserTriggerHelper.skipTrigger=true;
        User admin = TestHelper.getAdminUser(true);
        User suser = TestHelper.getStandardUser(true);
        System.runAs(admin) {
            GrantTriggerHelper.skipTrigger = true;
            AwardTriggerHelper.skipTrigger = true;
            RolesAndResponsibilitiesTriggerHelper.skipTrigger = true;
            AccountTriggerHelper.skipTrigger = true;
            TaskTriggerHelper.skipTrigger=true;
            SiteVisitTriggerHelper.skipTrigger = true;
        }
            SiteVisit__c sv = TestHelper.getSiteVisit(true);
            sv.Status__c = 'Planned and Submitted to Subrecipient';
            sv.GrantAdministrator__c = admin.Id;
            sv.Subawardee__c = suser.Id;
            sv.DocumentDueDate__c = System.TODAY() + 7;
        
            
        System.runAs(admin) {
            GNT__AttachmentExtension__c attach1 = new GNT__AttachmentExtension__c();
            
            attach1.GNT__Classification__c = 'Test';
            attach1.GNT__ParentId__c = sv.Id;
            insert attach1;
            attach1.OwnerId = admin.Id;
            update attach1;
        }

        System.runAs(suser) {

            GNT__AttachmentExtension__c attach2 = new GNT__AttachmentExtension__c();
            
            attach2.GNT__Classification__c = 'Test';
            attach2.GNT__ParentId__c = sv.Id;
            insert attach2;
            attach2.OwnerId = suser.Id;
            update attach2;
        }
        update sv;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('id',sv.Id);
        SubmitSiteVisitCtrl ctrl = new SubmitSiteVisitCtrl();
        ctrl.whenClicked();
        SiteVisit__c status = [SELECT Status__c from SiteVisit__c where Id =: sv.Id LIMIT 1];
        //System.assertEquals('Submitted to Grantor', status.Status__c);
        Test.stopTest();
        }
    

    @isTest 
    static void sentTest() {
        UserTriggerHelper.skipTrigger=true;
        User admin = TestHelper.getAdminUser(true);
        System.runAs(admin) {
            GrantTriggerHelper.skipTrigger = true;
            AwardTriggerHelper.skipTrigger = true;
            RolesAndResponsibilitiesTriggerHelper.skipTrigger = true;
            AccountTriggerHelper.skipTrigger = true;
            TaskTriggerHelper.skipTrigger=true;
            SiteVisitTriggerHelper.skipTrigger = true;
        
            SiteVisit__c sv = TestHelper.getSiteVisit(true);
            sv.Status__c = 'Sent to Subrecipient';
            sv.GrantAdministrator__c = admin.Id;
            sv.DocumentDueDate__c = System.TODAY() + 7;
            sv.SiteVisitName__c = 'Test Name';
            update sv;

            SiteVisitActivity__c svact = new SiteVisitActivity__c();
            
            svact.SiteVisit__c = sv.Id;
            svact.SubRecipientResponse__c = 'Test Response';
            RecordType externalRT = [select id from recordtype where name = 'External' and sobjecttype = 'SiteVisitActivity__c' limit 1];
            // uReg.RecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId(); 
            svact.RecordTypeId = externalRT.Id;
            insert svact;
            
            //svact.RecordType.Name = 'External';
            //update svact;
           // System.debug('RecordName: ' + svact.RecordType.Name);
            System.debug('TestClassObj: '+svact);

            Test.startTest();
            ApexPages.currentPage().getParameters().put('id',sv.Id);
            SubmitSiteVisitCtrl ctrl = new SubmitSiteVisitCtrl();
            ctrl.whenClicked();
            SiteVisit__c status = [SELECT Status__c from SiteVisit__c where Id =: sv.Id LIMIT 1];
            //System.assertEquals('Feedback from Subrecipient', status.Status__c);

            Test.stopTest();
        }
    }

}