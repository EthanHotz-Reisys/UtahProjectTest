@isTest
private with sharing class TestBudgetRevisionApproval{

    static testMethod void testExecute() {

        AmendmentRequestTriggerHelper.skipTrigger=true;
        USBEAnnouncementTriggerHelper.skipTrigger=true;
        ApplicationTriggerHelperUSBE.skipTrigger=true;
        ApplicationTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        
        AmendmentRequest__c amendreq=new AmendmentRequest__c();
        amendreq.impact__c='test';
        amendreq.purpose__c='test';
        insert amendreq;

        BudgetRevisionApproval budrevapproval=new BudgetRevisionApproval();  
       budrevapproval.selectedRecordId=amendreq.ID;
        budrevapproval.selectedAction='Approve';
       

        System.runAs(u){
            Test.startTest();  
            budrevapproval.execute();
            budrevapproval.selectedAction='Reject';
            budrevapproval.execute();
            Test.stopTest();
        }

    }
    
  }