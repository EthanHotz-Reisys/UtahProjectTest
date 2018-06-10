@isTest
public class TestPaymentRequestEditCtrl{
    static testMethod void someTest() {
    
        User u = TestHelper.getAdminUser(true);
        PaymentRequest__c payReq = null;
        Grant__c grant = null;
        Award__c awards = null;
        
        System.runAs(u){
        
            GrantTriggerHelper.skipTrigger = true;
            AwardTriggerHelper.skipTrigger = true;
            payReq = TestHelper.getPaymentRequest(true);
            payReq.Status__c = 'Approved by Program Manager';
            update payReq;
            grant = TestHelper.getGrant(true);
            awards = TestHelper.getAwards(grant.Id,true);
        }
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(payReq);
        ApexPages.currentPage().getParameters().put('id',payReq.id);
        ApexPages.CurrentPage().getParameters().put('grantId',grant.id);
        ApexPages.CurrentPage().getParameters().put('awardId',awards.id);
        PaymentRequestEditCtrl e = new PaymentRequestEditCtrl(sc);
        e.getKeyValueMap();
        e.redirect();
        Test.stopTest();
    }
}