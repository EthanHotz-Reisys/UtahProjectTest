@isTest
private with sharing class TestSubmitPreApplicationHelper{
    static testMethod void testWhenClicked() {
          Account acct = null;
          UserTriggerHelper.skipTrigger=true;
          User u = TestHelper.getAdminUser(true);
          
          System.runAs(u){
             ApplicationTriggerHelper.skipTrigger = true;
             AnnouncementTriggerHelper.skipTrigger = true;
             GNT__CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
             
             PreApplication__c preApp = TestHelper.getPreApplication(false);
             preApp.Status__c='Created';
             insert preApp;
             
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
            SubmitPreApplicationHelper ctrl = new SubmitPreApplicationHelper();
            ctrl.layoutHolder = layoutHolder;
            ctrl.whenClicked();
            Test.stopTest();
        
         }
        
    }   
    
}