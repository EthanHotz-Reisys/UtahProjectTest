/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2016   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestApplicantRegistrationViewCtrl{


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
         UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', uReg.Id);
        // ApexPages.currentPage().getParameters().put('tempLayout', '1');
        ApplicantRegistrationViewCtrl ctrl = new ApplicantRegistrationViewCtrl(new ApexPages.StandardController(uReg));

        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
       @IsTest(OnInstall=false)
     public static void test_ctrl1() {
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', uReg.Id);
        ApexPages.currentPage().getParameters().put('tempLayout', '1');
        ApplicantRegistrationViewCtrl ctrl = new ApplicantRegistrationViewCtrl(new ApexPages.StandardController(uReg));

        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
       @IsTest(OnInstall=false)
     public static void test_ctrl2() {
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', uReg.Id);
        ApexPages.currentPage().getParameters().put('tempLayout', '2');
        ApplicantRegistrationViewCtrl ctrl = new ApplicantRegistrationViewCtrl(new ApexPages.StandardController(uReg));

        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
    
  }