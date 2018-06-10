trigger USBEFormTrigger on USBEForm__c (before insert,after insert,before update) {
 new USBEFormTriggerHelper().process();
}