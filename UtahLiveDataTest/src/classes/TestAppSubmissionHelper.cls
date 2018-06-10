@isTest
private with sharing class TestAppSubmissionHelper {
    static testMethod void testWhenClicked() {
    
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        Application__c app = null;
        Announcement__c ann = null;
        List<BudgetCategory__c> budCat = null;
        ApplicationBudgetCategory2__c appbudCat = null;
        
        System.runAs(u){
            ApplicationTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            UserTriggerHelper.skipTrigger = true;
            
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            
            ann = TestHelper.getAnnouncement(true);
            ann.ApplicationCreatedOutside__c='Yes';
            update ann;
            
            app = TestHelper.getApplication(ann.Id,true);
            app.AwardFloor__c=2000;
            app.AwardCeiling__c=1;
            update app;
            
            budCat = TestHelper.getBudgetCategory(true);
            appbudCat = new ApplicationBudgetCategory2__c(Application__c = app.Id, BudgetCategory__c=budCat[0].Id);
            insert appbudCat;
            appbudCat.Amount__c=2;
            update appbudCat;
            
            String ns = AppUtils.getNamespacePrefix();
            GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'Application__c');
            GNT__TabConfig__c tabConfig =  TestHelper.getTabConfig(pageLayoutConfig.Id,true);
            GNT__PageBlockConfig__c pageBlockConfig =  TestHelper.getPageBlockConfig(tabConfig.Id, true);
            GNT__PageBlockDetailConfig__c pageBlockDetailConfigList = TestHelper.getPageBlockDetailConfig(pageBlockConfig.Id,false); 
            
           if(pageBlockDetailConfigList.GNT__FieldAPIName__c == 'Name') {
                    insert pageBlockDetailConfigList;
            }
            
            GNT__PageLayoutActionConfig__c pageAction = TestHelper.getPageLayoutActionConfig(true,pageLayoutConfig.Id);
            GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, app.Id,true);
            Test.startTest();
            AppSubmissionHelper ctrl = new AppSubmissionHelper();
            ctrl.layoutHolder = layoutHolder;
            ctrl.whenClicked();
            Test.stopTest();
        }
    }
    
    static testMethod void testWhenClicked2() {
    
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
       
        Application__c app = null;
        Announcement__c ann = null;
        
        System.runAs(u){
            ApplicationTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            UserTriggerHelper.skipTrigger = true;
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            
            User u2 = TestHelper.getAdminUser(true);
            ann = TestHelper.getAnnouncement(true);
         
            app = TestHelper.getApplication(ann.Id,true);
            app.FormsValidated__c=true;
            app.NumberOfReviews__c = 2;
            app.ProgramApprover__c=u.Id;
            app.FiscalApproval__c=u2.Id;
            app.Status__c='Reviewed';
            update app;
          
            String ns = AppUtils.getNamespacePrefix();
            GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'Application__c');
            GNT__TabConfig__c tabConfig =  TestHelper.getTabConfig(pageLayoutConfig.Id,true);
            GNT__PageBlockConfig__c pageBlockConfig =  TestHelper.getPageBlockConfig(tabConfig.Id, true);
            GNT__PageBlockDetailConfig__c pageBlockDetailConfigList = TestHelper.getPageBlockDetailConfig(pageBlockConfig.Id,false); 
            
           if(pageBlockDetailConfigList.GNT__FieldAPIName__c == 'Name') {
                    insert pageBlockDetailConfigList;
            }
            
            GNT__PageLayoutActionConfig__c pageAction = TestHelper.getPageLayoutActionConfig(true,pageLayoutConfig.Id);
            GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, app.Id,true);          
            
            Test.startTest();          
            AppSubmissionHelper ctrl = new AppSubmissionHelper();
            ctrl.layoutHolder = layoutHolder;
            ctrl.whenClicked();
            Test.stopTest();
        }
    }
}