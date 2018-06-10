@isTest
private with sharing class TestRiskAssessmentAction{
    static testMethod void testController() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u){
        
            GrantTriggerHelper.skipTrigger = true;
            GNT.KeyValueStoreHelper.setTextValue('RiskAssessmentActionStatus','In Progress,To Be Reviewed',true);
            Grant__c grant = TestHelper.getGrant(false);
            grant.ProjectOfficer__c=u.Id;
            grant.GrantMonitor__c=u.Id;
            insert grant;
            
            RiskAssessment__c riskAssess = new RiskAssessment__c();
            riskAssess.Grant__c =grant.Id;
            riskAssess.Status__c = 'In Progress';
            insert riskAssess;
            
            Test.startTest();
            RiskAssessmentAction ctrl = new RiskAssessmentAction();
            ctrl.urlParams.put('id',grant.Id);
            ctrl.clickHandler();
            riskAssess.Status__c='Completed';
            update riskAssess;
            ctrl.clickHandler();
            Test.stopTest();
        
        }
        
    }
    
      static testMethod void testController2() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u){
        
            GrantTriggerHelper.skipTrigger = true;
            GNT.KeyValueStoreHelper.setTextValue('RiskAssessmentActionStatus','In Progress,To Be Reviewed',true);
            Grant__c grant = TestHelper.getGrant(true);

            RiskAssessment__c riskAssess = new RiskAssessment__c();
            riskAssess.Grant__c =grant.Id;
            riskAssess.Status__c = 'In Progress';
            insert riskAssess;
            
            Test.startTest();
            RiskAssessmentAction ctrl = new RiskAssessmentAction();
            ctrl.urlParams.put('id',grant.Id);
            ctrl.clickHandler();
            Test.stopTest();
        
        }
        
    }
}