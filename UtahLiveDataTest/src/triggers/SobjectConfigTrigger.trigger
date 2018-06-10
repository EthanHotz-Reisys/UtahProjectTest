trigger SobjectConfigTrigger on GNT__SobjectConfig__c (before insert, before update,after undelete) {
	GNT.TriggerHelper th = new GNT.TriggerHelper ();
    th.setInternalUniqueID();
}