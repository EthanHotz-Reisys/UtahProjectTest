@isTest
private with sharing class TestSelectTermRecordsPopUpCtrl{
  
    static testMethod void testController() {
    /*
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          Account acct = null;
          Program__c pgm = null;
          TermCondition__c termCond = null;
          
          
          System.runAs(u){
            GrantTriggerHelper.skipTrigger = true;
            ProgramTriggerHelper.skipTrigger=true;
            AccountTriggerHelper.skipTrigger = true;
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            
            acct = TestHelper.getAccount(true);
            pgm = TestHelper.getProgram(acct.Id,true);
            termCond = TestHelper.getTermcondition(false,'Term');
            termCond.Program__c=pgm.Id;
            insert termCond;
            
            Test.startTest();
            ApexPages.currentPage().getParameters().put('parentid',pgm.id);
            ApexPages.currentPage().getParameters().put('reqType','Program');
            SelectTermRecordsPopUpCtrl ctrl = new SelectTermRecordsPopUpCtrl();
            ctrl.getKeyValueMap();
            ctrl.getListParameters();
            Test.stopTest();
            
        }
        */
    }
    
    static testMethod void testController2(){
    /*
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          Account acct = null;
          Award__c award = null;
          Grant__c grant = null;
          TermCondition__c termCond = null;
          
          
          System.runAs(u){
            GrantTriggerHelper.skipTrigger = true;
            AwardTriggerHelper.skipTrigger=true;
            AccountTriggerHelper.skipTrigger = true;
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            
            acct = TestHelper.getAccount(true);
            grant = TestHelper.getGrant(true);
            award = TestHelper.getAwards(grant.Id,true);
            termCond = TestHelper.getTermcondition(false,'Term');
            termCond.Award__c=award.Id;
            insert termCond;
            
            Test.startTest();
            ApexPages.currentPage().getParameters().put('parentid',award.id);
            ApexPages.currentPage().getParameters().put('reqType','Award');
            SelectTermRecordsPopUpCtrl ctrl = new SelectTermRecordsPopUpCtrl();
            ctrl.getKeyValueMap();
            ctrl.getListParameters();
            Test.stopTest();
            
        }
        */
    }
    
     static testMethod void testController3() {
     /*
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          Account acct = null;
          Program__c pgm = null;
          FundingSource__c fsrc = null;
          FundingAccount__c fundAcc = null;
          ProgramFundingAccount__c pgmFundAcc= null;
          TermCondition__c termCond = null;
          Award__c award = null;
          Grant__c grant = null;
          
          
          System.runAs(u){
            GrantTriggerHelper.skipTrigger = true;
            ProgramTriggerHelper.skipTrigger=true;
            AccountTriggerHelper.skipTrigger = true;
            AwardTriggerHelper.skipTrigger = true;
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            
            acct = TestHelper.getAccount(true);
            pgm = TestHelper.getProgram(acct.Id,true);
            grant = TestHelper.getGrant(false);
            grant.LatestAwardId__c='Test123';
            insert grant;
            award = TestHelper.getAwards(grant.Id,true);
            fsrc = TestHelper.getFundingSource(false);
            fsrc.Grant__c = grant.Id;
            insert fsrc;
            fundAcc = TestHelper.getFundingAccount(true,fsrc.Id);
            pgmFundAcc= new ProgramFundingAccount__c(Program__c=pgm.Id,Fundingaccount__c=fundAcc.Id);
            insert pgmFundAcc;
            
            termCond = TestHelper.getTermcondition(false,'Term');
            termCond.Program__c=pgm.Id;
            insert termCond;
            
            Test.startTest();
            ApexPages.currentPage().getParameters().put('parentid',pgm.id);
            ApexPages.currentPage().getParameters().put('reqType','Federal');
            SelectTermRecordsPopUpCtrl ctrl = new SelectTermRecordsPopUpCtrl();
            ctrl.getKeyValueMap();
            ctrl.getListParameters();
            Test.stopTest();
            
        }
      */  
    }
    
        static testMethod void testController4() {
        /*
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          Account acct = null;
          Program__c pgm = null;
          TermCondition__c termCond = null;
          
          
          System.runAs(u){
            GrantTriggerHelper.skipTrigger = true;
            ProgramTriggerHelper.skipTrigger=true;
            AccountTriggerHelper.skipTrigger = true;
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            
            acct = TestHelper.getAccount(true);
            pgm = TestHelper.getProgram(acct.Id,true);
            termCond = TestHelper.getTermcondition(false,'Term');
            termCond.Program__c=pgm.Id;
            insert termCond;
            
            Test.startTest();
            ApexPages.currentPage().getParameters().put('parentid',pgm.id);
            ApexPages.currentPage().getParameters().put('reqType','State');
            SelectTermRecordsPopUpCtrl ctrl = new SelectTermRecordsPopUpCtrl();
            ctrl.getKeyValueMap();
            ctrl.getListParameters();
            Test.stopTest();
           
        }
        
        */
        
    }
    
}