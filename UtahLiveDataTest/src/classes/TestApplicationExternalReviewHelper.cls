@isTest
private with sharing class TestApplicationExternalReviewHelper{

    static testMethod void testController() {
          
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              List<String> IdSet = new List<String>();
              GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
              AnnouncementTriggerHelper.skipTrigger=true;
              UserTriggerHelper.skipTrigger = true;
              
              Announcement__c ann = TestHelper.getAnnouncement(true);
             
              ApplicationTriggerHelper.skipTrigger= true;
              Application__c app = TestHelper.getApplication(ann.Id,false);
              app.Title__c='Test';
              app.Status__c='New';
              app.PrimaryApplicant__c=u.Id;
              insert app;
              
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
              ApplicationExternalReviewHelper ctrl = new ApplicationExternalReviewHelper();
              ctrl.layoutHolder = layoutHolder;
              ctrl.whenClicked();
              Test.stopTest();
         }
        
    }
    
}