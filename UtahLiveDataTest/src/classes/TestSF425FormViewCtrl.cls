@isTest
private with sharing class TestSF425FormViewCtrl{
    static testMethod void testController() {
    /*
          Account acct = null;
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          
          System.runAs(u){
            GrantTriggerHelper.skipTrigger = true;
            AwardTriggerHelper.skipTrigger = true;
            AccountTriggerHelper.skipTrigger = true;
            
            Grant__c grant = TestHelper.getGrant(true);
            Award__c award = TestHelper.getAwards(grant.Id,true);
            TermCondition__c termCond = TestHelper.getTermCondition(true,'Progress Report');
            ProgressReports__c progRep = new ProgressReports__c(Award__c = award.Id, TermandCondition__c=termCond.Id);
            insert progRep;
            
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(progRep);
            ApexPages.currentPage().getParameters().put('Id',progRep.id);
            SF425FormViewCtrl ctrl = new SF425FormviewCtrl(sc);
            ctrl.getKeyValueMap(); 
            Test.stopTest();
        
         }
        */
    }
    
}