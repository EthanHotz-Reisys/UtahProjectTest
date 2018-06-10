@isTest
private with sharing class TestGrantContactEditCtrl{
    static testMethod void testController() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantee');
        Award__c award = null;
        Grant__c grant = null;
        GrantContact__c grantContact = null;
        
     
        System.runAs(u){
            GrantTriggerHelper.skipTrigger = true;
            AwardTriggerHelper.skipTrigger = true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            AccountTriggerHelper.skipTrigger=true;
            
            
            grant = TestHelper.getGrant(true);
            award= TestHelper.getAwards(grant.Id,true);
            grantContact = new GrantContact__c(Award__c=award.Id);
            insert grantContact;
            
        }      
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(grant);
            ApexPages.currentPage().getParameters().put('id',grantContact.id);
            ApexPages.currentPage().getParameters().put('awardId',award.id);
            GrantContactEditCtrl ctrl = new GrantContactEditCtrl(sc);
            ctrl.getKeyValueMap();
            Test.stopTest();
        }
        
        
        static testMethod void testController2() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
        Award__c award = null;
        Grant__c grant = null;
        GrantContact__c grantContact = null;
        
     
        System.runAs(u){
            GrantTriggerHelper.skipTrigger= true;
            AwardTriggerHelper.skipTrigger = true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            AccountTriggerHelper.skipTrigger=true;
            
            grant = TestHelper.getGrant(true);
            award= TestHelper.getAwards(grant.Id,true);
            grantContact = new GrantContact__c(Award__c=award.Id);
            insert grantContact;
            
        }      
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(grant);
            ApexPages.currentPage().getParameters().put('id',grantContact.id);
            ApexPages.currentPage().getParameters().put('awardId',award.id);
            GrantContactEditCtrl ctrl = new GrantContactEditCtrl(sc);
            ctrl.getKeyValueMap();
            Test.stopTest();
        }
    }