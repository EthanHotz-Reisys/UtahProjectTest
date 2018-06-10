@isTest
private with sharing class TestActivateInternalAgency{
    static testMethod void testWhenClicked() {
    
    /*
          Account acct = null;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          
           
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            AccountTriggerHelper.skipTrigger=true;
            Account grandParentAccount = TestHelper.getAccount(true);
            Account parentAccount = TestHelper.getAccount(false);
            parentAccount.Status__c = 'New';
            parentAccount.ParentId = grandParentAccount.Id;
            insert parentAccount;
            Contact ct = TestHelper.getContact(false);
            ct.AccountId=parentAccount.Id;
            insert ct;
            acct = TestHelper.getAccount(false);
            acct.Status__c='Active';
            acct.parentId = parentAccount.Id;
            insert acct;
            Contact ct2 = new Contact(Firstname='Test1', Lastname='Test2',Email='test@email.com', Title='TestTitle',Phone ='123-456-7890');
            ct2.AccountId=acct.Id;
            insert ct2;
             

             
            Test.startTest();
            ApexPages.currentPage().getParameters().put('Id',acct.id);
            ActivateInternalAgency ctrl = new ActivateInternalAgency();
            ctrl.whenClicked();
            delete ct;
            delete ct2;
            ctrl.whenClicked();
            delete acct;
            ctrl.whenClicked();
            Test.stopTest();
        
        }
        */
    }
    
}