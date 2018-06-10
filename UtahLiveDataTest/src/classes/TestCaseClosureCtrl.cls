/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2016   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestCaseClosureCtrl {


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
        //Shah 4/28/2017 Commenting out since we should not be using native Case object
        /*
        User u = TestHelper.getAdminUser(true);
        UserRegistrationTriggerHelper.skipTrigger= true;
        UserRegistrationTriggerHelper.skipBeforeUpdate = true;
        UserRegistrationTriggerHelper.skipAfterUpdate= true;
        ApplicationTriggerHelper.skipTrigger = true;
        ReviewTriggerHelper.skipTrigger = true;   
        AccountTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger = true;
        AppUtils.skipStepReviewTrigger = true;  
        PanelUserTriggerHelper.skipAll=true;  
        ReviewStepTriggerHelper.skipTrigger = true;
        ContactTriggerHelper.skipTrigger = true;
        ContactTriggerHelper.skipSyncEmail = true;
        System.runAs(u) {
        GNT__ErrorMessageConfig__c emsg1 = new GNT__ErrorMessageConfig__c();
        emsg1.GNT__ErrorCode__c = 'P17-GRNTE-80225';
        emsg1.GNT__Message__c = 'P17-GRNTE-80225';
        emsg1.GNT__Message_Type__c ='error';
        insert emsg1;
        
        GNT__ErrorMessageConfig__c emsg= new GNT__ErrorMessageConfig__c();
        emsg.GNT__ErrorCode__c = 'P17-GRNTE-55441';
        emsg.GNT__Message__c = 'P17-GRNTE-55441';
        emsg.GNT__Message_Type__c ='error';
        insert emsg;
        UserRegistration__c uReg = new UserRegistration__c();
        uReg.OrganizationName__c ='TestORG';
        uReg.LastName__c = 'Betty';
        uReg.username__c = System.now().millisecond() + 'test@123test.com';
        uReg.EINo__c = Math.Random();
        uReg.Email__c = 'test15@test.com';
        //uReg.RecordType.DeveloperName = 'Reviewer';
        insert uReg;
        Test.startTest();
        
        Case case1 = new Case();
        case1.Case_Comments_All__c='test';
        case1.caseComments__c='test';
        case1.Detailed_Comments__c='test1';
        insert case1;

        //ApexPages.currentPage().getParameters().put('id', uReg.Id);
        ApexPages.currentPage().getParameters().put('type', 'Applicant');
        ApexPages.currentPage().getParameters().put('id', case1.Id);
        CaseClosureCtrl ctrl = new CaseClosureCtrl();
        ctrl.whenClicked();
        Test.stopTest();

        //assert
        System.assertEquals(uReg.Id, uReg.Id);
        
        
        }*/
    }
  }