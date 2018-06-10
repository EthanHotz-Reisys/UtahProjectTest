trigger BudgetCategoryMappingTrigger on BudgetCategoryMapping__c (before insert, before update, after undelete) {
    GNT.TriggerHelper th = new GNT.TriggerHelper ();
    th.setInternalUniqueID();
}