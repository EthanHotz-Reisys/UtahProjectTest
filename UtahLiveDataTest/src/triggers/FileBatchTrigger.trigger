trigger FileBatchTrigger on FileBatch__c (before insert, after update, before update) {
    new FileBatchTriggerHelper().process();
}