trigger SpendPlanTrigger on SpendPlan__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    new SpendPlanTriggerHelper().process();
}