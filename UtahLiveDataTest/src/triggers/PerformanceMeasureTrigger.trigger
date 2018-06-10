trigger PerformanceMeasureTrigger on PerformanceMeasure__c (before insert, after insert, before update, after update) {
 new PerformanceMeasureTriggerHelper().process();
}