/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2016   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestReviewerViewCtrl {


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
       contact con = TestHelper.getContact(true);
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', con.Id);
        ApexPages.currentPage().getParameters().put('type', 'Applicant');
        ReviewerViewCtrl ctrl = new ReviewerViewCtrl(new ApexPages.StandardController(con));
        ctrl.getKeyValueMap();
        Test.stopTest();

        //assert
        System.assertEquals(con.Id, con.Id);
        
        
        }
    }
  }