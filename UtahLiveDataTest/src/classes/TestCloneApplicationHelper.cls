@isTest
private class TestCloneApplicationHelper{
    
    @isTest
    private static void testWhenClicked() {
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
           
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,true);
           
            GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'Application__c');
            GNT__TabConfig__c tabConfig =  TestHelper.getTabConfig(pageLayoutConfig.Id,true);
            GNT__PageBlockConfig__c pageBlockConfig =  TestHelper.getPageBlockConfig(tabConfig.Id, true);
            GNT__PageBlockDetailConfig__c pageBlockDetailConfigList = TestHelper.getPageBlockDetailConfig(pageBlockConfig.Id,false); 
            if(pageBlockDetailConfigList.GNT__FieldAPIName__c == 'Name') {
                insert pageBlockDetailConfigList;
             }
            
            GNT__PageLayoutActionConfig__c pageAction = TestHelper.getPageLayoutActionConfig(true,pageLayoutConfig.Id);
            GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, app.Id,true);

            ApexPages.StandardController sc = new ApexPages.standardController(app);
            CloneApplicationHelper cloneAppHelp = new CloneApplicationHelper(sc);
            cloneAppHelp.layoutHolder = layoutHolder;
            System.debug(layoutHolder.recordMap);
            result = cloneAppHelp.whenClicked();
            delete app;
            result = cloneAppHelp.whenClicked();
            Test.stopTest();
        }
        */
    }
    
    @isTest
    private static void testWhenClicked2() {
    /*
        UserTriggerHelper.skipTrigger = true; 
        User admin = TestHelper.getAdminUser(true);
        Account acct = null;
  
        System.runAs(admin) {
            AnnouncementTriggerHelper.skipTrigger = true;
            RolesAndResponsibilitiesTriggerHelper.skipTrigger = true;
            ApplicationTriggerHelper.skipTrigger = true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            AccountTriggerHelper.skipTrigger=true;
            acct = TestHelper.getAccount(true);
           
            Test.startTest();
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            String ns = AppUtils.getNamespacePrefix();
            PageReference result;
           
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,true);
            ann.MaxApplicationsAllowed__c=10;
            update ann;
             
            GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'Application__c');
            GNT__TabConfig__c tabConfig =  TestHelper.getTabConfig(pageLayoutConfig.Id,true);
            GNT__PageBlockConfig__c pageBlockConfig =  TestHelper.getPageBlockConfig(tabConfig.Id, true);
            GNT__PageBlockDetailConfig__c pageBlockDetailConfigList = TestHelper.getPageBlockDetailConfig(pageBlockConfig.Id,false); 
            if(pageBlockDetailConfigList.GNT__FieldAPIName__c == 'Name') {
                insert pageBlockDetailConfigList;
             }
            
            GNT__PageLayoutActionConfig__c pageAction = TestHelper.getPageLayoutActionConfig(true,pageLayoutConfig.Id);
            GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, app.Id,true);

            Program__c pgm = TestHelper.getProgram(acct.Id,true);
            RolesAndResponsibilities__c roleAndResp =new RolesAndResponsibilities__c(Program__c = pgm.Id,BusinessRole__c='Program Approver',Application__c=app.Id);       
            insert roleAndResp;
            
            GNT__AttachmentExtension__c attachExt = TestHelper.getAttachmentExtension('Application',app.Id,true);
            ApexPages.StandardController sc = new ApexPages.standardController(app);
            CloneApplicationHelper cloneAppHelp = new CloneApplicationHelper(layoutHolder);
            cloneAppHelp.layoutHolder = layoutHolder;
            System.debug(layoutHolder.recordMap);
            result = cloneAppHelp.whenClicked();
            
            Test.stopTest();
        }
        */
    }
    
        private static void testWhenClicked3() {
        /*
        UserTriggerHelper.skipTrigger = true; 
        User admin = TestHelper.getAdminUser(true);
        Account acct = null;
  
        System.runAs(admin) {
            AnnouncementTriggerHelper.skipTrigger = true;
            RolesAndResponsibilitiesTriggerHelper.skipTrigger = true;
            ApplicationTriggerHelper.skipTrigger = true;
            RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
            GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='ENTERPRISE',GNT__BooleanValue__c=true);
            AccountTriggerHelper.skipTrigger=true;
            acct = TestHelper.getAccount(true);
           
            Test.startTest();
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            String ns = AppUtils.getNamespacePrefix();
            PageReference result;
           
            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id,true);
            ann.MaxApplicationsAllowed__c=0;
            update ann;
             
            GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'Application__c');
            GNT__TabConfig__c tabConfig =  TestHelper.getTabConfig(pageLayoutConfig.Id,true);
            GNT__PageBlockConfig__c pageBlockConfig =  TestHelper.getPageBlockConfig(tabConfig.Id, true);
            GNT__PageBlockDetailConfig__c pageBlockDetailConfigList = TestHelper.getPageBlockDetailConfig(pageBlockConfig.Id,false); 
            if(pageBlockDetailConfigList.GNT__FieldAPIName__c == 'Name') {
                insert pageBlockDetailConfigList;
             }
            
            GNT__PageLayoutActionConfig__c pageAction = TestHelper.getPageLayoutActionConfig(true,pageLayoutConfig.Id);
            GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, app.Id,true);

            Program__c pgm = TestHelper.getProgram(acct.Id,true);
            RolesAndResponsibilities__c roleAndResp =new RolesAndResponsibilities__c(Program__c = pgm.Id,BusinessRole__c='Program Approver',Application__c=app.Id);       
            insert roleAndResp;
            
            GNT__AttachmentExtension__c attachExt = TestHelper.getAttachmentExtension('Application',app.Id,true);
            ApexPages.StandardController sc = new ApexPages.standardController(app);
            CloneApplicationHelper cloneAppHelp = new CloneApplicationHelper();
            cloneAppHelp.layoutHolder = layoutHolder;
            System.debug(layoutHolder.recordMap);
            result = cloneAppHelp.whenClicked();
            Test.stopTest();
        }
        */
    }
}