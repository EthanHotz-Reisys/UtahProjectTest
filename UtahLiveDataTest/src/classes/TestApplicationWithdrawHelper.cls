@isTest
private with sharing class TestApplicationWithdrawHelper{
    static testMethod void testwhenClicked() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          Account acct = null;
          
          System.runAs(u){
            AnnouncementTriggerHelper.skipTrigger = true;
            GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
            Announcement__c ann = TestHelper.getAnnouncement(true);
            
            ApplicationTriggerHelper.skipTrigger = true;
            Application__c app = TestHelper.getApplication(ann.Id,true);
            
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
            ApplicationWithdrawHelper ctrl = new ApplicationWithdrawHelper();
            ctrl.layoutHolder = layoutHolder;
            ctrl.whenClicked(); 
            delete app; 
            ctrl.whenClicked();       
            Test.stopTest();
        }
        
    }
    
}