@isTest(SeeAllData=true)
private class TestPaymentSubmissionHelper {

    static testMethod void myUnitTest() {
        
        User u = TestHelper.getAdminUser(true);
        User u1 =TestHelper.getAdminUser(true); 
        PaymentRequest__c pmntreq = null;
        System.runAs(u){
            pmntreq = TestHelper.getPaymentRequest(false);
            pmntreq.approver__c = u1.Id;
            pmntreq.Title__c = 'Test';
            insert pmntreq;
            Attachment att = new Attachment(Name = 'paymentreq.pdf',Parentid = pmntreq.id,Body= Blob.valueOf('xyz'));
            insert att;
            Test.setCurrentPageReference(new PageReference('Page.PaymentRequestView'));        
        }
        
        Test.startTest();
        PaymentSubmissionHelper pmntHelper = new PaymentSubmissionHelper();
        ApexPages.currentPage().getParameters().put('id', pmntreq.Id);
        pmntHelper.whenClicked();
        Test.stopTest();
    
    }
}