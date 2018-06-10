/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2014   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestApplicantRegistrationPage2Ctrl {


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
    
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        UserTriggerHelper.skipTrigger = true;
        
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        uReg.RecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        uReg.OrganizationStreetAddress__c = '1400 S St';
        uReg.OrganizationCityAddress__c = 'Arlington';
        uReg.OrganizationState__c = 'VA';
        //uReg.RecordType.DeveloperName = 'Applicant';
        insert uReg;
        CommunityRegistrationConfig__c cr = new CommunityRegistrationConfig__c();
        cr.UserType__c = 'Applicant';
        insert cr;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', uReg.Id);
        ApexPages.currentPage().getParameters().put('type', 'Applicant');
        ApexPages.currentPage().getParameters().put('isReviewer', 'false');
        ApexPages.CurrentPage().getParameters().put('selectedOrgId',uReg.id);
       /* GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='AllowedExternalUsersPerOrganisation',
                                                GNT__IntegerValue__c=3,
                                                GNT__BooleanValue__c=true,
                                                GNT__Admin_Question__c = 'Loren Ipsum',
                                                GNT__Description__c='Email address to send feedback of the customer in real time');
        insert key; */
        //GNT.KeyValueStoreHelper.setIntegerValue('AllowedExternalUsersPerOrganisation',3,true);
        GNT__KeyValueStore__c key1= new GNT__KeyValueStore__c(Name='NewUserRegStartDate',GNT__DateValue__c=System.today(),GNT__BooleanValue__c=true,GNT__Description__c='NewUserRegStartDate',GNT__Admin_Question__c = 'Loren Ipsum');                          
        GNT__KeyValueStore__c key2= new GNT__KeyValueStore__c(Name='NewUserRegEndDate',GNT__DateValue__c=System.today(),GNT__BooleanValue__c=true,GNT__Description__c='NewUserRegEndDate',GNT__Admin_Question__c = 'Loren Ipsum');      
        insert key1;
        insert key2;                    

        ApplicantRegistrationPage2Ctrl ctrl = new ApplicantRegistrationPage2Ctrl(new ApexPages.StandardController(uReg));
        ctrl.fetchOrgnizations(); 
        ctrl.getLoginValidationtype();
        ctrl.redirectPage();
        ctrl.getApplicantTypes();
        ctrl.CreateOrganization();
        ctrl.getAdminApprovalRequired();
        ctrl.checkOrganizations();
        ctrl.applySelectedFlags();
        ctrl.saveUserRegistrationEntry();
        ctrl.showContactInfo();
        ctrl.showOrgCreateInfo();
        ctrl.checkIfAccountIsMissingRequiredFields();
        ctrl.showContactInfoWithOrgSelected();
        ctrl.showOrgCreateInfoResetEIN();
        ctrl.backFromConfirmOrganization();
        ctrl.backFromCreateOrganization();
        ctrl.backFromCreateUser();
        ctrl.showCaptchaInfo();
        ctrl.cancelPage();
        ctrl.copyAddress();
        ctrl.showSearchOrgnizations();
        ctrl.resetSearchCriteria();
       
        
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
         UserTriggerHelper.skipTrigger = true;
         
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        uReg.RecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Ind Applicant').getRecordTypeId();
        //uReg.RecordType.DeveloperName = 'Applicant';
        insert uReg;
        CommunityRegistrationConfig__c cr = new CommunityRegistrationConfig__c();
        cr.UserType__c = 'Ind Applicant';
        insert cr;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', uReg.Id);
        ApexPages.currentPage().getParameters().put('type', 'Ind Applicant');
        ApexPages.CurrentPage().getParameters().put('selectedOrgId',uReg.id);
        //GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='AllowedExternalUsersPerOrganisation',GNT__IntegerValue__c=3,true);
        //GNT.KeyValueStoreHelper.setIntegerValue('AllowedExternalUsersPerOrganisation',3,true);
        ApplicantRegistrationPage2Ctrl ctrl = new ApplicantRegistrationPage2Ctrl(new ApexPages.StandardController(uReg));
        ctrl.fetchOrgnizationsInd(); 

       
        
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }


    @IsTest(OnInstall=false)
    public static void test_ctrl3() {
    
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        UserTriggerHelper.skipTrigger = true;
        
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        uReg.RecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Ind Applicant').getRecordTypeId();
        //uReg.RecordType.DeveloperName = 'Applicant';
        insert uReg;
        CommunityRegistrationConfig__c cr = new CommunityRegistrationConfig__c();
        cr.UserType__c = 'Ind Applicant';
        insert cr;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', uReg.Id);
        ApexPages.currentPage().getParameters().put('type', 'Ind Applicant');
        ApexPages.CurrentPage().getParameters().put('selectedOrgId',uReg.id);
        //GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='AllowedExternalUsersPerOrganisation',GNT__IntegerValue__c=3,true);
        //GNT.KeyValueStoreHelper.setIntegerValue('AllowedExternalUsersPerOrganisation',3,true);
        ApplicantRegistrationPage2Ctrl ctrl = new ApplicantRegistrationPage2Ctrl(new ApexPages.StandardController(uReg));
        CommunityRegistrationConfigDetail__c communityRegistrationConfigDetail = new CommunityRegistrationConfigDetail__c(Name='test');
       // insert communityRegistrationConfigDetail;
        ApplicantRegistrationPage2Ctrl.CommunityRegistrationConfigDetailWrapper communityRegistrationWrapper =new ApplicantRegistrationPage2Ctrl.CommunityRegistrationConfigDetailWrapper(communityRegistrationConfigDetail);        
        communityRegistrationWrapper.compareTo(communityRegistrationWrapper);
        ctrl.getValidCountries();  
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }

  }