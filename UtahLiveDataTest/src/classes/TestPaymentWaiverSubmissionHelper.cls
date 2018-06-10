@isTest
public with sharing class TestPaymentWaiverSubmissionHelper {
    static testMethod void testMethod0() {
		User u = TestHelper.getAdminUser(true);
		System.runAs(u){
			GrantTriggerHelper.skipTrigger = true;
			AwardTriggerHelper.skipTrigger = true;
			Grant__c grant = TestHelper.getGrant(true);
			Award__c award = TestHelper.getAwards(grant.id,true);
			PaymentRequest__c payreq = TestHelper.getPaymentRequest(false);
			payreq.Award__c = award.Id;
			payreq.Name = 'Test';
			payreq.Title__c = 'Test';
			insert payreq;
			Attachment att = TestHelper.getAttachment(payreq.Id,true);
			GNT__TaskConfig__c task = TestHelper.getTaskConfig('Review Payment Waiver',true);
			
			Test.startTest();
			ApexPages.CurrentPage().getParameters().put('id',payreq.Id);
			PaymentWaiverSubmissionHelper ctrl = new PaymentWaiverSubmissionHelper();
			ctrl.whenClicked();
			Test.stopTest();
		}
	}
}