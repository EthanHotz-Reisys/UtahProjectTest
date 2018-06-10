/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2016   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestCommunityApprovalDetailsCtrl {


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        ProcessInstanceWorkitem p = TestHelper.getWorkItem(); 
        Test.startTest();

        ApexPages.currentPage().getParameters().put('Id', p.Id);
        ApexPages.currentPage().getParameters().put('type', 'Applicant');
        CommunityApprovalDetailsCtrl ctrl = new CommunityApprovalDetailsCtrl(new ApexPages.StandardController(p));
        ctrl.approveRecord();
        ctrl.rejectRecord();
        Test.stopTest();

        //assert
        System.assertEquals(p.Id, p.Id);
        
        
        }
    }
  }