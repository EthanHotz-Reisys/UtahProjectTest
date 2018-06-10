@isTest
private with sharing class TestReviewStepApplicationEditCtrl{
    static testMethod void testController() {
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u){
        
            GrantTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationTriggerHelper.skipTrigger = true;
           
            ReviewStepApplication__c revStepApp = TestHelper.getReviewStepApplication(true);
            
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(revStepApp);
            ApexPages.currentPage().getParameters().put('Id',revStepApp.id);
            ApexPages.currentPage().getParameters().put('type','RejectedApp');
            ReviewStepApplicationEditCtrl ctrl = new ReviewStepApplicationEditCtrl(sc);
            ctrl.getKeyValueMap();
            Test.stopTest();
        
        }
        
    }
    
    static testMethod void testController2() {
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u){
        
            GrantTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            ApplicationTriggerHelper.skipTrigger = true;
           
            ReviewStepApplication__c revStepApp = TestHelper.getReviewStepApplication(true);
            
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(revStepApp);
            ApexPages.currentPage().getParameters().put('Id',revStepApp.id);
            ReviewStepApplicationEditCtrl ctrl = new ReviewStepApplicationEditCtrl(sc);
            ctrl.getKeyValueMap();
            Test.stopTest();
        
        }
        
    }
    
}