@isTest
private class TestFinalizeScheduleCtrl {
     @isTest
    private static void testFinalizeScheduleCtrl() {
         UserTriggerHelper.skipTrigger = true;
        User admin = TestHelper.getAdminUser(true);
        System.runAs(admin) {
            AnnouncementTriggerHelper.skipTrigger = true;
            RolesAndResponsibilitiesTriggerHelper.skipTrigger = true;
            
            Test.startTest();
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            Announcement__c ann = TestHelper.getAnnouncement(true);
            PageReference result;
            //List<SiteVisit__c> siteVisitList= new List<SiteVisit__c>();
            SiteVisitSchedule__c siteVisitSchedule = TestHelper.getSiteVisitSchedule(true);
            //siteVisitList.add(siteVisitSchedule);
            //List<ID> ids = TestHelper.setLayoutData1('SiteVisitSchedule__c');
            String ns = AppUtils.getNamespacePrefix();
            GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'SiteVisitSchedule__c');
            GNT__TabConfig__c tabConfig =  TestHelper.getTabConfig(pageLayoutConfig.Id,true);
            GNT__PageBlockConfig__c pageBlockConfig =  TestHelper.getPageBlockConfig(tabConfig.Id, true);
            GNT__PageBlockDetailConfig__c pageBlockDetailConfigList = TestHelper.getPageBlockDetailConfig(pageBlockConfig.Id,false); 
           
                if(pageBlockDetailConfigList.GNT__FieldAPIName__c == 'Name') {
                    insert pageBlockDetailConfigList;
                }
            
            GNT__PageLayoutActionConfig__c pageAction = TestHelper.getPageLayoutActionConfig(true,pageLayoutConfig.Id);
            
            GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, siteVisitSchedule.Id,true);
            FinalizeScheduleCtrl fsc = new FinalizeScheduleCtrl();
            fsc.layoutHolder = layoutHolder;
            System.debug(layoutHolder.recordMap);
            result = fsc.whenClicked();
            //fsc.sendEmailNUpdateSiteVisit(siteVisitList);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testFinalizeScheduleCtrl2() {
        UserTriggerHelper.skipTrigger = true;
        User admin = TestHelper.getAdminUser(true);
        System.runAs(admin) {
            AnnouncementTriggerHelper.skipTrigger = true;
            RolesAndResponsibilitiesTriggerHelper.skipTrigger = true;
            
            Test.startTest();
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            Announcement__c ann = TestHelper.getAnnouncement(true);
            PageReference result;
            //List<SiteVisit__c> siteVisitList= new List<SiteVisit__c>();
            SiteVisitSchedule__c siteVisitSchedule = TestHelper.getSiteVisitSchedule(true);
            //siteVisitList.add(siteVisitSchedule);
            //List<ID> ids = TestHelper.setLayoutData1('SiteVisitSchedule__c');
            String ns = AppUtils.getNamespacePrefix();
            GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'SiteVisitSchedule__c');
            GNT__TabConfig__c tabConfig =  TestHelper.getTabConfig(pageLayoutConfig.Id,true);
            GNT__PageBlockConfig__c pageBlockConfig =  TestHelper.getPageBlockConfig(tabConfig.Id, true);
            GNT__PageBlockDetailConfig__c pageBlockDetailConfigList = TestHelper.getPageBlockDetailConfig(pageBlockConfig.Id,false); 
           
                if(pageBlockDetailConfigList.GNT__FieldAPIName__c == 'Name') {
                    insert pageBlockDetailConfigList;
                }
            
            GNT__PageLayoutActionConfig__c pageAction = TestHelper.getPageLayoutActionConfig(true,pageLayoutConfig.Id);
            
            GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, siteVisitSchedule.Id,true);
            
            FinalizeScheduleCtrl fsc = new FinalizeScheduleCtrl();
            fsc.layoutHolder = layoutHolder;
            delete siteVisitSchedule;
            System.debug(layoutHolder.recordMap);
            result = fsc.whenClicked();
            //fsc.sendEmailNUpdateSiteVisit(siteVisitList);
            Test.stopTest();
        }
    }
   
}