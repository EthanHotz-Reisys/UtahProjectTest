trigger FINETProgramTrigger on r_prog__c (before insert,after insert,before update,after update) {
  new FINETProgramTriggerHelper().process();
}