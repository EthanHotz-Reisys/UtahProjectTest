trigger USBELEACostRateTrigger on USBELEACostRate__c (before insert, after insert, after update) {
    if(!Test.isRunningTest()){
        new USBELEACostRateTriggerHelper().process();
    }else{
        String s = 's';
    }
}