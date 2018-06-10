@isTest
private with sharing class TestCreatePreApplicationHelper {

    static testMethod void testWhenClicked() {
    /*
         UserTriggerHelper.skipTrigger = true;
         User u = TestHelper.getAdminUser(true);
         PreApplication__c preApp = null;
         GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'Recipient');
         Account acct = null;
         
         System.runAs(u) {
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
            preApp = TestHelper.getPreApplication(true);
            
            OpportunityQualification__c oppQual = new OpportunityQualification__c(FundingOpportunity__c=ann.Id,IsPreapplicationSubmitted__c=false);
            insert oppQual;
          
            
            GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'OpportunityQualification__c ');
            GNT__TabConfig__c tabConfig =  TestHelper.getTabConfig(pageLayoutConfig.Id,true);
            GNT__PageBlockConfig__c pageBlockConfig =  TestHelper.getPageBlockConfig(tabConfig.Id, true);
            GNT__PageBlockDetailConfig__c pageBlockDetailConfigList = TestHelper.getPageBlockDetailConfig(pageBlockConfig.Id,false); 
            if(pageBlockDetailConfigList.GNT__FieldAPIName__c == 'Name') {
                insert pageBlockDetailConfigList;
             }
            
            GNT__PageLayoutActionConfig__c pageAction = TestHelper.getPageLayoutActionConfig(true,pageLayoutConfig.Id);
            GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, oppQual.Id,true);
            
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','Recipient');
            ApexPages.CurrentPage().getParameters().put('id',preApp.Id);
            CreatePreApplicationHelper createPreApp = new CreatePreApplicationHelper();
            createPreApp.layoutHolder = layoutHolder;
            System.debug(layoutHolder.recordMap);
            result = createPreApp.whenClicked();
            //fsc.sendEmailNUpdateSiteVisit(siteVisitList);
            Test.stopTest();
        }
        */
    }
    
    static testMethod void testWhenClicked2() {
    /*
         UserTriggerHelper.skipTrigger = true;
         User u = TestHelper.getAdminUser(true);
         PreApplication__c preApp = null;
         GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee');
         Account acct = null;
         
         System.runAs(u) {
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
            preApp = TestHelper.getPreApplication(true);
            
            OpportunityQualification__c oppQual = new OpportunityQualification__c(FundingOpportunity__c=ann.Id,IsPreapplicationSubmitted__c=false);
            insert oppQual;
          
            
            GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'Announcement__c');
            GNT__TabConfig__c tabConfig =  TestHelper.getTabConfig(pageLayoutConfig.Id,true);
            GNT__PageBlockConfig__c pageBlockConfig =  TestHelper.getPageBlockConfig(tabConfig.Id, true);
            GNT__PageBlockDetailConfig__c pageBlockDetailConfigList = TestHelper.getPageBlockDetailConfig(pageBlockConfig.Id,false); 
            if(pageBlockDetailConfigList.GNT__FieldAPIName__c == 'Name') {
                insert pageBlockDetailConfigList;
             }
            
            GNT__PageLayoutActionConfig__c pageAction = TestHelper.getPageLayoutActionConfig(true,pageLayoutConfig.Id);
            GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, ann.Id,true);
            
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantee');
            ApexPages.CurrentPage().getParameters().put('id',preApp.Id);
            CreatePreApplicationHelper createPreApp = new CreatePreApplicationHelper();
            createPreApp.layoutHolder = layoutHolder;
            System.debug(layoutHolder.recordMap);
            result = createPreApp.whenClicked();
            //fsc.sendEmailNUpdateSiteVisit(siteVisitList);
            Test.stopTest();
        }
        */
    }
    
    static testMethod void testWhenClicked3() {
    /*
         UserTriggerHelper.skipTrigger = true;
         User u = TestHelper.getAdminUser(true);
         PreApplication__c preApp = null;
         GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee');
         Account acct = null;
         
         System.runAs(u) {
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
            preApp = TestHelper.getPreApplication(true);
            preApp.Announcement__c=ann.Id;
            preApp.Status__c='Approved';
            update preApp;
            
            OpportunityQualification__c oppQual = new OpportunityQualification__c(FundingOpportunity__c=ann.Id,IsPreapplicationSubmitted__c=false);
            insert oppQual;
          
            
            GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'Announcement__c');
            GNT__TabConfig__c tabConfig =  TestHelper.getTabConfig(pageLayoutConfig.Id,true);
            GNT__PageBlockConfig__c pageBlockConfig =  TestHelper.getPageBlockConfig(tabConfig.Id, true);
            GNT__PageBlockDetailConfig__c pageBlockDetailConfigList = TestHelper.getPageBlockDetailConfig(pageBlockConfig.Id,false); 
            if(pageBlockDetailConfigList.GNT__FieldAPIName__c == 'Name') {
                insert pageBlockDetailConfigList;
             }
            
            GNT__PageLayoutActionConfig__c pageAction = TestHelper.getPageLayoutActionConfig(true,pageLayoutConfig.Id);
            GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, ann.Id,true);
            
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantee');
            ApexPages.CurrentPage().getParameters().put('id',preApp.Id);
            CreatePreApplicationHelper createPreApp = new CreatePreApplicationHelper();
            createPreApp.layoutHolder = layoutHolder;
            System.debug(layoutHolder.recordMap);
            result = createPreApp.whenClicked();
            preApp.Status__c='Submitted to Grantor';
            update preApp;
            Test.stopTest();
        }
        */
    }
}