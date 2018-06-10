/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2014   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestAdditionalUserEditCtrl {


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
       
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
        AccountTriggerHelper.skipTrigger=true;
        Account acct = TestHelper.getAccount(true);
        
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        Contact con = TestHelper.getContact(true);
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', uReg.Id);
        AdditionalUserEditCtrl ctrl = new AdditionalUserEditCtrl(new ApexPages.StandardController(con));
        ctrl.getKeyValueMap();
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
        
        */
    }
    
  /*  @IsTest(OnInstall=false)
    public static void test_ctrl1() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        AccountTriggerHelper.skipAll= true;
        TestHelper.CreateCustomSettings(true);
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        Contact con = TestHelper.getContact(true);
        Test.startTest();
        Account acc = TestHelper.getAccount(false);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Recipient').getRecordTypeId();
       // string recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Reviewers').getRecordTypeId();
       insert acc;
       
        AdditionalUserEditCtrl ctrl = new AdditionalUserEditCtrl(new ApexPages.StandardController(con));

        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id); 
        
        
        }
    } */
  }