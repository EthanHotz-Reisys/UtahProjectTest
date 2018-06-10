trigger FundingAccountBudgetCategoryTrigger on FundingAccountBudgetCategory__c (before insert,before update,after insert, after update, after undelete) {
     new FundingAccntBudgetCategoryTriggerHelper().process();

}