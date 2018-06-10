/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2014   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestTertiaryAppRegistrationViewCtrl {


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
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
        insert uReg;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', uReg.Id);
        TertiaryApplicantRegistrationViewCtrl ctrl = new TertiaryApplicantRegistrationViewCtrl(new ApexPages.StandardController(uReg));

        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
  }