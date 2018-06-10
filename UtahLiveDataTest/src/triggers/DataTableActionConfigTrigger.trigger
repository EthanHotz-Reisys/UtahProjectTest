trigger DataTableActionConfigTrigger on GNT__DataTableAction__c (before insert, before update, after undelete) {
    GNT.TriggerHelper th = new GNT.TriggerHelper ();
    th.setInternalUniqueID();
}