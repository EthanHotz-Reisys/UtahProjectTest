trigger SObjectLayoutConfigTrigger  on GNT__SObjectLayoutConfig__c (before insert, before update,after undelete) {
	GNT.TriggerHelper th = new GNT.TriggerHelper ();
	    th.setInternalUniqueID();

}