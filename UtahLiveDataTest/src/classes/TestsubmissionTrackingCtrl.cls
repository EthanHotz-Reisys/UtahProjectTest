@isTest
private with sharing class TestsubmissionTrackingCtrl{
    static testMethod void testController() {
          Account acct = null;
          User u = TestHelper.getAdminUser(true);
          
          System.runAs(u){
            GrantTriggerHelper.skipTrigger = true;
            
            SubmissionTracking__c subTrack = new SubmissionTracking__c(Comments__c='Test Case');
            insert subTrack;
           
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(subTrack);
            ApexPages.currentPage().getParameters().put('id',subTrack.id);
            SubmissionTrackingCtrl ctrl = new SubmissionTrackingCtrl(sc);
            ctrl.deleteURL = new PageReference('myPage.TestPage');
            ctrl.pageTemplateName = 'Test Template';
            ctrl.getKeyValueMap();
            Test.stopTest();
        
     }
        
    }
}