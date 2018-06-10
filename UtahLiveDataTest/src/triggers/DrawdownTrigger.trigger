trigger DrawdownTrigger on Drawdown__c (after insert) {
    new DrawdownTriggerHelper().process();
}