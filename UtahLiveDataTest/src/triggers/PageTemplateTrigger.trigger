trigger PageTemplateTrigger on GNT__PageTemplate__c (before insert, before update, after undelete) {
    GNT.TriggerHelper th = new GNT.TriggerHelper ();
    th.setInternalUniqueID();

}