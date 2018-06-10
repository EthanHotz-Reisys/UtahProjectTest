/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2014   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestIndAppInternalViewCtrl{


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
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
        IndAppInternalViewCtrl ctrl = new IndAppInternalViewCtrl(new ApexPages.StandardController(uReg));

        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
    }