trigger RiskItemTrigger on RiskItem__c (before insert, after insert, before update, after update) {
 new RiskItemTriggerHelper().process();
}