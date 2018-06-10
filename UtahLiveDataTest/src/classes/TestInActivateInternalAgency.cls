@isTest
private with sharing class TestInActivateInternalAgency{
    static testMethod void testwhenClicked() {
       /*
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
              AccountTriggerHelper.skipTrigger=true;
              Account grandParentAcc = TestHelper.getAccount(true);
              Account parentAcc = TestHelper.getAccount(false);
              parentAcc.parentId=grandParentAcc.Id;
              insert parentAcc;
              Account acct = TestHelper.getAccount(false);
              acct.parentId=parentAcc.Id;
              insert acct;
            
              Test.startTest();
              ApexPages.currentPage().getParameters().put('id',acct.id);
              InActivateInternalAgency ctrl = new InActivateInternalAgency();
              ctrl.whenClicked();
              Test.stopTest();
          }
        */
    }
    
    static testMethod void testwhenClicked2() {
       /*
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              
              GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
              AccountTriggerHelper.skipTrigger=true;
              Account grandParentAcc = TestHelper.getAccount(true);
              Account parentAcc = TestHelper.getAccount(false);
              parentAcc.parentId=grandParentAcc.Id;
              insert parentAcc;
              Account acct = TestHelper.getAccount(false);
              acct.parentId=parentAcc.Id;
              insert acct;
            
              Test.startTest();
              InActivateInternalAgency ctrl = new InActivateInternalAgency();
              ctrl.whenClicked();
              Test.stopTest();
          }
        */
    }
}