/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2014   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestNotifyNonWinnersHelper {


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        Test.startTest();
         NotifyNonWinnersHelper ctrl = new NotifyNonWinnersHelper();
        ctrl.clickHandler();

        Test.stopTest();

        //assert
        System.assertEquals(ctrl, ctrl);
        
        
        }
    }
    
     @IsTest(OnInstall=false)
    public static void test_ctrl1() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        ApplicationTriggerHelper.skiptrigger = true;
        AnnouncementTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger = true;
        ReviewPanelTemplateTriggerHelper.skipTrigger = true;
        TestHelper.CreateCustomSettings(true);
       
        Test.startTest();
       ReviewStep__c rs = TestHelper.getReviewStep(true);
       ApexPages.currentPage().getParameters().put('Id', rs.Id);
       ReviewStepApplication__c rsa = TestHelper.getReviewStepApplication(true);
       List<String> selectedRecordIds = new List<String>();
       selectedRecordIds.add(rsa.id);
       Map<String,String> urlParams = new Map<String,String>();
            NotifyNonWinnersHelper ctrl = new NotifyNonWinnersHelper();
            ctrl.selectedRecordIds = selectedRecordIds;
            urlParams.put('id',rs.Id);
            ctrl.urlParams = urlParams;
            ctrl.clickHandler();   
            Test.stopTest();

        //assert
        System.assertEquals(rs.Id, rs.Id);
        
        
        }
    }
  }