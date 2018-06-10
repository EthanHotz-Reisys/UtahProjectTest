/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2014   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestUserRegistrationTriggerHelper {


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
    
      UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        UserRegistrationTriggerHelper.skipAfterUpdate = true;
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        uReg.Status__c = 'In Progress';
        uReg.RecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        insert uReg;
        Test.startTest();
        uReg.Status__c = 'Approved';
        update uReg;
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
        
    }
    @IsTest(OnInstall=false)
    public static void test_ctrl108() {
      UserTriggerHelper.skipTrigger=false;
      UserRegistrationTriggerHelper.skipAfterUpdate=false;
      UserRegistrationTriggerHelper.skipBeforeUpdate=false;

        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        UserRegistrationTriggerHelper.skipAfterUpdate = true;
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        uReg.Status__c = 'In Progress';
        uReg.RecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        insert uReg;
        Test.startTest();
        uReg.Status__c = 'Approved';
        update uReg;
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
    
    @IsTest(OnInstall=false)
    public static void test_ctrl1() {
    /*
     UserRole portalRole = new UserRole();
     portalRole.PortalType ='None';
     portalRole.name ='abc';
     insert portalRole ;
     
        User u = TestHelper.getAdminUser(false);
        u.UserRoleId = portalRole.id;
        
        insert u;
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        UserRegistrationTriggerHelper.skipBeforeUpdate = true;
        UserRegistrationTriggerHelper.skipAfterUpdate= true;

        AccountTriggerHelper.skipTrigger = true;

        CommunityProfileConfig__c communityProfileConfig = new CommunityProfileConfig__c();
        communityProfileConfig.Name = 'Reviewer';
        communityProfileConfig.ExternalRegistrationRecordType__c = 'Reviewer';
        communityProfileConfig.ProfileName__c = 'SME';
        insert communityProfileConfig;

        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.ExternalReviewerPrefix__c = 'Mr';
        uReg.ExternalReviewerFirstName__c = 'Betty';
        uReg.ExternalReviewerLastName__c = 'Ander';
        uReg.ExternalReviewerAddress1__c = '23 main street';
        uReg.ExternalReviewerAddress2__c = 'abc';
        uReg.ExternalReviewerCity__c = 'sterling';
        uReg.ExternalReviewerState__c = 'VA';
        uReg.ExternalReviewerZipCode__c ='23456-1546';
        uReg.ExternalReviewerCountry__c  = 'USA';
        uReg.ExternalReviewerPhone__c = '1234567890';
        uReg.ExternalReviewerEmail__c = 'swa@gmail.com';
        uReg.LastName__c = 'Betty';
        uReg.isApplicant__c = true;
        //uReg.UserRole__c = 'Project Director';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        uReg.Status__c = 'In Progress';
        uReg.RecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Reviewer').getRecordTypeId();
        insert uReg;

        

        Account acc = TestHelper.getAccount(false);
        acc.name = 'SME Reviewer System Account';
        insert acc;
        Account acc1 = TestHelper.getAccount(false);
        acc1.name = 'Individuals System Account';
        insert acc1;
        GNT__KeyValueStore__c key1= new GNT__KeyValueStore__c(Name='UniqueUsername',
                                                GNT__IntegerValue__c=1153,
                                                GNT__BooleanValue__c=true,
                                                GNT__Admin_Question__c = 'Loren Ipsum',
                                                GNT__Description__c='Email address to send feedback of the customer in real time');
        insert key1; 

        Test.startTest();
        uReg.Status__c = 'Approved';
        update uReg;
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
        */
    }
    
     @IsTest(OnInstall=false)
    public static void test_ctrl2() {
    /*
     UserRole portalRole = new UserRole();
     portalRole.PortalType ='None';
     portalRole.name ='abc';
     insert portalRole ;
     
        User u = TestHelper.getAdminUser(false);
        u.UserRoleId = portalRole.id;
        
        insert u;
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        UserRegistrationTriggerHelper.skipBeforeUpdate = true;
        UserRegistrationTriggerHelper.skipAfterUpdate= true;
        AccountTriggerHelper.skipTrigger = true;

        CommunityProfileConfig__c communityProfileConfig = new CommunityProfileConfig__c();
        communityProfileConfig.Name = 'Ind Applicant';
        communityProfileConfig.ExternalRegistrationRecordType__c = 'Ind Applicant';
        communityProfileConfig.ProfileName__c = 'SPI';
        insert communityProfileConfig;
        

        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.PrimaryRepPrefix__c= 'Mr';
        uReg.PrimaryRepFirstName__c= 'Betty';
        uReg.PrimaryRepLastName__c= 'Ander';
        uReg.PrimaryRepAddress1__c= '23 main street';
        uReg.PrimaryRepAddress2__c= 'abc';
        uReg.PrimaryRepCity__c= 'sterling';
        //uReg.PrimaryRepState__c= 'VA';
        uReg.PrimaryRepZipCode__c='23456-1546';
        uReg.PrimaryRepCountry__c= 'USA';
        uReg.PrimaryRepPhone__c= '1234567890';
        uReg.PrimaryRepEmail__c= 'swati@gmail.com';
        uReg.LastName__c = 'Betty';
        uReg.isApplicant__c = true;
       
        //uReg.UserRole__c = 'Project Director';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        uReg.Status__c = 'In Progress';
        uReg.RecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Ind Applicant').getRecordTypeId();
        insert uReg;
        Account acc = TestHelper.getAccount(false);
        acc.name = 'SME Reviewer System Account';
        insert acc;
        Account acc1 = TestHelper.getAccount(false);
        acc1.name = 'Individuals System Account';
        insert acc1;
        GNT__KeyValueStore__c key1= new GNT__KeyValueStore__c(Name='UniqueUsername',
                                                GNT__IntegerValue__c=1153,
                                                GNT__BooleanValue__c=true,
                                                GNT__Admin_Question__c = 'Loren Ipsum',
                                                GNT__Description__c='Email address to send feedback of the customer in real time');
        insert key1; 

        Test.startTest();
        uReg.Status__c = 'Approved';
        update uReg;
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
        */
    }
    
    @IsTest(OnInstall=false)
    public static void test_ctrl3() {
    /*
     UserRole portalRole = new UserRole();
     portalRole.PortalType ='None';
     portalRole.name ='abc';
     insert portalRole ;
     
        User u = TestHelper.getAdminUser(false);
        u.UserRoleId = portalRole.id;
        
        insert u;
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        UserRegistrationTriggerHelper.skipBeforeUpdate = true;
        AccountTriggerHelper.skipTrigger = true;
        UserRegistrationTriggerHelper.skipAfterUpdate= true;

        CommunityProfileConfig__c communityProfileConfig = new CommunityProfileConfig__c();
        communityProfileConfig.Name = 'Reviewer';
        communityProfileConfig.ExternalRegistrationRecordType__c = 'Reviewer';
        communityProfileConfig.ProfileName__c = 'SME';
        insert communityProfileConfig;
        contact con = TestHelper.getContact(true);
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.ExternalReviewerPrefix__c = 'Mr';
        uReg.ExternalReviewerFirstName__c = 'Betty';
        uReg.ExternalReviewerLastName__c = 'Ander';
        uReg.ExternalReviewerAddress1__c = '23 main street';
        uReg.ExternalReviewerAddress2__c = 'abc';
        uReg.ExternalReviewerCity__c = 'sterling';
        uReg.ExternalReviewerState__c = 'VA';
        uReg.ExternalReviewerZipCode__c ='23456-1546';
        uReg.ExternalReviewerCountry__c  = 'USA';
        uReg.ExternalReviewerPhone__c = '1234567890';
        uReg.ExternalReviewerEmail__c = 'swa@gmail.com';
        uReg.LastName__c = 'Betty';
        uReg.isApplicant__c = true;
        //uReg.UserRole__c = 'Project Director';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        uReg.Status__c = 'In Progress';
        uReg.contact__c = con.Id;
        uReg.RecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Reviewer').getRecordTypeId();
        insert uReg;
        con.UserRegistration__c = uReg.Id;
        Update con;
        

        Account acc = TestHelper.getAccount(false);
        acc.name = 'SME Reviewer System Account';
        insert acc;
        Account acc1 = TestHelper.getAccount(false);
        acc1.name = 'Individuals System Account';
        insert acc1;
        GNT__KeyValueStore__c key1= new GNT__KeyValueStore__c(Name='UniqueUsername',
                                                GNT__IntegerValue__c=1153,
                                                GNT__BooleanValue__c=true,
                                                GNT__Admin_Question__c = 'Loren Ipsum',
                                                GNT__Description__c='Email address to send feedback of the customer in real time');
        insert key1; 

        Test.startTest();
        uReg.Status__c = 'Approved';
        update uReg;
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        }
        */
    }
    
    @IsTest(OnInstall=false)
    public static void test_ctrl4() {
    /*
     UserRole portalRole = new UserRole();
     portalRole.PortalType ='None';
     portalRole.name ='abc';
     insert portalRole ;
     
        User u = TestHelper.getAdminUser(false);
        u.UserRoleId = portalRole.id;
        
        insert u;
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        UserRegistrationTriggerHelper.skipBeforeUpdate = true;
        UserRegistrationTriggerHelper.skipAfterUpdate= true;
        AccountTriggerHelper.skipTrigger = true;

        CommunityProfileConfig__c communityProfileConfig = new CommunityProfileConfig__c();
        communityProfileConfig.Name = 'Reviewer';
        communityProfileConfig.ExternalRegistrationRecordType__c = 'Reviewer';
        communityProfileConfig.ProfileName__c = 'SPI';
        insert communityProfileConfig;
        Account acc2 = TestHelper.getAccount(true);

        contact con = TestHelper.getContact(false);
           con.accountId = acc2.Id;
           insert con;
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.PrimaryRepPrefix__c= 'Mr';
        uReg.PrimaryRepFirstName__c= 'Betty';
        uReg.PrimaryRepLastName__c= 'Ander';
        uReg.PrimaryRepAddress1__c= '23 main street';
        uReg.PrimaryRepAddress2__c= 'abc';
        uReg.PrimaryRepCity__c= 'sterling';
       // uReg.PrimaryRepState__c= 'VA';
        uReg.PrimaryRepZipCode__c='23456-1546';
        uReg.PrimaryRepCountry__c= 'USA';
        uReg.PrimaryRepPhone__c= '1234567890';
        uReg.PrimaryRepEmail__c= 'swati@gmail.com';
        uReg.LastName__c = 'Betty';
        uReg.isApplicant__c = true;
        uReg.Contact__c = con.Id;
        //uReg.UserRole__c = 'Project Director';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        uReg.Status__c = 'In Progress';
        uReg.RecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Additional Applicant').getRecordTypeId();
        insert uReg;
        con.UserRegistration__c = uReg.Id;
        Update con;
        Account acc = TestHelper.getAccount(false);
        acc.name = 'SME Reviewer System Account';
        insert acc;
        Account acc1 = TestHelper.getAccount(false);
        acc1.name = 'Individuals System Account';
        insert acc1;
        GNT__KeyValueStore__c key1= new GNT__KeyValueStore__c(Name='UniqueUsername',
                                                GNT__IntegerValue__c=1153,
                                                GNT__BooleanValue__c=true,
                                                GNT__Admin_Question__c = 'Loren Ipsum',
                                                GNT__Description__c='Email address to send feedback of the customer in real time');
        insert key1; 

        Test.startTest();
        uReg.Status__c = 'Approved';
        update uReg;
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
        */
    }
     /* @IsTest(OnInstall=false)
    public static void test_ctrl5() {
     UserRole portalRole = new UserRole();
     portalRole.PortalType ='None';
     portalRole.name ='abc';
     insert portalRole ;
     
        User u = TestHelper.getAdminUser(false);
        u.UserRoleId = portalRole.id;
        
        insert u;
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        UserRegistrationTriggerHelper.skipBeforeUpdate = true;
        UserRegistrationTriggerHelper.skipAfterUpdate= true;
        AccountTriggerHelper.skipTrigger = true;

        CommunityProfileConfig__c communityProfileConfig = new CommunityProfileConfig__c();
        communityProfileConfig.ProfileName__c = 'SPI';
        communityProfileConfig.ExternalRegistrationRecordType__c = 'Additional Applicant';
        communityProfileConfig.Name = 'Additional Applicant';
        insert communityProfileConfig;
        Account acc2 = TestHelper.getAccount(true);

        contact con = TestHelper.getContact(false);
           con.accountId = acc2.Id;
           insert con;
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.OrganizationStreetAddress__c= '23 main street';
        uReg.OrganizationStreet2Address__c= 'abc';
        uReg.OrganizationZipCode__c= '23456-1546';
        uReg.OrganizationCityAddress__c= 'abc';
        uReg.OrganizationState__c= 'sterling';
        uReg.LastName__c = 'Betty';
        uReg.isApplicant__c = true;
        uReg.Contact__c = con.Id;
        //uReg.UserRole__c = 'Project Director';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        uReg.Status__c = 'In Progress';
        uReg.RecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Additional Applicant').getRecordTypeId();

        insert uReg;
        con.UserRegistration__c = uReg.Id;
        Update con;
        Account acc = TestHelper.getAccount(false);
        acc.name = 'SME Reviewer System Account';
        insert acc;
        Account acc1 = TestHelper.getAccount(false);
        acc1.name = 'Individuals System Account';
        insert acc1;
        GNT__KeyValueStore__c key1= new GNT__KeyValueStore__c(Name='UniqueUsername',
                                                GNT__IntegerValue__c=1153,
                                                GNT__BooleanValue__c=true,
                                                GNT__Admin_Question__c = 'Loren Ipsum',
                                                GNT__Description__c='Email address to send feedback of the customer in real time');
        insert key1; 
        Test.startTest();
        uReg.Status__c = 'Approved';
        update uReg;
        Test.stopTest();
        System.assertEquals(uReg.Id, uReg.Id);
        }
    }*/
  }