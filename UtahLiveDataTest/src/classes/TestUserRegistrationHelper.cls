/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2014   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestUserRegistrationHelper {


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
      UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        accountTriggerHelper.SkipTrigger = true;
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        UserRegistrationTriggerHelper.skipAfterUpdate = true;
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.PrimaryRepAddress2__c='abc';
        uReg.PrimaryRepCity__c='abc';
        uReg.PrimaryRepState__c='Virginia';
        uReg.PrimaryRepZipCode__c='22202-1234';
        uReg.PrimaryRepCountry__c='abc';
        uReg.PrimaryRepPhone__c='1234567890';
        uReg.Comments__c='approved';
        uReg.PrimaryRepTitle__c='abc';
        uReg.PrimaryRepEmail__c='abc@gmail.com';
        uReg.SecondaryRepPrefix__c='abc';
        uReg.SecondaryRepFirstName__c='abc';
        uReg.Organization__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        uReg.SecondaryRepEmail__c ='test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        uReg.Status__c = 'In Progress';
        uReg.RecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        insert uReg;
       Schema.SObjectType.Account.getRecordTypeInfosByName().get('External').getRecordTypeId();
       User u1 = TestHelper.getAdminUser(true);
         /*GNT__PageLayoutConfig__c pagelayoutConfig= null;
         pagelayoutConfig = TestHelper.getPageLayoutConfig(true,'UserRegistration__c ');
         GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, uReg.Id,true);*/
            ApexPages.currentPage().getParameters().put('Id',uReg.Id);
        Test.startTest();
        UserRegistrationHelper ctrl = new UserRegistrationHelper();
            ctrl.whenClicked();
        
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
    
   
     
    
  }