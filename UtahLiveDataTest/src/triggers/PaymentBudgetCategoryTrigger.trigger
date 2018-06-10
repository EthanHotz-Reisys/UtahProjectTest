trigger PaymentBudgetCategoryTrigger on PaymentBudgetCategory__c (before insert, before update, after update, after undelete) {
    new PaymentBudgetCategoryTriggerHelper().process();
}