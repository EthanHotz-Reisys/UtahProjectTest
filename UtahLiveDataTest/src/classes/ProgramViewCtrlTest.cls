@isTest(SeeAllData=false)
private with sharing class ProgramViewCtrlTest {
    static testMethod void testController() {
    /*
          Account acct = null;
          User u = TestHelper.getAdminUser(true);
                 
        
          System.runAs(u){
              GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
              AccountTriggerHelper.skipTrigger=true;
              ProgramTriggerHelper.skipTrigger=true;
              acct = TestHelper.getAccount(true);
              UserTriggerHelper.skipTrigger=true;
              u= [select GNT__OrganizationId__c from User where Id=:UserInfo.getUserId()];
              u.GNT__OrganizationId__c=acct.Id;
              update u;
              Program__c prog = TestHelper.getProgram(acct.Id,true);
          
             Test.startTest();
             ApexPages.StandardController sc = new ApexPages.standardController(prog);
             ApexPages.currentPage().getParameters().put('Id',prog.id);
             ProgramViewCtrl ctrl = new ProgramViewCtrl(sc);
             ctrl.getKeyValueMap();
             ctrl.getChartParameters();
             Test.stopTest();
        }
        */
    }
}