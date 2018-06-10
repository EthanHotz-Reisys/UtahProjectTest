/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2014   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestReviewerConfirmationViewCtrl {


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        ReviewTriggerHelper.SkipTrigger = true;
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        Review__c r = new Review__c();
        insert r;
        Test.startTest();
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');    
        ApexPages.currentPage().getParameters().put('id', r.Id);
        ApexPages.currentPage().getParameters().put('type', 'Applicant');
        ApexPages.currentPage().getParameters().put('nextAction', 'Edit');
        //ReviewerConfirmationEditCtrl ctrl = new ReviewerConfirmationEditCtrl();
        ReviewerConfirmationViewCtrl ctrl = new ReviewerConfirmationViewCtrl (new ApexPages.StandardController(r));
        ctrl.getKeyValueMap();
        ctrl.redirect();
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
        ReviewTriggerHelper.SkipTrigger = true;
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        Review__c r = new Review__c();
        r.Status__c = 'Declined Due To Conflict';
        insert r;
        Test.startTest();
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');    
        ApexPages.currentPage().getParameters().put('id', r.Id);
        ApexPages.currentPage().getParameters().put('type', 'Applicant');
        ApexPages.currentPage().getParameters().put('nextAction', 'Edit');
        ReviewerConfirmationViewCtrl ctrl = new ReviewerConfirmationViewCtrl();
        //ReviewerConfirmationEditCtrl ctrl = new ReviewerConfirmationEditCtrl (new ApexPages.StandardController(r));
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
        ReviewTriggerHelper.SkipTrigger = true;
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        Review__c r = new Review__c();
        insert r;
        Test.startTest();
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');    
        ApexPages.currentPage().getParameters().put('id', r.Id);
        ApexPages.currentPage().getParameters().put('type', 'Applicant');
        ApexPages.currentPage().getParameters().put('nextAction', 'Continue');
        //ReviewerConfirmationEditCtrl ctrl = new ReviewerConfirmationEditCtrl();
        ReviewerConfirmationViewCtrl ctrl = new ReviewerConfirmationViewCtrl (new ApexPages.StandardController(r));
        ctrl.getKeyValueMap();
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
        ReviewTriggerHelper.SkipTrigger = true;
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        Review__c r = new Review__c();
        insert r;
        Test.startTest();
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');    
        ApexPages.currentPage().getParameters().put('id', r.Id);
        ApexPages.currentPage().getParameters().put('type', 'Applicant');
        ApexPages.currentPage().getParameters().put('nextAction', 'Decline');
        //ReviewerConfirmationEditCtrl ctrl = new ReviewerConfirmationEditCtrl();
        ReviewerConfirmationViewCtrl ctrl = new ReviewerConfirmationViewCtrl (new ApexPages.StandardController(r));
        ctrl.getKeyValueMap();
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
        ReviewTriggerHelper.SkipTrigger = true;
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        Review__c r = new Review__c();
        r.ReviewDeclineReason__c ='Abc';
        insert r;
        Test.startTest();
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');    
        ApexPages.currentPage().getParameters().put('id', r.Id);
        ApexPages.currentPage().getParameters().put('type', 'Applicant');
        ApexPages.currentPage().getParameters().put('nextAction', 'Decline');
        //ReviewerConfirmationEditCtrl ctrl = new ReviewerConfirmationEditCtrl();
        ReviewerConfirmationViewCtrl ctrl = new ReviewerConfirmationViewCtrl (new ApexPages.StandardController(r));
        ctrl.getKeyValueMap();
        ctrl.redirect();
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
    
            @IsTest(OnInstall=false)
    public static void test_ctrl6() {
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        ReviewTriggerHelper.SkipTrigger = true;
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        Review__c r = new Review__c();
        r.ReviewAcceptanceStatus__c ='Accepted';
        insert r;
        Test.startTest();
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');    
        ApexPages.currentPage().getParameters().put('id', r.Id);
        ApexPages.currentPage().getParameters().put('type', 'Applicant');
        //ApexPages.currentPage().getParameters().put('nextAction', 'Decline');
        //ReviewerConfirmationEditCtrl ctrl = new ReviewerConfirmationEditCtrl();
        ReviewerConfirmationViewCtrl ctrl = new ReviewerConfirmationViewCtrl (new ApexPages.StandardController(r));
        ctrl.getKeyValueMap();
        ctrl.redirect();
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
    
    
        @IsTest(OnInstall=false)
    public static void test_ctrl7() {
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        ReviewTriggerHelper.SkipTrigger = true;
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        Review__c r = new Review__c();
        r.ReviewAcceptanceStatus__c = 'Accepted';
        insert r;
        Test.startTest();
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');    
        ApexPages.currentPage().getParameters().put('id', r.Id);
        ApexPages.currentPage().getParameters().put('type', 'Applicant');
        ApexPages.currentPage().getParameters().put('nextAction', 'Edit');
        ReviewerConfirmationViewCtrl ctrl = new ReviewerConfirmationViewCtrl();
        //ReviewerConfirmationEditCtrl ctrl = new ReviewerConfirmationEditCtrl (new ApexPages.StandardController(r));
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
  }