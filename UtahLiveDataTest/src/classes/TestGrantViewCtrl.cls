/**
 
    **********************************************************
    Audit History
    **********************************************************
    7/21/2014   swati singh    Created
 
    **********************************************************  
*/
@isTest
public with sharing class TestGrantViewCtrl{

    @IsTest(OnInstall=false)
    public static void test_ctrl() {
    /*
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        GrantTriggerHelper.skipTrigger=true;
        
        Grant__c g  = TestHelper.getGrant(false);
        g.GrantType__c = 'USBEMSP';
        Insert g;
     
        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.standardController(g); 
        ApexPages.currentPage().getParameters().put('Id',g.Id);
        ApexPages.currentPage().getParameters().put('ActiveAppName__c','StateasGrantee');
        GrantViewCtrl extReg= new GrantViewCtrl(sc); 
        extReg.getKeyValueMap();
        Test.stopTest();

        //assert
        System.assertEquals('', '');
        
        
        }
        */
    }
    
     
  }