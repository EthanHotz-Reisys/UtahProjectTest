@isTest
private with sharing class TestCreateAppFromPreApp{
    static testMethod void testwhenClicked() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
          
              AccountTriggerHelper.skipAll=true;
              AnnouncementTriggerHelper.skipTrigger = true;
              RolesandResponsibilitiesTriggerHelper.skipTrigger= true;
              PreApplication__c preApp = TestHelper.getPreApplication(true);

              String ns = AppUtils.getNamespacePrefix();
              GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'PreApplication__c');
              GNT__TabConfig__c tabConfig =  TestHelper.getTabConfig(pageLayoutConfig.Id,true);
              GNT__PageBlockConfig__c pageBlockConfig =  TestHelper.getPageBlockConfig(tabConfig.Id, true);
              GNT__PageBlockDetailConfig__c pageBlockDetailConfigList = TestHelper.getPageBlockDetailConfig(pageBlockConfig.Id,false); 
           
              if(pageBlockDetailConfigList.GNT__FieldAPIName__c == 'Name') {
                    insert pageBlockDetailConfigList;
              }
            
              GNT__PageLayoutActionConfig__c pageAction = TestHelper.getPageLayoutActionConfig(true,pageLayoutConfig.Id);
              GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, preApp.Id,true);
              Test.startTest();
              createAppFromPreApp ctrl = new createAppFromPreApp();
              ctrl.layoutHolder = layoutHolder;
              ctrl.whenClicked();
              Test.stopTest();
          }
        
    }
    
    static testMethod void testwhenClicked2() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
          
          System.runAs(u){
          
              AccountTriggerHelper.skipAll=true;
              AnnouncementTriggerHelper.skipTrigger = true;
              RolesandResponsibilitiesTriggerHelper.skipTrigger= true;
              PreApplication__c preApp = TestHelper.getPreApplication(true);

              String ns = AppUtils.getNamespacePrefix();
              GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'PreApplication__c');
              GNT__TabConfig__c tabConfig =  TestHelper.getTabConfig(pageLayoutConfig.Id,true);
              GNT__PageBlockConfig__c pageBlockConfig =  TestHelper.getPageBlockConfig(tabConfig.Id, true);
              GNT__PageBlockDetailConfig__c pageBlockDetailConfigList = TestHelper.getPageBlockDetailConfig(pageBlockConfig.Id,false); 
           
              if(pageBlockDetailConfigList.GNT__FieldAPIName__c == 'Name') {
                    insert pageBlockDetailConfigList;
              }
            
              GNT__PageLayoutActionConfig__c pageAction = TestHelper.getPageLayoutActionConfig(true,pageLayoutConfig.Id);
              GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, preApp.Id,true);
              GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
              Test.startTest();
              createAppFromPreApp ctrl = new createAppFromPreApp();
              ctrl.layoutHolder = layoutHolder;
              ctrl.whenClicked();
              Test.stopTest();
          }
        
    }
    
}