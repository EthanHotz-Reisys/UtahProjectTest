@isTest
private with sharing class TestGrantProjectAreaEditCtrl{
    static testMethod void testController() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        GrantServiceArea__c grantServArea= null;
        Grant__c grant = null;
        
     
        System.runAs(u){
            AwardTriggerHelper.skipTrigger=true;
            grant = TestHelper.getGrant(true);
            grantServArea = new GrantServiceArea__c(Grant__c=grant.Id);
            insert grantServArea;
            
        }      
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(grant);
            ApexPages.currentPage().getParameters().put('Id',grantServArea.id);
            ApexPages.currentPage().getParameters().put('grantId',grant.id);
            GrantProjectAreaEditCtrl ctrl = new GrantProjectAreaEditCtrl(sc);
            ctrl.getKeyValueMap();
            Test.stopTest();
        }
        
    }