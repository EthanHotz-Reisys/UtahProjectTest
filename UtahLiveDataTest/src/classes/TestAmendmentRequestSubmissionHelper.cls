/*
* Test class for AmendmentRequestSubmissionHelper 
* @author: Sarat Mahavratayajula  2016-07-05   
*/
@isTest(SeeAllData = false)
public with sharing class TestAmendmentRequestSubmissionHelper {

    @isTest 
    public static void testWhenClicked1() {
    AmendmentRequestTriggerHelper.skipTrigger = true;
    GrantTriggerHelper.skipTrigger = true;
    AwardTriggerHelper.skipTrigger = true;
    UserTriggerHelper.skipTrigger = true;
    User u = TestHelper.getAdminUser(true);
    Contact c = TestHelper.getcontact(true);
        ServiceArea__c serviceArea = TestHelper.getServiceArea(true);
        Grant__c grant = TestHelper.getGrant(true);
        AwardTriggerHelper.skipTrigger = true;
        Award__c awd = TestHelper.getAwards(grant.Id,true);

    Id recordTypeId1 = TestHelper.getRecordType(Schema.Sobjecttype.AmendmentRequest__c,'Formal Amendments');
        AmendmentRequest__c amendmentRequest1 = new AmendmentRequest__c(RecordTypeId = recordTypeId1,
                                                                        Award__c=awd.Id,
                                                                        Purpose__c='Test Purpose',
                                                                        Impact__c='Test Impact',AmendmentContact__c=c.Id,
                                                                        NoCostExtension__c=true,
                                                                        NewBudgetPeriodEndDate__c=date.newInstance(2018,12,26));
        insert amendmentRequest1;

        Id recTypeId = TestHelper.getRecordType(Schema.SObjectType.RolesAndResponsibilities__c,'Amendment Request');

        List<RolesAndResponsibilities__c> rolesandResponsibilities = new List<RolesAndResponsibilities__c>();

        RolesAndResponsibilities__c rolesAndResponsibility1 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                AmendmentRequest__c=amendmentRequest1.Id,
                                                                Name__c=u.Id,
                                                                BusinessRole__c='Program Approver');
        RolesAndResponsibilities__c rolesAndResponsibility2 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                AmendmentRequest__c=amendmentRequest1.Id,
                                                                Name__c=u.Id,
                                                                BusinessRole__c='Fiscal Approver');
        RolesAndResponsibilities__c rolesAndResponsibility3 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                AmendmentRequest__c=amendmentRequest1.Id,
                                                                Name__c=u.Id,
                                                                BusinessRole__c='Owner');

        rolesandResponsibilities.add(rolesAndResponsibility1);
        rolesandResponsibilities.add(rolesAndResponsibility2);
        rolesandResponsibilities.add(rolesAndResponsibility3);

        insert rolesandResponsibilities;
        
        ApexPages.currentPage().getParameters().put('Id',amendmentRequest1.Id);
        AmendmentRequestSubmissionHelper amendmentRequestSubmissionHelper = new AmendmentRequestSubmissionHelper();
        amendmentRequestSubmissionHelper.whenClicked();
    }

@isTest 
    public static void testWhenClicked2() {
    AmendmentRequestTriggerHelper.skipTrigger = true;
    GrantTriggerHelper.skipTrigger = true;   
    AwardTriggerHelper.skipTrigger = true; 
    UserTriggerHelper.skipTrigger = true;
    User u = TestHelper.getAdminUser(true);
    Contact c = TestHelper.getcontact(true);
        ServiceArea__c serviceArea = TestHelper.getServiceArea(true);
        Grant__c grant = TestHelper.getGrant(true);
        AwardTriggerHelper.skipTrigger = true;
        Award__c awd = TestHelper.getAwards(grant.Id,true);
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee');

        GrantContact__c awardContact = new GrantContact__c(Award__c=awd.Id,Contact__c=c.Id,Role__c='KeyPOC');
        insert awardContact;
        
        List<RolesAndResponsibilities__c> AwdrolesandResponsibilities = new List<RolesAndResponsibilities__c>();
        RolesAndResponsibilities__c AwdrolesAndResp = new RolesAndResponsibilities__c(
                                                                Award__c=awd.Id,
                                                                Name__c=u.Id,
                                                                BusinessRole__c='Owner');
        AwdrolesandResponsibilities.add(AwdrolesAndResp);
        insert AwdrolesandResponsibilities;
        
    Id recordTypeId2 = TestHelper.getRecordType(Schema.Sobjecttype.AmendmentRequest__c,'Formal Amendments');


        AmendmentRequest__c amendmentRequest2 = new AmendmentRequest__c(RecordTypeId = recordTypeId2,
                                                                        Award__c=awd.Id,
                                                                        Purpose__c='Test',
                                                                        Impact__c='Test',AmendmentContact__c=c.Id,
                                                                        NoCostExtension__c=true,
                                                                        NewBudgetPeriodEndDate__c=date.newInstance(2016,12,26));
        insert amendmentRequest2;

        AmendmentType__c amendmentType = new AmendmentType__c(Name='Fixed Price Awards',
                                                              Type__c='Prior Approval',
                                                              SubType__c='Fixed Price Awards',
                                                              Description__c='Test',
                                                              NOGARequired__c='No');
        insert amendmentType;

        AmendmentRequestPriorApproval__c amdReqPriApproval = new AmendmentRequestPriorApproval__c(AmendmentType__c=amendmentType.Id,
                                                             AmendmentRequest__c=amendmentRequest2.Id,
                                                             Justification__c='Test Justification');

        insert amdReqPriApproval;


        Id recTypeId = TestHelper.getRecordType(Schema.SObjectType.RolesAndResponsibilities__c,'Amendment Request');

        List<RolesAndResponsibilities__c> rolesandResponsibilities = new List<RolesAndResponsibilities__c>();

        RolesAndResponsibilities__c rolesAndResponsibility1 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                AmendmentRequest__c=amendmentRequest2.Id,
                                                                Name__c=u.Id,
                                                                BusinessRole__c='Program Approver');
        RolesAndResponsibilities__c rolesAndResponsibility2 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                AmendmentRequest__c=amendmentRequest2.Id,
                                                                Name__c=u.Id,
                                                                BusinessRole__c='Fiscal Approver');
        RolesAndResponsibilities__c rolesAndResponsibility3 = new RolesAndResponsibilities__c(RecordTypeId=recTypeId,
                                                                AmendmentRequest__c=amendmentRequest2.Id,
                                                                Name__c=u.Id,
                                                                BusinessRole__c='Owner');


        rolesandResponsibilities.add(rolesAndResponsibility1);
        rolesandResponsibilities.add(rolesAndResponsibility2);
        rolesandResponsibilities.add(rolesAndResponsibility3);
      
        insert rolesandResponsibilities;
        
        Attachment att = new Attachment(Name='TestAttach',Body=Blob.valueOf('Test Attachment'),ParentId=amendmentRequest2.Id);
        insert att;

        Test.startTest();

            PageReference ref = Page.amendmentrequestview;
            Test.setCurrentPage(ref);

            ApexPages.currentPage().getParameters().put('Id',amendmentRequest2.Id);

            AmendmentRequestSubmissionHelper amendmentRequestSubmissionHelper = new AmendmentRequestSubmissionHelper();
            amendmentRequestSubmissionHelper.whenClicked();
        Test.stopTest();
    }

    @isTest 
    public static void testWhenClicked3() {
        AmendmentRequestTriggerHelper.skipTrigger = true;
        GrantTriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        Contact c = TestHelper.getcontact(true);
        ServiceArea__c serviceArea = TestHelper.getServiceArea(true);
        Grant__c grant = TestHelper.getGrant(true);
        AwardTriggerHelper.skipTrigger = true;
        Award__c awd = TestHelper.getAwards(grant.Id,true);

        Id recordTypeId3 = TestHelper.getRecordType(Schema.Sobjecttype.AmendmentRequest__c,'Formal Amendments');
        
        AmendmentRequest__c amendmentRequest3 = new AmendmentRequest__c(RecordTypeId = recordTypeId3,
                                                                        Award__c=awd.Id,
                                                                        Purpose__c='Test Purpose',
                                                                        Impact__c='Test Impact',AmendmentContact__c=c.Id,
                                                                        NoCostExtension__c=false,
                                                                        Justification__c='test',
                                                                        NewBudgetPeriodEndDate__c=date.newInstance(2016,12,26));
        insert amendmentRequest3;

        Id recTypeId = TestHelper.getRecordType(Schema.SObjectType.RolesAndResponsibilities__c,'Amendment Request');
        
        ApexPages.currentPage().getParameters().put('Id',amendmentRequest3.Id);
        AmendmentRequestSubmissionHelper amendmentRequestSubmissionHelper = new AmendmentRequestSubmissionHelper();
        amendmentRequestSubmissionHelper.whenClicked();
    }

}