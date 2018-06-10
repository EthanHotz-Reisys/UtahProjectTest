@isTest
public class TestFundingSourceBudCatTriggerHelper {

    static TestMethod void testTrigger(){
        
        FundingSourceBudgetCategory__c fundSrcCatBud = null;
        FundingSourceBudgetCategory__C fundSrcCatBud2=null;
        FundingSource__c fsource = null;
        UserTriggerHelper.skipTrigger = true; 
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u){
            fsource=TestHelper.getFundingSource(true);
            fundSrcCatBud = new FundingSourceBudgetCategory__c(FundingSource__c=fsource.Id);
            insert fundSrcCatBud;
            fundSrcCatBud.TotalAmountAllocated__c=0;
            update fundSrcCatBud;
            delete fundSrcCatBud;
        }
    }
    
    static TestMethod void testTrigger2(){
        FundingSourceBudgetCategory__c fundSrcBudCat = null;
        FundingSource__c fsource = null;
        Grant__c grants = null;
        Award__c award = null;
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        
        System.runAs(u){
        
            GrantTriggerHelper.skipTrigger=true;
            AwardTriggerHelper.skipTrigger=true;
            
            fsource=TestHelper.getFundingSource(true);
          //  fsource.RecordType.DeveloperName='External';
            update fsource;
            
            grants = TestHelper.getGrant(true);
            award = TestHelper.getAwards(grants.Id,true);
            
            AwardBudgetCategory__c awardbudCat = new AwardBudgetCategory__c();
            awardbudCat.Award__c=award.Id;
            insert awardbudCat;
            
            fundSrcBudCat = new FundingSourceBudgetCategory__c(FundingSource__c=fsource.Id);
            insert fundSrcBudCat;
            fundSrcBudCat.TotalAmountAllocated__c=5000;
            fundSrcBudCat.AwardBudgetCategory__c = awardbudCat.Id;
            update fundSrcBudCat;
           
        }
        
    }
}