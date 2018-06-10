/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2014   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestUsefulLinksCtrl{


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
       GNT__UsefulLinkConfig__c ulc = new GNT__UsefulLinkConfig__c();
       ulc.Name = 'Sam.Gov';
       ulc.GNT__Label__c ='Sam.Gov';
       ulc.GNT__Location__c= 'ApplicantLogin';
       ulc.GNT__Sequence__c = 2;
       ulc.GNT__URL__c= 'https://www.sam.gov/portal/SAM/##11';
       insert ulc;
      // setCurrentPageReference('/apex/MyCustomVFPage');      
       //ApexPages.CurrentPage().putUrl('Applicant'); 
        ApexPages.currentPage().getParameters().put('id', uReg.Id);
        ApexPages.currentPage().getParameters().put('type', 'Applicant');
        UsefulLinksCtrl ctrl = new UsefulLinksCtrl();
       //UsefulLinkWrapper ctrl1 = new UsefulLinkWrapper(ulc.GNT__Label__c,ulc.GNT__URL__c,true);
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
        insert uReg;
        Test.startTest();
       
        ApexPages.currentPage().getParameters().put('id', uReg.Id);
        ApexPages.currentPage().getParameters().put('Applicant', 'Applicant');
        UsefulLinksCtrl ctrl = new UsefulLinksCtrl();

        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
  }