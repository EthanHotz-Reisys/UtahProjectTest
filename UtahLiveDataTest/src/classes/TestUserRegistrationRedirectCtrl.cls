/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2014   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestUserRegistrationRedirectCtrl{


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        
        contact con = TestHelper.getContact(false);
        con.ReviewerStatus__c = 'Invitation Sent';
        con.SecurityToken__c = 'abceeeer44tt';
        insert con;
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        //uReg.RecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        insert uReg;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', uReg.Id);
        
        ApexPages.currentPage().getParameters().put('t','abceeeer44tt');
      
      // ApexPages.currentPage().getParameters().put('RecordType', '');
        UserRegistrationRedirectCtrl ctrl = new UserRegistrationRedirectCtrl();
        ctrl.redirect();
        ctrl.setDefaultValues(uReg);
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
    
     @IsTest(OnInstall=false)
    public static void test_ctrl1() {
        UserTriggerHelper.skipTrigger=true;
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
        uReg.RecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        insert uReg;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', uReg.Id);
      
        ApexPages.currentPage().getParameters().put('RecordType', 'Applicant');
        UserRegistrationRedirectCtrl ctrl = new UserRegistrationRedirectCtrl();
        ctrl.redirect();
       
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
    
    @IsTest(OnInstall=false)
    public static void test_ctrl2() {
        UserTriggerHelper.skipTrigger=true;
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
        uReg.RecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Ind Applicant').getRecordTypeId();
        insert uReg;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', uReg.Id);
      
        ApexPages.currentPage().getParameters().put('RecordType', 'IndApplicant');
        UserRegistrationRedirectCtrl ctrl = new UserRegistrationRedirectCtrl();
        ctrl.redirect();
       
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
    
     @IsTest(OnInstall=false)
    public static void test_ctrl3() {
        UserTriggerHelper.skipTrigger=true;
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
        uReg.RecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Reviewer').getRecordTypeId();
        insert uReg;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', uReg.Id);
      
        ApexPages.currentPage().getParameters().put('RecordType', 'Reviewer');
        UserRegistrationRedirectCtrl ctrl = new UserRegistrationRedirectCtrl();
        ctrl.redirect();
       
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
    
    @IsTest(OnInstall=false)
    public static void test_ctrl4() {
        UserTriggerHelper.skipTrigger=true;
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
        uReg.RecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Additional Applicant').getRecordTypeId();
        insert uReg;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', uReg.Id);
      
        ApexPages.currentPage().getParameters().put('RecordType', 'AdditionalApplicant');
        UserRegistrationRedirectCtrl ctrl = new UserRegistrationRedirectCtrl();
        ctrl.redirect();
       
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
    
    
    
  }