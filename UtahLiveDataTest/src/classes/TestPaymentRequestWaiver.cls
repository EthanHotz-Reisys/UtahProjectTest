@isTest
private with sharing class TestPaymentRequestWaiver{

    static testMethod void testExecute() {


        User u = TestHelper.getAdminUser(true);
        PaymentRequestWaiver payreqwaiver=new PaymentRequestWaiver();  
        PaymentRequest__c payreq=TestHelper.getPaymentRequest(true); 
        payreqwaiver.selectedRecordId=payreq.ID;
        payreqwaiver.selectedAction='Approve';
        

        System.runAs(u){
            Test.startTest();  
            payreqwaiver.execute();
            payreqwaiver.selectedAction='Reject';
            payreqwaiver.execute();
            Test.stopTest();
        }

    }
    
  }