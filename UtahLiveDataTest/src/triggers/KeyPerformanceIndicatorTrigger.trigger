trigger KeyPerformanceIndicatorTrigger on KeyPerformanceIndicator__c (before insert, before update, after undelete) {
    GNT.TriggerHelper th = new GNT.TriggerHelper ();
    th.setInternalUniqueID(); 
}