@isTest
private with sharing class TestReviewStepApplicationAmountCtrl{
    static testMethod void testController() {
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u){
        
            GrantTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationTriggerHelper.skipTrigger = true;
           
            ReviewStepApplication__c revStepApp = TestHelper.getReviewStepApplication(true);
            
            Test.startTest();
            ApexPages.currentPage().getParameters().put('Id',revStepApp.id);
            ReviewStepApplicationAmountCtrl ctrl = new ReviewStepApplicationAmountCtrl();
            Test.stopTest();
        
        }
        
    }
    
}