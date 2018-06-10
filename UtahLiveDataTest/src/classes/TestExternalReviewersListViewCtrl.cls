@isTest

public with sharing class TestExternalReviewersListViewCtrl { 
    string IsActive;
    
    @isTest
    private static void IsActive(){
        UserTriggerHelper.skipTrigger = true; 
        user u = TestHelper.getAdminUser(false);
        system.runAs(u){
            ApexPages.currentPage().getParameters().put('IsActive','true');
            TestHelper.createCustomSettings(true);
            test.startTest();
            ExternalReviewersListViewCtrl ex= new ExternalReviewersListViewCtrl ();
            
            test.stopTest();
            system.assertNotEquals(null,ex.pageTitle);
            system.assertEquals('Active External Reviewers',ex.pageTitle);
        }
    }
    @isTest
    private static void IsNotActive(){
        UserTriggerHelper.skipTrigger = true; 
        user u = TestHelper.getAdminUser(false);
        system.runAs(u){
            ApexPages.currentPage().getParameters().put('IsActive','false');
            TestHelper.createCustomSettings(true);
            test.startTest();
            ExternalReviewersListViewCtrl ex= new ExternalReviewersListViewCtrl ();
            
            test.stopTest();
           system.assertNotEquals(null,ex.pageTitle);
          
        }
    }
    @isTest
    private static void testAll(){
        UserTriggerHelper.skipTrigger = true; 
        user u = TestHelper.getAdminUser(false);
        system.runAs(u){
            ApexPages.currentPage().getParameters().put('IsActive','');
            TestHelper.createCustomSettings(true);
            test.startTest();
            ExternalReviewersListViewCtrl ex= new ExternalReviewersListViewCtrl ();
            
            test.stopTest();
            system.assertNotEquals(null,ex.pageTitle);
        }
    }
}