@isTest
private with sharing class TestReviewPanelRedirectCtrl{
    static testMethod void testforwardToReviewPanel() {
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            AccountTriggerHelper.skipTrigger=true;
            AnnouncementTriggerHelper.skipTrigger = true;
            ProgramTriggerHelper.skipTrigger = true;
     
            ReviewStep__c revStep = TestHelper.getReviewStep(true);
            
            Test.startTest();
            ApexPages.currentPage().getParameters().put('name','Step 1');
            ReviewPanelRedirectCtrl ctrl = new ReviewPanelRedirectCtrl();
            ctrl.forwardToReviewPanel();
            Test.stopTest();
        
         }
    }
}