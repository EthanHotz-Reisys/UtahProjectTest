trigger GoalObjectiveTrigger on GoalObjective__c (before insert,after insert,before update,after update,before delete,after delete) {
  new GoalObjectiveTriggerHelper().process();
}