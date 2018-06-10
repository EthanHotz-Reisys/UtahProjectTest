@isTest
private with sharing class TestDeleteRiskAssessmentOnCancel{
    static testMethod void testwhenClicked() {
          UserTriggerHelper.skipTrigger = true;
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){
              GrantTriggerHelper.skipTrigger = true;
              Grant__c grant = TestHelper.getGrant(true);
              RiskAssessment__c riskAssess = new RiskAssessment__c(Grant__c=grant.Id);
              insert riskAssess;

               String ns = AppUtils.getNamespacePrefix();
               GNT__PageLayoutConfig__c pageLayoutConfig =  TestHelper.getPageLayoutConfig(true,ns + 'RiskAssessment__c');
               GNT__TabConfig__c tabConfig =  TestHelper.getTabConfig(pageLayoutConfig.Id,true);
               GNT__PageBlockConfig__c pageBlockConfig =  TestHelper.getPageBlockConfig(tabConfig.Id, true);
               GNT__PageBlockDetailConfig__c pageBlockDetailConfigList = TestHelper.getPageBlockDetailConfig(pageBlockConfig.Id,false); 
               if(pageBlockDetailConfigList.GNT__FieldAPIName__c == 'Name') {
                    insert pageBlockDetailConfigList;
                }
            
               GNT__PageLayoutActionConfig__c pageAction = TestHelper.getPageLayoutActionConfig(true,pageLayoutConfig.Id);
               GNT.DynamicLayoutHolder layoutHolder = new GNT.DynamicLayoutHolder(pageLayoutConfig.id, riskAssess.Id,true);
               
              Test.startTest();
              DeleteRiskAssessmentOnCancel ctrl = new DeleteRiskAssessmentOnCancel();
              ctrl.layoutHolder = layoutHolder;
              ctrl.whenClicked();
              Test.stopTest();
          }
        
    }
    
}