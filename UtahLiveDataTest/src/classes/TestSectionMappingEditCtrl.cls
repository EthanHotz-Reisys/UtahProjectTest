@isTest
private with sharing class TestSectionMappingEditCtrl{
    static testMethod void testController() {
          Account acct = null;
          User u = TestHelper.getAdminUser(true);
          
          System.runAs(u){
            
            GNT__PageLayoutConfig__c pageLayout = TestHelper.getPageLayoutConfig(true);
            GNT__TabConfig__c tabConfig = TestHelper.getTabConfig(pageLayout.Id,true);
            GNT__PageBlockConfig__c pageBlock =TestHelper.getPageBlockConfig(tabConfig.Id,true);
         
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(pageBlock);
            ApexPages.currentPage().getParameters().put('Id',pageBlock.id);
            SectionMappingEditCtrl ctrl = new SectionMappingEditCtrl(sc);
            ctrl.cancelPage= new PageReference('myPage.CancelPage');
            ctrl.savePage = new PageReference('myPage.SavePage');
            ctrl.getKeyValueMap();
            Test.stopTest();
        
     }
        
   }
   
}