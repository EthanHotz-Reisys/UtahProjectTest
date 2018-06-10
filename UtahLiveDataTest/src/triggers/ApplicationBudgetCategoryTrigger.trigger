trigger ApplicationBudgetCategoryTrigger on ApplicationBudgetCategory2__c (before update, after update) {
    new ApplicationBudgetCategoryTriggerHelper().process();
}