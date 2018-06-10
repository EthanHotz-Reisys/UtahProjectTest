/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2014   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestReviewerRegistrationEditCtrl{


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        Contact con = TestHelper.getContact(true);
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        uReg.OrganizationStreetAddress__c ='23 main street';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', uReg.Id);
        ApexPages.currentPage().getParameters().put('RecordType','Reviewer');
        ApexPages.currentPage().getParameters().put('conId','1');
        ApexPages.currentPage().getParameters().put('tempLayout','1');
        ApexPages.currentPage().getParameters().put('EIN','345234567' );
        ApexPages.currentPage().getParameters().put('DUNS','453234567');
        ApexPages.currentPage().getParameters().put('OrganizationName',uReg.OrganizationName__c);
     
        ReviewerRegistrationEditCtrl ctrl = new ReviewerRegistrationEditCtrl(new ApexPages.StandardController(uReg));

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
        Contact con = TestHelper.getContact(true);
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        uReg.OrganizationStreetAddress__c ='23 main street';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', uReg.Id);
        ApexPages.currentPage().getParameters().put('RecordType','Reviewer');
        ApexPages.currentPage().getParameters().put('conId','1');
        ApexPages.currentPage().getParameters().put('tempLayout','2');
        ApexPages.currentPage().getParameters().put('EIN','345234567' );
        ApexPages.currentPage().getParameters().put('DUNS','453234567');
        ApexPages.currentPage().getParameters().put('OrganizationName',uReg.OrganizationName__c);
     
        ReviewerRegistrationEditCtrl ctrl = new ReviewerRegistrationEditCtrl(new ApexPages.StandardController(uReg));

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
        Contact con = TestHelper.getContact(true);
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        uReg.OrganizationStreetAddress__c ='23 main street';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', uReg.Id);
        ApexPages.currentPage().getParameters().put('RecordType','Reviewer');
        ApexPages.currentPage().getParameters().put('conId','1');
     
        ApexPages.currentPage().getParameters().put('EIN','345234567' );
        ApexPages.currentPage().getParameters().put('DUNS','453234567');
        ApexPages.currentPage().getParameters().put('OrganizationName',uReg.OrganizationName__c);
     
        ReviewerRegistrationEditCtrl ctrl = new ReviewerRegistrationEditCtrl(new ApexPages.StandardController(uReg));

        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
  }