@isTest
private with sharing class TestRiskAssessment{
    static testMethod void testController() {
    
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u){
        
            GrantTriggerHelper.skipTrigger = true;
           
            Grant__c grant = TestHelper.getGrant(false);
            grant.ProjectOfficer__c=u.Id;
            grant.GrantMonitor__c=u.Id;
            grant.GrantSupervisor__c= u.Id;
            insert grant;
   
            
            RiskAssessment__c riskAssess = new RiskAssessment__c();
            riskAssess.Grant__c =grant.Id;
            riskAssess.Status__c = 'In Progress';
            insert riskAssess;
            
            Test.startTest();
            ApexPages.currentPage().getParameters().put('grantid',grant.Id);
            RiskAssessment ctrl = new RiskAssessment();
            ctrl.redirect();
            Test.stopTest();
        
        }
        
    }
    
}