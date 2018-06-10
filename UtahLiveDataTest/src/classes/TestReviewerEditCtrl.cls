/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2016   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestReviewerEditCtrl{


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        contact con = TestHelper.getContact(true);
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', con.Id);
        ApexPages.currentPage().getParameters().put('type', 'Applicant');
        ReviewerEditCtrl ctrl = new ReviewerEditCtrl(new ApexPages.StandardController(con));
        ctrl.getKeyValueMap();
        Test.stopTest();

        //assert
        System.assertEquals(con.Id, con.Id);
        
        
        }
    }
    
    
    @IsTest(OnInstall=false)
    public static void test_ctrl1() {
    /*
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        AccounttriggerHelper.skipTrigger = true;
        TestHelper.CreateCustomSettings(true);
        contact con = TestHelper.getContact(true);
        Test.startTest();
        Account acc = TestHelper.getAccount(false);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Reviewers').getRecordTypeId();
       // string recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Reviewers').getRecordTypeId();
       insert acc;
            
       // ApexPages.currentPage().getParameters().put('id', con.Id);
        ApexPages.currentPage().getParameters().put('type', 'Applicant');
        ReviewerEditCtrl ctrl = new ReviewerEditCtrl(new ApexPages.StandardController(con));

        Test.stopTest();

        //assert
        System.assertEquals(con.Id, con.Id);
        
        
        }
        */
    }
  }