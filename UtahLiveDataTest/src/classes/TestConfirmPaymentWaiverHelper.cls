@isTest
public with sharing class TestConfirmPaymentWaiverHelper {
    static testMethod void testMethod0() {
		User u = TestHelper.getAdminUser(true);
		System.runAs(u){
			PaymentRequest__c payreq = TestHelper.getPaymentRequest(true);
			
			Test.startTest();
			ApexPages.CurrentPage().getParameters().put('id',payreq.Id);
			ConfirmPaymentWaiverHelper ctrl = new ConfirmPaymentWaiverHelper();
			ctrl.whenClicked();
			Test.stopTest();
		}
	}
}