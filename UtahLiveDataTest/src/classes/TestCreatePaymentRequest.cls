@isTest
public with sharing class TestCreatePaymentRequest {
    static testMethod void testMethod0() {
		User u = TestHelper.getAdminUser(true);
		System.runAs(u){
			AwardTriggerHelper.skipTrigger = true;
			Grant__c grant = TestHelper.getGrant(true);
			Award__c award = TestHelper.getAwards(grant.Id,true);
			
			Test.startTest();
			ApexPages.CurrentPage().getParameters().put('id',award.Id);   
			CreatePaymentRequest ctrl = new CreatePaymentRequest();
			ctrl.clickHandler();
			Test.stopTest();
		}
	}
}