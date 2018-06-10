trigger AwardServiceAreaTrigger on AwardServiceArea__c (after insert, after update, after undelete) {
    GNT.TriggerHelper th = new GNT.TriggerHelper ();
    th.setInternalUniqueID();

}