trigger CaseTrigger on Case__c (before insert, after update, after insert) {
    new CaseTriggerHelper().Process();
}