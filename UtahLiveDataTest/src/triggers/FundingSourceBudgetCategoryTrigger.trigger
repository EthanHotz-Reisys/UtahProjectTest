trigger FundingSourceBudgetCategoryTrigger on FundingSourceBudgetCategory__c (before insert,before update,after insert, after update, after undelete,before delete) {
	new FundingSourceBudgetCategoryTriggerHelper().process();

}