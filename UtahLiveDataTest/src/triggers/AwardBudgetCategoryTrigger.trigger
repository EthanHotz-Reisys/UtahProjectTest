trigger AwardBudgetCategoryTrigger on AwardBudgetCategory__c (before insert,before update,after insert, after update, before delete,after delete) {
	new AwardBudgetCategoryTriggerHelper().process();
}