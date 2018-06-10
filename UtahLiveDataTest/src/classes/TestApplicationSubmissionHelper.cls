@isTest
private with sharing class TestApplicationSubmissionHelper {
    static testMethod void testWhenClicked() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        Application__c app = null;
        Announcement__c ann = null;
        
        System.runAs(u){
            ApplicationTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            
            ann = TestHelper.getAnnouncement(true);
            app = TestHelper.getApplication(ann.Id,true);
       
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
            
            ApplicationSubmissionHelper ctrl = new ApplicationSubmissionHelper();
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
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            
            ann = TestHelper.getAnnouncement(true);
            app = TestHelper.getApplication(ann.Id,true);
            app.Status__c='Negotiation Initiated';
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
            
            ApplicationSubmissionHelper ctrl = new ApplicationSubmissionHelper();
            ctrl.layoutHolder = layoutHolder;
            ctrl.whenClicked();
            Test.stopTest();
        }
    }
    
      static testMethod void testWhenClicked3() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        Application__c app = null;
        Announcement__c ann = null;
        
        System.runAs(u){
            ApplicationTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            
            ann = TestHelper.getAnnouncement(true);
            app = TestHelper.getApplication(ann.Id,true);
            app.Status__c='Submitted to Grantor';
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
            ApplicationSubmissionHelper ctrl = new ApplicationSubmissionHelper();
            ctrl.layoutHolder = layoutHolder;
            ctrl.whenClicked();
            Test.stopTest();
        }
    }
    
     static testMethod void testWhenClicked4() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
       
        Application__c app = null;
        Application__c app2 = null;
        Announcement__c ann = null;
        Task tsk = null;
        List<BudgetCategory__c> budCat = null;
        ApplicationBudgetCategory2__c appBudCat = null;
        System.runAs(u){
            ApplicationTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            TaskTriggerHelper.skipTrigger = true;
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            
            User u1 = TestHelper.getAdminUser(true);
            ann = TestHelper.getAnnouncement(true);
            Date myDate = Date.newInstance(2016, 12, 18);
            Time myTime = Time.newInstance(3, 3, 3, 0);
            DateTime dt = DateTime.newInstance(myDate, myTime);
           ann.ApplicationDeadlineWithDateTime__c = dt ;
            update ann;
            app = TestHelper.getApplication(ann.Id,true);
            app.AwardCeiling__c=1.0;
            app.Status__c='Internally Reviewed';
            app.FormsValidated__c=true;
            app.PrimaryApplicant__c=u1.Id;
            update app;
       
        
            
            tsk = TestHelper.getTask(true);
            tsk.WhatId = app.Id;
            tsk.OwnerId=app.PrimaryApplicant__c;
            tsk.Status='In Progress';
            update tsk;
            
            budCat = TestHelper.getBudgetCategory(true);
            appBudCat= new ApplicationBudgetCategory2__c(Application__c=app.Id,BudgetCategory__c=budCat[0].Id,Amount__c=10.0);
            insert appBudCat;
            
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
            ApplicationSubmissionHelper ctrl = new ApplicationSubmissionHelper();
            ctrl.layoutHolder = layoutHolder;
            ctrl.whenClicked();
            Test.stopTest();
        }
    }
    
     static testMethod void testWhenClicked5() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        Application__c app = null;
        Announcement__c ann = null;
        System.runAs(u){
            ApplicationTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            
            ann = TestHelper.getAnnouncement(true);
            Date myDate = Date.newInstance(2016, 12, 18);
            Time myTime = Time.newInstance(3, 3, 3, 0);
            DateTime dt = DateTime.newInstance(myDate, myTime);
            ann.ApplicationDeadlineWithDateTime__c = dt;
            update ann;
            app = TestHelper.getApplication(ann.Id,true);
            app.AwardCeiling__c=1.0;
            app.Status__c='Internally Reviewed';
            app.FormsValidated__c=false;
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
            ApplicationSubmissionHelper ctrl = new ApplicationSubmissionHelper();
            ctrl.layoutHolder = layoutHolder;
            ctrl.whenClicked();
            Test.stopTest();
        }
    }
    
     static testMethod void testWhenClicked6() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
       
        Application__c app = null;
        Application__c app2 = null;
        Announcement__c ann = null;
        Task tsk = null;
        List<BudgetCategory__c> budCat = null;
        ApplicationBudgetCategory2__c appBudCat = null;
        System.runAs(u){
            ApplicationTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            TaskTriggerHelper.skipTrigger = true;
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            
            User u1 = TestHelper.getAdminUser(true);
            ann = TestHelper.getAnnouncement(true);
            Date myDate = Date.newInstance(2016, 12, 18);
            Time myTime = Time.newInstance(3, 3, 3, 0);
            DateTime dt = DateTime.newInstance(myDate, myTime);
           ann.ApplicationDeadlineWithDateTime__c = dt;
            update ann;
            app = TestHelper.getApplication(ann.Id,true);
            app.AwardCeiling__c=1.0;
            app.NumberOfReviews__c=0;
            app.FormsValidated__c=true;
            app.PrimaryApplicant__c=u1.Id;
            app.NumberOfReviews__c=0;
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
            ApplicationSubmissionHelper ctrl = new ApplicationSubmissionHelper();
            ctrl.layoutHolder = layoutHolder;
            ctrl.whenClicked();
            Test.stopTest();
        }
    }
    
        static testMethod void testWhenClicked7() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
       
        Application__c app = null;
        Application__c app2 = null;
        Announcement__c ann = null;
        Task tsk = null;
        List<BudgetCategory__c> budCat = null;
        ApplicationBudgetCategory2__c appBudCat = null;
        System.runAs(u){
            ApplicationTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            TaskTriggerHelper.skipTrigger = true;
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            
            User u1 = TestHelper.getAdminUser(true);
            ann = TestHelper.getAnnouncement(true);
            Date myDate = Date.newInstance(2016, 12, 18);
            Time myTime = Time.newInstance(3, 3, 3, 0);
            DateTime dt = DateTime.newInstance(myDate, myTime);
            ann.ApplicationDeadlineWithDateTime__c = dt;
            update ann;
            app = TestHelper.getApplication(ann.Id,true);
            app.Status__c='Internally Reviewed';
            app.AwardCeiling__c=1.0;
            app.NumberOfReviews__c=0;
            app.FormsValidated__c=true;
            app.PrimaryApplicant__c=u1.Id;
            app.NumberOfReviews__c=0;
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
            ApplicationSubmissionHelper ctrl = new ApplicationSubmissionHelper();
            ctrl.layoutHolder = layoutHolder;
            ctrl.whenClicked();
            Test.stopTest();
        }
    }
    
        static testMethod void testWhenClicked8() {
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
       
        Application__c app = null;
        Application__c app2 = null;
        Announcement__c ann = null;
        Task tsk = null;
        List<BudgetCategory__c> budCat = null;
        ApplicationBudgetCategory2__c appBudCat = null;
        ApplicationBudgetCategory2__c appBudCat2 = null;
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
        System.runAs(u){
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
      
            ApplicationTriggerHelper.skipTrigger = true;
            AnnouncementTriggerHelper.skipTrigger = true;
            TaskTriggerHelper.skipTrigger = true;
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            
            User u1 = TestHelper.getAdminUser(true);
            ann = TestHelper.getAnnouncement(true);
            Date myDate = Date.newInstance(2016, 12, 18);
            Time myTime = Time.newInstance(3, 3, 3, 0);
            DateTime dt = DateTime.newInstance(myDate, myTime);
            ann.ApplicationDeadlineWithDateTime__c = dt ;
            ann.ApplicationCreatedOutside__c='Yes';
            update ann;
            
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
            app = TestHelper.getApplication(ann.Id,true);
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
            app.Status__c='Internally Reviewed';
            app.AwardCeiling__c= 1;
            app.FormsValidated__c=true;
            app.PrimaryApplicant__c=u1.Id;
            update app;
 
            budCat = TestHelper.getBudgetCategory(true);
            appbudCat = new ApplicationBudgetCategory2__c(Application__c = app.Id, BudgetCategory__c=budCat[0].Id);
            insert appbudCat;
            appbudCat.Amount__c = 2000;
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
            ApplicationSubmissionHelper ctrl = new ApplicationSubmissionHelper();
             ctrl.layoutHolder = layoutHolder;
            ctrl.whenClicked();
            Test.stopTest();
        }
    }
}