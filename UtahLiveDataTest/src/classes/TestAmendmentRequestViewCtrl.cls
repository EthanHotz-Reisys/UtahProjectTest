@isTest
public class TestAmendmentRequestViewCtrl {
    @isTest
    public static void testConstructor() {
        
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        GranttriggerHelper.skipTrigger = true;
        Contact c = TestHelper.getcontact(true);
        Grant__c grant = TestHelper.getGrant(true);
        AwardTriggerHelper.skipTrigger = true;
        Award__c awd = TestHelper.getAwards(grant.Id,true);
        AmendmentRequestTriggerHelper.skipTrigger = true;

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
            ApexPages.currentPage().getParameters().put('parentId',grant.Id);
            ApexPages.StandardController stdController = new ApexPages.StandardController(amendmentRequest1);
            AmendmentRequestViewCtrl amendmentRequestViewCtrl = new AmendmentRequestViewCtrl(stdController);
            amendmentRequestViewCtrl.getKeyValueMap();
        Test.stopTest();        
    }
}