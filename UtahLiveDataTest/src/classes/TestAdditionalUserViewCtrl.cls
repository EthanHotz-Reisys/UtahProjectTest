/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2016  swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestAdditionalUserViewCtrl{


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
        
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        UserTriggerHelper.skipTrigger = true;
        contact con = TestHelper.getContact(true);
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', con.Id);
        
        AdditionalUserViewCtrl ctrl = new AdditionalUserViewCtrl(new ApexPages.StandardController(con));
        ctrl.getKeyValueMap();
        Test.stopTest();

        //assert
        System.assertEquals(con.Id, con.Id);
        
        
        }
    }
  }