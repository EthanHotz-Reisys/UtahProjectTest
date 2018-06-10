@isTest
private class TestUSBELEACostRateTriggerHelper {
    @isTest static void testMe(){
        USBELEACostRate__c usbl = new USBELEACostRate__c();
        insert usbl;
        update usbl;
    }
}