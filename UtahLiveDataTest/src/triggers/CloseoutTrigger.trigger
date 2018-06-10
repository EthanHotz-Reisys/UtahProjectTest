trigger CloseoutTrigger on Closeout__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
     new CloseOutTriggerHelper().process();
}