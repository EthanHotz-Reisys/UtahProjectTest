/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2014   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestRegisteredUserCtrl{


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
      
        Test.startTest();

      
        RegisteredUserCtrl ctrl = new RegisteredUserCtrl();
        ctrl.getKeyValueMap();
        Test.stopTest();

        //assert
      //  System.assertEquals(uReg.Id, uReg.Id);
        
        
        }
    }
  }