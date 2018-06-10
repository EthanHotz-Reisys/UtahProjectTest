@isTest
public with sharing class TestCreatePaymentWaiver {
    static testMethod void testMethod0() {
		User u = TestHelper.getAdminUser(true);
		System.runAs(u){
			AwardTriggerHelper.skipTrigger = true;
			Grant__c grant = TestHelper.getGrant(true);
			Award__c award = TestHelper.getAwards(grant.id,true);
			
			Test.startTest();
			ApexPages.CurrentPage().getParameters().put('id',award.Id);
			CreatePaymentWaiver ctrl = new CreatePaymentWaiver();
			ctrl.clickHandler();
			Test.stopTest();
		}
	}
}