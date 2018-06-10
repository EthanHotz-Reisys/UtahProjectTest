trigger FlexGridConfigTrigger on GNT__FlexGridConfig__c (before insert, before update,after undelete) {
    GNT.TriggerHelper th = new GNT.TriggerHelper ();
    th.setInternalUniqueID();
}