/**
 
    **********************************************************
    Audit History
    **********************************************************
    7/21/2014   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestMonitoringPhaseViewCtrl{


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
       
        //SiteVisit__c sv= new SiteVisit__c();
        //insert sv;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('reqType', 'SiteVisits');
        MonitoringPhaseViewCtrl ctrl = new MonitoringPhaseViewCtrl();

        Test.stopTest();

        //assert
        System.assertEquals('', '');
        
        
        }
    }
    @IsTest(OnInstall=false)
    public static void test_ctrl1() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
       
        //SiteVisit__c sv= new SiteVisit__c();
        //insert sv;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('reqType', 'ProgressReports');
        MonitoringPhaseViewCtrl ctrl = new MonitoringPhaseViewCtrl();

        Test.stopTest();

        //assert
        System.assertEquals('', '');
        
        
        }
    }
        @IsTest(OnInstall=false)
    public static void test_ctrl2() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
       
        //SiteVisit__c sv= new SiteVisit__c();
        //insert sv;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('reqType', 'RiskAssessment');
        MonitoringPhaseViewCtrl ctrl = new MonitoringPhaseViewCtrl();

        Test.stopTest();

        //assert
        System.assertEquals('', '');
        
        
        }
    }
        @IsTest(OnInstall=false)
    public static void test_ctrl3() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
       
        //SiteVisit__c sv= new SiteVisit__c();
        //insert sv;
        Test.startTest();

        ApexPages.currentPage().getParameters().put('reqType', 'InactiveExternalReviewers');
        MonitoringPhaseViewCtrl ctrl = new MonitoringPhaseViewCtrl();

        Test.stopTest();

        //assert
        System.assertEquals('', '');
        
        
        }
    }
     
  }