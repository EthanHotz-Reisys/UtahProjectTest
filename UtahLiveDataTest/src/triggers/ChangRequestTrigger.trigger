trigger ChangRequestTrigger on ChangeRequest__c (before insert, before update, after insert, after update) {
    new ChangeRequestTriggerHelper().process();
}