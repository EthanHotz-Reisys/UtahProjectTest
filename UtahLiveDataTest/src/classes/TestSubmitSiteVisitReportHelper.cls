@isTest(seeAllData=False)
private class TestSubmitSiteVisitReportHelper{
   /* @isTest
    
    private static void testSubmitSiteVisitReportHelper(){
        CustomAppConfig__c cac = TestHelper.getCustomAppConfig(true);
       
        TaskTriggerHelper.skipTrigger = true;
      
        User u=TestHelper.getAdminUser(true);        
       
        System.runAs(u){
            Test.startTest();
            List<Id> createLayoutData = setLayoutData();
            Id pageLayoutId = createLayoutData.get(0);

            SiteVisit__c sitevisit= TestHelper.getSiteVisit(true);
           // sitevisit.Status__c = 'In Progress';
         //   insert  sitevisit;
            System.debug('sitevisit--->>>'+sitevisit);
            
            DynamicLayoutHolder dlh = new DynamicLayoutHolder(pageLayoutId,sitevisit.ID,true);
            SubmitSiteVisitReportHelper scorh =new SubmitSiteVisitReportHelper();
            scorh.layoutHolder=dlh;
            scorh.whenClicked();
            //system.assertnotEquals(scorh.whenClicked(),null);
             
            
            Test.stopTest();
        }
    }
    
    private static List<ID> setLayoutData(){
            
        List<ID> layoutIDs = new List<ID>();
        PageLayoutConfig__c pageLayoutConfig = TestHelper.getPageLayoutConfig(false);
        pageLayoutConfig.ObjectAPIName__c = 'SiteVisit__c ';
        insert pageLayoutConfig ;
        TabConfig__c tabConfig =  TestHelper.getTabConfig(pageLayoutConfig.Id,true);
        PageBlockConfig__c pageBlockConfig =  TestHelper.getPageBlockConfig(tabConfig.Id, true);
        PageBlockDetailConfig__c pageBlockDetailConfig = TestHelper.getPageBlockDetailConfig(pageBlockConfig.Id,true); 
        PageLayoutActionConfig__c pageAction = TestHelper.getPageLayoutActionConfig(true,pageLayoutConfig.Id);
        layoutIDs.add(pageLayoutConfig.Id);
        layoutIDs.add(tabConfig.ID);
        layoutIDs.add(pageBlockConfig.Id);
        layoutIDs.add(pageBlockDetailConfig.Id);
        layoutIDs.add(pageAction.Id);
        return layoutIDs;       
    
    }*/
}