@isTest
private with sharing class TestPaymentRequestApproval{

    static testMethod void testExecute() {


        User u = TestHelper.getAdminUser(true);
        PaymentRequestApproval payreqapproval=new PaymentRequestApproval();  
        PaymentRequest__c payreq=TestHelper.getPaymentRequest(true); 
        payreqapproval.selectedRecordId=payreq.ID;
        payreqapproval.selectedAction='Approve';
        

        System.runAs(u){
            Test.startTest();  
            payreqapproval.execute();
            payreqapproval.selectedAction='Reject';
            payreqapproval.execute();
            Test.stopTest();
        }

    }
    
  }