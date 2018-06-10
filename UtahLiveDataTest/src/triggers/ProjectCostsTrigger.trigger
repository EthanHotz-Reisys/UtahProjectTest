trigger ProjectCostsTrigger on ProjectCostByFundingSource__c (before insert, after insert, before update, after update) {
     new ProjectCostsTriggerHelper().process();
}