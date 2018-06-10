trigger BudgetPeriodTrigger on BudgetPeriod__c (after insert, before update, before delete ,after undelete) {
    new BudgetPeriodTriggerHelper().process();
}