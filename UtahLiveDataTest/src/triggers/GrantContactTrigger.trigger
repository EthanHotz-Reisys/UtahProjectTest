trigger GrantContactTrigger on GrantContact__c(before insert, after insert, after update, after undelete) {
    new GrantContactTriggerHelper().process();
}