@isTest
public with sharing class TestPayPaymentRequestHelper {
    static testMethod void testMethod0() {
		User u = TestHelper.getAdminUser(true);
		System.runAs(u){
			PaymentRequest__c payreq = TestHelper.getPaymentRequest(false);
			payreq.Status__c = 'Approved';
			insert payreq;
			
			Test.startTest();
			ApexPages.CurrentPage().getParameters().put('id',payreq.Id);   
			PayPaymentRequestHelper ctrl = new PayPaymentRequestHelper();
			ctrl.whenClicked();
			Test.stopTest();
		}
	}
}