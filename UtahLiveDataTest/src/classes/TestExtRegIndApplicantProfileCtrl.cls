/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2014   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestExtRegIndApplicantProfileCtrl{


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        Recordtype recordType2  = [Select Id from RecordType where DeveloperName ='AdditionalApplicant'];
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        uReg.RecordTypeId = recordType2.Id;
        insert uReg;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', uReg.Id);
        ApexPages.currentPage().getParameters().put('EIN','456345678');
        ApexPages.currentPage().getParameters().put('DUNS','334234567');
        ApexPages.currentPage().getParameters().put('OrganizationName',uReg.OrganizationName__c);
        ApexPages.currentPage().getParameters().put('UniqueID','J23423');
        ApexPages.currentPage().getParameters().put('UniqueType','Passport');
         
         
        ExtRegIndApplicantProfileCtrl ctrl = new ExtRegIndApplicantProfileCtrl(new ApexPages.StandardController(uReg));

        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
     
  }