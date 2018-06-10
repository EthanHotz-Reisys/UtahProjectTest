trigger CommunityRegistrationConfigDetailTrigger on CommunityRegistrationConfigDetail__c (after insert, after update, after undelete) {
    GNT.TriggerHelper th = new GNT.TriggerHelper ();
    th.setInternalUniqueID();

}