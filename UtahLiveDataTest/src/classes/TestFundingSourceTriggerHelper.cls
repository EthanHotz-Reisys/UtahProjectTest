/**
* Copyright REI Systems 2014 - 2016 
* Test Class for FundingSourceTriggerHelper
* Negative test case -  
* Positive test case - 
* @author smahavratayajula 
*/
@isTest
public class TestFundingSourceTriggerHelper {
    
    static testMethod void populateReferenceNo() {
        Grant__c grants =null;
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        system.debug('***Entering test coverage***');
        
        System.runAs(u){
            //GNT.TriggerHelper.skipTrigger=true;
            RolesAndResponsibilitiesTriggerHelper.skipTrigger=true;
            GrantTriggerHelper.skipTrigger=true;
            AwardTriggerHelper.skipTrigger=true;
            
            grants = TestHelper.getGrant(true);
            /*
            grants.recordTypeId = TestHelper.getRecordType(Schema.SObjectType.Grant__c, 'Grantee');
            grants.GranteePOC__c = u.Id;
            grants.Name='abcd';
            grants.ProjectPeriodStartDate__c=System.today();
            system.debug('***Trying to insert grant***');
            insert grants;
            system.debug('Grant Id : ' + grants.Id);
            
            BudgetPeriod__c budgetPeriod = new BudgetPeriod__c();
            budgetPeriod.Name = 'Test budget period name';
            insert budgetPeriod;
            
            System.debug('Budget period id : ' + budgetPeriod);
            
            Award__c award = new Award__c();
            award.Grant__c = grants.Id;
            award.GrantAwardName__c = 'Test title';
            award.FederalGrantAwardIdFAIN__c = 'test federal grant';
            award.BudgetPeriod__c = budgetPeriod.Id; 
            award.AwardType__c = 'New';
            award.TotalObligateAmount__c = 1000;
            // validation rule - AwardedAmountthisAction__c < TotalObligateAmount__c
            award.AwardedAmountthisAction__c = 100;
            insert award;*/
            
           /* RolesAndResponsibilities__c rolesAndResponsibilities = new RolesAndResponsibilities__c(Award__c = award.Id,
                                                                           BusinessRole__c='Program Approver');
            insert rolesAndResponsibilities;*/
            
           /* AwardBudgetCategory__c awardBudgetCategory = new AwardBudgetCategory__c();
            awardBudgetCategory.Award__c = award.Id;
            insert awardBudgetCategory;*/
            
         //   System.debug('Award budget category id : ' + awardBudgetCategory);
            
           /* FundingSource__c fsource = new FundingSource__c();
            fsource.Grant__c = grants.Id;
            fsource.SpendPlan__c = 'Awards';
            fsource.Title__c = 'Test Funding source';
            //fsource.StartDate__c = System.today() + 1 ;
            //fsource.EndDate__c = System.today() + 30;
            insert fsource;*/
            
            
            
            Award__c award = TestHelper.getAwards(grants.Id,true);
            award.IndirectCostRateDecision__c='Explicit';
            update award;
            
            AwardBudgetCategory__c awardbudCat = new AwardBudgetCategory__c();
            awardbudCat.Award__c=award.Id;
            insert awardbudCat;
            
            grants.LatestAwardId__c = award.Id;
            update grants;
          
            
            FundingSource__c fsource = new FundingSource__c(OrganizationName__c ='TestOrganization'+System.today(), FundingSourceID__c=''+System.today(), 
                    Type__c='State', Status__c = 'Active');
            fsource.Grant__c = grants.Id;
            fsource.Type__c='Federal';
            fsource.SpendPlan__c = 'Awards';
            fsource.Title__c = 'Test Funding source';
            fsource.StartDate__c = System.today() + 1 ;
            fsource.EndDate__c = System.today() + 30;
            fsource.Name='Fund1';
            insert fsource;
            
            FundingSource__c fsource2= new FundingSource__c();
            insert fsource2;
            delete fsource2;
           
            system.debug('FSource Grant ID:'+fsource.Grant__c);
            FundingAccount__c fundAcc = TestHelper.getFundingAccount(true,fsource.Id);
            
           // system.debug('Funding Source : ' + fsource.Id);
       }
             
    }
    
    /*static testMethod void someTest2() {
        Grant__c grants =null;
        User u = TestHelper.getAdminUser(true);
        system.debug('***Entering test coverage***');
        
        System.runAs(u){
            //GNT.TriggerHelper.skipTrigger=true;
            RolesAndResponsibilitiesTriggerHelper.skipTrigger=true;
            GrantTriggerHelper.skipTrigger=true;
            AwardTriggerHelper.skipTrigger=true;
            
            grants = TestHelper.getGrant(true);
            
            Award__c award = TestHelper.getAwards(grants.Id,true);
            award.IndirectCostRateDecision__c='Implicit';
            award.ApprovedIndirectCostRate__c=2.1;
            update award;
            
            BudgetCategory__c budCategory = new BudgetCategory__c();
            insert budCategory;
            
            AwardBudgetCategory__c awardbudCat = new AwardBudgetCategory__c();
            awardbudCat.Award__c=award.Id;
            awardbudCat.BudgetCategory__c=budCategory.Id;
            awardbudCat.Amount1__c= 5000;
            insert awardbudCat;
            
            grants.LatestAwardId__c = award.Id;
            update grants;
            
          
            
            FundingSource__c fsource = new FundingSource__c(OrganizationName__c ='TestOrganization'+System.today(), FundingSourceID__c=''+System.today(), 
                    Type__c='State', Status__c = 'Active');
            fsource.Grant__c = grants.Id;
            fsource.Type__c='Federal';
            fsource.SpendPlan__c = 'Awards';
            fsource.Title__c = 'Test Funding source';
            fsource.StartDate__c = System.today() + 1 ;
            fsource.EndDate__c = System.today() + 30;
            fsource.Name='Fund1';
            insert fsource;
            
            FundingAccount__c fundAcc = TestHelper.getFundingAccount(true,fsource.Id);
            
            FundingSourceBudgetCategory__c fundsrcbudCat = new FundingSourceBudgetCategory__c();
            fundsrcbudCat.FundingSource__c= fsource.Id;
            fundsrcbudCat.BudgetCategory__c=budCategory.Id;
            insert fundsrcbudCat;
            
            
      }      
             
    }*/
    
    
}