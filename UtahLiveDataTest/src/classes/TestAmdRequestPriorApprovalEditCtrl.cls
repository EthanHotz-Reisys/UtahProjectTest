@isTest
private class TestAmdRequestPriorApprovalEditCtrl {

    @isTest static void test() {
     
     UserTriggerHelper.skipTrigger = true;
     User u = TestHelper.getAdminUser(true);
        GranttriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger = true;
        AmendmentRequestTriggerHelper.skipTrigger = true;
        Contact c = TestHelper.getcontact(true);
        Grant__c grant = TestHelper.getGrant(true);
        AwardTriggerHelper.skipTrigger = true;
        Award__c awd = TestHelper.getAwards(grant.Id,true);

        Id recordTypeId1 = TestHelper.getRecordType(Schema.Sobjecttype.AmendmentRequest__c,'Formal Amendments');
        AmendmentRequest__c amendmentRequest1 = new AmendmentRequest__c(RecordTypeId = recordTypeId1,
                                                                        Award__c=awd.Id,
                                                                        Purpose__c='Test Purpose',
                                                                        Impact__c='Test Impact',AmendmentContact__c=c.Id,
                                                                        NoCostExtension__c=true,
                                                                        NewBudgetPeriodEndDate__c=date.newInstance(2016,12,26));
        insert amendmentRequest1;

        Test.startTest();
            ApexPages.currentPage().getParameters().put('Id',amendmentRequest1.Id);
            ApexPages.currentPage().getParameters().put('amendmentId',amendmentRequest1.Id);
            ApexPages.StandardController stdController = new ApexPages.StandardController(amendmentRequest1);
            AmendmentRequestPriorApprovalEditCtrl amendmentRequestPriorApprovalEditCtrl = 
                                                        new AmendmentRequestPriorApprovalEditCtrl(stdController);
            amendmentRequestPriorApprovalEditCtrl.getKeyValueMap();
        Test.stopTest();
    }   
}