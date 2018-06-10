@isTest
private class TestFormTableTriggerHelper {
   
    @isTest static void testme(){
        FormTable__c testt = new FormTable__c(Name = 'test');
        insert testt;
        update testt;
    }
}