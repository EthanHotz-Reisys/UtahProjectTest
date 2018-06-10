@isTest
private class TestSubmittoGrantorHelper {
    
    @isTest static void test_method_one() {
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        GranttriggerHelper.skipTrigger = true; 
        Contact c = TestHelper.getcontact(true);
        Grant__c grant = TestHelper.getGrant(true);
        AwardTriggerHelper.skipTrigger = true;
        AmendmentRequestTriggerHelper.skipTrigger=true;
        Award__c awd = TestHelper.getAwards(grant.Id,true);

        Id recordTypeId1 = TestHelper.getRecordType(Schema.Sobjecttype.AmendmentRequest__c,'Formal Amendments');
        AmendmentRequest__c amendmentRequest1 = new AmendmentRequest__c(RecordTypeId = recordTypeId1,
                                                                            Award__c=awd.Id,
                                                                            AmendmentContact__c=c.id,
                                                                            Purpose__c='Test Purpose',
                                                                            Impact__c='Test Impact');
        insert amendmentRequest1;
        Test.startTest();
            ApexPages.currentPage().getParameters().put('Id',amendmentRequest1.Id);
            SubmittoGrantorHelper submit2GrntrHelper = new SubmittoGrantorHelper();
            submit2GrntrHelper.whenClicked();
        Test.stopTest();
    }   
}