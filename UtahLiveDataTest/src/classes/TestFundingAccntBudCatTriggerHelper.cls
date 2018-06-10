@isTest
public class TestFundingAccntBudCatTriggerHelper {

      static testMethod void testFundingAccntBudCatTrigger() {
      
          FundingSource__c fundSrc = TestHelper.getFundingSource(true);
          FundingAccount__c fundAcc = TestHelper.getFundingAccount(true,fundSrc.Id);
         
          
          FundingSourceBudgetCategory__c fundSrcBudCat = new FundingSourceBudgetCategory__c(FundingSource__c=fundSrc.Id);
          FundingAccountBudgetCategory__c fundAccBudCat = new FundingAccountBudgetCategory__c(FundingAccount__c=fundAcc.Id);
          insert fundAccBudCat;
          fundAccBudCat.AmountAllocated__c=5000;
          fundAccBudCat.FundingSourceBudgetCategory__c=fundSrcBudCat.Id;
          update fundAccBudCat;
      }
}