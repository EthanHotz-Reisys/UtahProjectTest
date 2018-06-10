/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2016   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestInviteExternalReviewersCtrl{


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        Test.startTest();
        InviteExternalReviewersCtrl ctrl = new InviteExternalReviewersCtrl();
        ctrl.getKeyValueMap();
        Test.stopTest();

        
        
        }
    }
  }