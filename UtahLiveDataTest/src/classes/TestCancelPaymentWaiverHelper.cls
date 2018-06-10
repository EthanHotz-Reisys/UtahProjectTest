@isTest
public with sharing class TestCancelPaymentWaiverHelper {
    static testMethod void testMethod0() {
		User u = TestHelper.getAdminUser(true);
		System.runAs(u){
			GrantTriggerHelper.skipTrigger = true;
			AwardTriggerHelper.skipTrigger = true;
			Grant__c grant = TestHelper.getGrant(true);
			Award__c award = TestHelper.getAwards(grant.id,true);
			PaymentRequest__c payreq = TestHelper.getPaymentRequest(false);
			payreq.Award__c = award.Id;
			insert payreq;
			
			Test.startTest();
			ApexPages.CurrentPage().getParameters().put('id',payreq.Id);
			CancelPaymentWaiverHelper ctrl = new CancelPaymentWaiverHelper();
			ctrl.whenClicked();
			Test.stopTest();
		}
	}
}