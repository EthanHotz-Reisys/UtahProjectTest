@isTest
public with sharing class TestCloneProgramHelper {
    static testMethod void testMethod0() {
    /*
        UserTriggerHelper.skipTrigger = true; 
        User admin = TestHelper.getAdminUser(true);
        Account acct = null;
  
        System.runAs(admin) {
            AnnouncementTriggerHelper.skipTrigger = true;
            RolesAndResponsibilitiesTriggerHelper.skipTrigger = true;
            ApplicationTriggerHelper.skipTrigger = true;
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            AccountTriggerHelper.skipTrigger=true;
            acct = TestHelper.getAccount(true);
           
            Test.startTest();
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            String ns = AppUtils.getNamespacePrefix();
            PageReference result;
            Program__c prog = TestHelper.getProgram(acct.Id,true);
           
            GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'Program__c');
            GNT__TabConfig__c tabConfig =  TestHelper.getTabConfig(pageLayoutConfig.Id,true);
            GNT__PageBlockConfig__c pageBlockConfig =  TestHelper.getPageBlockConfig(tabConfig.Id, true);
            GNT__PageBlockDetailConfig__c pageBlockDetailConfigList = TestHelper.getPageBlockDetailConfig(pageBlockConfig.Id,false); 
            if(pageBlockDetailConfigList.GNT__FieldAPIName__c == 'Name') {
                insert pageBlockDetailConfigList;
             }
            
            GNT__PageLayoutActionConfig__c pageAction = TestHelper.getPageLayoutActionConfig(true,pageLayoutConfig.Id);
            GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, prog.Id,true);

            ApexPages.StandardController sc = new ApexPages.standardController(prog);
            CloneProgramHelper cloneProgHelp = new CloneProgramHelper(sc);
            cloneProgHelp.layoutHolder = layoutHolder;
            result = cloneProgHelp.whenClicked();
            Test.stopTest();
        }
        */
    }
}