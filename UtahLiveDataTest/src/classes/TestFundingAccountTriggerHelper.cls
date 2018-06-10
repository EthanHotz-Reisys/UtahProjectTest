@isTest
public class TestFundingAccountTriggerHelper {
    
    static testMethod void testFundingAccTrigger() {
        FundingSource__c fundSrc = TestHelper.getFundingSource(true);
       
        
        
        BudgetCategory__c budCat = new BudgetCategory__c();
        insert budCat;
        
        BudgetCategoryMapping__c budCatMapping = new BudgetCategoryMapping__c();
        budCatMapping.SourceBudgetCategory__c= budCat.Id;
        insert budCatMapping;
        
        FundingSourceBudgetCategory__c fundSrcBudCat = new FundingSourceBudgetCategory__c();
        fundSrcBudCat.FundingSource__c=fundSrc.Id;
        fundSrcBudCat.BudgetCategory__c=budCat.Id;
        fundSrcBudCat.AllocatedAmount__c=5000;
        insert fundSrcBudCat;
        
        
        FundingAccount__c fundAcc = TestHelper.getFundingAccount(true,fundSrc.Id);
        fundAcc.AllocatedAmount__c=5000;
        update fundAcc;
        delete fundAcc;
    }
    
    static testMethod void testFundingAccTrigger2() {
        FundingSource__c fundSrc = TestHelper.getFundingSource(true);
        fundSrc.Type__c='Federal';
        update fundSrc;
        
        
        BudgetCategory__c budCat = new BudgetCategory__c();
        insert budCat;
        
        BudgetCategoryMapping__c budCatMapping = new BudgetCategoryMapping__c();
        budCatMapping.SourceBudgetCategory__c= budCat.Id;
        insert budCatMapping;
        
        FundingSourceBudgetCategory__c fundSrcBudCat = new FundingSourceBudgetCategory__c();
        fundSrcBudCat.FundingSource__c=fundSrc.Id;
        fundSrcBudCat.BudgetCategory__c=budCat.Id;
        fundSrcBudCat.AllocatedAmount__c=5000;
        insert fundSrcBudCat;
        
        
        FundingAccount__c fundAcc = TestHelper.getFundingAccount(true,fundSrc.Id);
        fundAcc.AllocatedAmount__c=5000;
        update fundAcc;
        delete fundAcc;
    }
}