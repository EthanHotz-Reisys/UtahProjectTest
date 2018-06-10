trigger OpportunityQualificationTrigger on OpportunityQualification__c (before insert,after insert, before update, after undelete) {
    GNT.TriggerHelper th = new GNT.TriggerHelper ();
    th.setInternalUniqueID();
    new OpportunityQualificationTriggerHelper().process();
}