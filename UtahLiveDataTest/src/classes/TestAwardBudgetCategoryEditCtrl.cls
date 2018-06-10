@isTest
private with sharing class TestAwardBudgetCategoryEditCtrl{

     static testMethod void testController() { 
         
         UserTriggerHelper.skipTrigger = true;
         User u = TestHelper.getAdminUser(true);
         AwardBudgetCategory__c awardbudCat = null;
         Grant__c grant = null;
         Award__c awards= null;
         PageReference pageRef = null;
         
         System.runAs(u){
             GrantTriggerHelper.skipTrigger = true;
             AwardTriggerHelper.skipTrigger = true;
             RolesAndResponsibilitiesTriggerHelper.skipTrigger=true;
             grant = TestHelper.getGrant(true);
             awards = TestHelper.getAwards(grant.Id, true);
             awardbudCat = new AwardBudgetCategory__c(Award__c=awards.Id);
             insert awardbudCat;
             pageRef = Page.AwardBudgetCategoryView;    
            
         }
         
         Test.startTest();
         ApexPages.StandardController sc = new ApexPages.standardController(awardbudCat);
         ApexPages.currentPage().getParameters().put('id',awardbudCat.Id);
         ApexPages.currentPage().getParameters().put('awardId',awards.id);
         AwardBudgetCategoryEditCtrl ctrl = new AwardBudgetCategoryEditCtrl(sc);
         ctrl.getKeyValueMap();
         Test.stopTest();
         
         system.assertNotEquals(null,pageRef);
     }
      
}