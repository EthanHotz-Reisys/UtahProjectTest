@isTest
private with sharing class TestRiskAssessmentRatingEditCtrl{
    static testMethod void testController() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u){
        
            GrantTriggerHelper.skipTrigger = true;
            RiskAssessment__c riskAssess = new RiskAssessment__c();
            insert riskAssess;
        
            Grant__c grant = TestHelper.getGrant(true);
            
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(riskAssess);
            ApexPages.currentPage().getParameters().put('Id',riskAssess.id);
            ApexPages.currentPage().getParameters().put('grantid',grant.id);
            RiskAssessmentRatingEditCtrl ctrl = new RiskAssessmentRatingEditCtrl(sc);
            ctrl.getKeyValueMap();
            Test.stopTest();
        
        }
        
    }
}