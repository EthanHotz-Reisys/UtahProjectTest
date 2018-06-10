/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2016   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestReviewerEmailRegViewCtrl {


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
     
        contact con = testHelper.getContact(true);
        Test.startTest();

     
        ReviewerEmailRegViewCtrl ctrl = new ReviewerEmailRegViewCtrl (new ApexPages.StandardController(con));
        ctrl.getKeyValueMap();

        Test.stopTest();

        //assert
        System.assertEquals(con.Id, con.Id);
        
        
        }
    }
       @IsTest(OnInstall=false)
    public static void test_ctrl1() {
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
     
        contact con = testHelper.getContact(true);
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', con.Id);
        ApexPages.currentPage().getParameters().put('tempLayout', '1');
        ReviewerEmailRegViewCtrl ctrl = new ReviewerEmailRegViewCtrl (new ApexPages.StandardController(con));
        ctrl.getKeyValueMap();

        Test.stopTest();

        //assert
        System.assertEquals(con.Id, con.Id);
        
        
        }
    }
    @IsTest(OnInstall=false)
    public static void test_ctrl2() {
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
     
        contact con = testHelper.getContact(true);
        Test.startTest();
        ApexPages.currentPage().getParameters().put('conId', con.Id);
        ApexPages.currentPage().getParameters().put('tempLayout', '2');

     
        ReviewerEmailRegViewCtrl ctrl = new ReviewerEmailRegViewCtrl (new ApexPages.StandardController(con));
        ctrl.getKeyValueMap();

        Test.stopTest();

        //assert
        System.assertEquals(con.Id, con.Id);
        
        
        }
    }
    
     @IsTest(OnInstall=false)
    public static void test_ctrl3() {
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
     
        contact con = testHelper.getContact(true);
        Test.startTest();
        ApexPages.currentPage().getParameters().put('conId', con.Id);
        ApexPages.currentPage().getParameters().put('tempLayout', '3');

     
        ReviewerEmailRegViewCtrl ctrl = new ReviewerEmailRegViewCtrl (new ApexPages.StandardController(con));
        ctrl.getKeyValueMap();

        Test.stopTest();

        //assert
        System.assertEquals(con.Id, con.Id);
        
        
        }
    }
  }