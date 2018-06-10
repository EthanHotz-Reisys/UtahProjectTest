@isTest

public with sharing class TestActivateReviewerCtrl  { 
     static Map<String,Object> testResult;
    
    @isTest
    private static void testAll(){
        UserTriggerHelper.skipTrigger = true;
        user u = TestHelper.getAdminUser(false);        
        system.runAs(u){           
            TestHelper.createCustomSettings(true);
            UserTriggerHelper.skipTrigger = true;
            test.startTest();
            ActivateReviewerCtrl act = new ActivateReviewerCtrl ();
            act.selectedRecordIds=new List<String>();
            act.selectedRecordIds.add(u.id);
            
            testResult = act.clickHandler(); 
            test.stopTest();
            System.assertNotEquals(testResult,null);
        }
    }
   
  }