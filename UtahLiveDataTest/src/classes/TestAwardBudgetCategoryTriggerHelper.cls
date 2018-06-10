@isTest
private with sharing class TestAwardBudgetCategoryTriggerHelper{

    static testMethod void testAwardBudCatTrigger(){
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        Grant__c grant = null;
        Award__c awards= null;
        GrantServiceArea__c grantServArea=null;
        AwardBudgetCategory__c awardbudCat = null;
         AwardBudgetCategory__c awardbudCat2 = null;
        
         System.runAs(u){
             GrantTriggerHelper.skipTrigger = true;
             AwardTriggerHelper.skipTrigger = true;
             RolesAndResponsibilitiesTriggerHelper.skipTrigger=true;
             grant = TestHelper.getGrant(true);
             awards = TestHelper.getAwards(grant.Id, true);
              
             grantServArea = new GrantServiceArea__c(Grant__c=grant.Id);
             insert grantServArea;
             grantServArea.AmountAllocated__c=1000;
             update grantServArea;
             
             awardbudCat = new AwardBudgetCategory__c(Award__c=awards.Id,GrantServiceArea__c=grantServArea.Id);
             insert awardbudCat;
             awardbudCat.Amount1__c=1000;
             update awardbudCat;
             
             delete awardbudCat;
             delete grantServArea;
         }
         
        
    }
}