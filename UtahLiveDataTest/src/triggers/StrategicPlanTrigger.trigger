trigger StrategicPlanTrigger on StrategicPlan__c (before insert, before update, after undelete, after insert) {
    new StrategicPlanTriggerHelper().process();
    /* Pranjali : The below lines are commented because they do not make a appropriate call to StrategicPlanTriggerHelper class */
    //GNT.TriggerHelper th = new GNT.TriggerHelper ();
    //th.setInternalUniqueID();
}